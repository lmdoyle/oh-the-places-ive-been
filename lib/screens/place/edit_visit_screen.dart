import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/visit.dart';
import '../../services/cloudinary_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/star_rating.dart';
import '../../widgets/xfile_thumbnail.dart';

class EditVisitScreen extends StatefulWidget {
  final Visit visit;

  const EditVisitScreen({super.key, required this.visit});

  @override
  State<EditVisitScreen> createState() => _EditVisitScreenState();
}

class _EditVisitScreenState extends State<EditVisitScreen> {
  late final _commentController = TextEditingController(
    text: widget.visit.comment ?? '',
  );
  late DateTimeRange? _visitedRange = widget.visit.visitedFrom == null
      ? null
      : DateTimeRange(
          start: widget.visit.visitedFrom!,
          end: widget.visit.visitedTo ?? widget.visit.visitedFrom!,
        );
  late int _rating = widget.visit.rating ?? 0;
  late final List<String> _existingPhotoUrls = List.from(
    widget.visit.photoUrls,
  );
  final List<XFile> _newPhotos = [];
  bool _isSaving = false;

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: _visitedRange,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (range != null) setState(() => _visitedRange = range);
  }

  Future<void> _pickPhotos() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) setState(() => _newPhotos.addAll(picked));
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uploadedUrls = _newPhotos.isEmpty
          ? <String>[]
          : await CloudinaryService.uploadImages(_newPhotos);

      await VisitService.updateVisit(widget.visit.id, {
        'visitedFrom': _visitedRange?.start.toIso8601String(),
        'visitedTo': _visitedRange?.end.toIso8601String(),
        'rating': _rating > 0 ? _rating : null,
        'comment': _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        'photoUrls': [..._existingPhotoUrls, ...uploadedUrls],
      });

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${widget.visit.placeName}?'),
        content: const Text(
          "This can't be undone — the visit, its photos, likes, and comments will all be gone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await VisitService.deleteVisit(widget.visit.id);
    if (mounted) {
      // Pop both this screen and the place detail screen behind it, since
      // that visit no longer exists.
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.visit.placeName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            runSpacing: 8,
            children: [
              ..._existingPhotoUrls.map(
                (url) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _existingPhotoUrls.remove(url)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._newPhotos.map(
                (p) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: XFileThumbnail(file: p),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() => _newPhotos.remove(p)),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
