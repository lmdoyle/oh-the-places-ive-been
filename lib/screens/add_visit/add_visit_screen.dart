import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../models/visit.dart';
import '../../services/auth_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/geocoding_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/xfile_thumbnail.dart';

class AddVisitScreen extends StatefulWidget {
  const AddVisitScreen({super.key});

  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final _searchController = TextEditingController();
  final _commentController = TextEditingController();
  final _mapController = MapController();
  Timer? _debounce;
  List<PlaceResult> _results = [];
  PlaceResult? _selectedPlace;
  DateTimeRange? _visitedRange;
  int _rating = 0;
  final List<XFile> _photos = [];
  bool _isSaving = false;

  PlaceResult? get _markerPlace =>
      _selectedPlace ?? (_results.isNotEmpty ? _results.first : null);

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final languageCode = Localizations.localeOf(context).languageCode;
      final results = await GeocodingService.search(
        query,
        languageCode: languageCode,
      );
      if (!mounted) return;
      setState(() {
        _selectedPlace = null;
        _results = results;
      });
      if (results.isNotEmpty) {
        _mapController.move(
          LatLng(results.first.latitude, results.first.longitude),
          10,
        );
      }
    });
  }

  void _selectPlace(PlaceResult place) {
    setState(() {
      _selectedPlace = place;
      _searchController.text = place.displayName;
      _results = [];
    });
    _mapController.move(LatLng(place.latitude, place.longitude), 12);
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) setState(() => _photos.addAll(picked));
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _visitedRange,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (range != null) setState(() => _visitedRange = range);
  }

  Future<void> _save() async {
    final place = _selectedPlace;
    final userId = AuthService.currentUser?.uid;
    if (place == null || userId == null) return;

    setState(() => _isSaving = true);
    try {
      final visitId = await VisitService.addVisit(
        Visit(
          id: '',
          userId: userId,
          placeName: place.placeName,
          country: place.country,
          state: place.state,
          latitude: place.latitude,
          longitude: place.longitude,
          visitedFrom: _visitedRange?.start,
          visitedTo: _visitedRange?.end,
          rating: _rating > 0 ? _rating : null,
          comment: _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      if (_photos.isNotEmpty) {
        final urls = await CloudinaryService.uploadImages(_photos);
        await VisitService.updateVisit(visitId, {'photoUrls': urls});
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerPlace = _markerPlace;
    return Scaffold(
      appBar: AppBar(title: const Text("Add a place")),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(20, 0),
                initialZoom: 2,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.gamerguytv.oh_the_places_ive_been',
                ),
                if (markerPlace != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          markerPlace.latitude,
                          markerPlace.longitude,
                        ),
                        width: 36,
                        height: 36,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search a place',
                    hintText: 'e.g. Vienna, Austria',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _onSearchChanged,
                ),
                if (_selectedPlace == null)
                  ..._results.map(
                    (r) => ListTile(
                      title: Text(r.displayName),
                      onTap: () => _selectPlace(r),
                    ),
                  ),
                if (_selectedPlace != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _visitedRange == null
                              ? 'No dates set'
                              : '${DateFormat.yMMMd().format(_visitedRange!.start)} – '
                                    '${DateFormat.yMMMd().format(_visitedRange!.end)}',
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDateRange,
                        child: const Text('Pick dates'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StarRating(
                    rating: _rating,
                    onChanged: (r) => setState(() => _rating = r),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ..._photos.map(
                        (p) => ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: XFileThumbnail(file: p),
                        ),
                      ),
                      InkWell(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text("I've been here"),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
