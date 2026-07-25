import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/visit.dart';
import '../../services/auth_service.dart';
import '../../services/country_boundaries_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/ad_banner.dart';
import '../add_visit/add_visit_screen.dart';
import '../place/place_detail_screen.dart';

// Countries here show a state-level highlight instead of a whole-country
// blob, since a visit to one state shouldn't shade the entire country.
const _usCountryNames = {'united states', 'usa', 'united states of america'};

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  Future<List<Polygon>> _highlightPolygons(List<Visit> visits) async {
    final countries = visits
        .where((v) => !_usCountryNames.contains(v.country.trim().toLowerCase()))
        .map((v) => v.country)
        .where((c) => c.isNotEmpty)
        .toSet();
    final usStates = visits
        .where(
          (v) =>
              _usCountryNames.contains(v.country.trim().toLowerCase()) &&
              (v.state?.isNotEmpty ?? false),
        )
        .map((v) => v.state!)
        .toSet();

    final results = await Future.wait([
      CountryBoundariesService.polygonsForCountries(
        countries,
        color: Colors.teal.withValues(alpha: 0.35),
        borderColor: Colors.teal,
      ),
      UsStateBoundariesService.polygonsForStates(
        usStates,
        color: Colors.teal.withValues(alpha: 0.35),
        borderColor: Colors.teal,
      ),
    ]);
    return [...results[0], ...results[1]];
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text("Oh the Places I've Been")),
      body: userId == null
          ? const Center(child: Text('Sign in to see your map'))
          : StreamBuilder<List<Visit>>(
              stream: VisitService.visitsForUser(userId),
              builder: (context, snapshot) {
                final visits = snapshot.data ?? [];

                return FutureBuilder<List<Polygon>>(
                  future: _highlightPolygons(visits),
                  builder: (context, polygonSnap) {
                    final polygons = polygonSnap.data ?? [];
                    return FlutterMap(
                      options: const MapOptions(
                        initialCenter: LatLng(20, 0),
                        initialZoom: 2,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.gamerguytv.oh_the_places_ive_been',
                        ),
                        if (polygons.isNotEmpty)
                          PolygonLayer(polygons: polygons),
                        MarkerLayer(
                          markers: visits
                              .map(
                                (v) => Marker(
                                  point: LatLng(v.latitude, v.longitude),
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.topCenter,
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            PlaceDetailScreen(visitId: v.id),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddVisitScreen()),
        ),
        child: const Icon(Icons.add_location_alt),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
