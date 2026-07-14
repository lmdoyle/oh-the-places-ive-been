import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Loads a GeoJSON FeatureCollection asset once and matches its features'
// `name` property to arbitrary lookup strings, for rendering as highlighted
// map regions. Used for both the world countries and the US states datasets.
class _GeoBoundaryDataset {
  final String assetPath;
  final Map<String, String> aliases;
  Map<String, List<List<LatLng>>>? _boundariesByName;

  _GeoBoundaryDataset(this.assetPath, {this.aliases = const {}});

  Future<void> _ensureLoaded() async {
    if (_boundariesByName != null) return;

    final raw = await rootBundle.loadString(assetPath);
    final geojson = jsonDecode(raw) as Map<String, dynamic>;
    final features = geojson['features'] as List;

    final map = <String, List<List<LatLng>>>{};
    for (final feature in features) {
      final properties = feature['properties'] as Map<String, dynamic>;
      final name = (properties['name'] as String).toLowerCase();
      final geometry = feature['geometry'] as Map<String, dynamic>;

      final rings = <List<LatLng>>[];
      if (geometry['type'] == 'Polygon') {
        rings.add(_outerRing(geometry['coordinates'] as List));
      } else if (geometry['type'] == 'MultiPolygon') {
        for (final polygon in geometry['coordinates'] as List) {
          rings.add(_outerRing(polygon as List));
        }
      }
      map[name] = rings;
    }
    _boundariesByName = map;
  }

  // Only the outer ring is used (holes are ignored) — fine for a highlight
  // overlay where minor overlap with an enclosed neighbor isn't noticeable.
  List<LatLng> _outerRing(List polygonCoordinates) {
    final outer = polygonCoordinates.first as List;
    return outer
        .map(
          (point) => LatLng(
            ((point as List)[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<List<Polygon>> polygonsForNames(
    Set<String> names, {
    required Color color,
    required Color borderColor,
  }) async {
    await _ensureLoaded();
    final polygons = <Polygon>[];
    for (final rawName in names) {
      final normalized = rawName.trim().toLowerCase();
      final lookupName = aliases[normalized] ?? normalized;
      final rings = _boundariesByName![lookupName];
      if (rings == null) continue;
      for (final ring in rings) {
        polygons.add(
          Polygon(
            points: ring,
            color: color,
            borderColor: borderColor,
            borderStrokeWidth: 1.5,
          ),
        );
      }
    }
    return polygons;
  }
}

// Maps alternate country names (e.g. what Nominatim returns) to the name
// used in assets/countries.geo.json. Extend as mismatches turn up. Shared
// with ContinentService so country matching stays consistent everywhere.
const countryNameAliases = {
  'united states': 'united states of america',
  'usa': 'united states of america',
  'czechia': 'czech republic',
  "côte d'ivoire": 'ivory coast',
  "cote d'ivoire": 'ivory coast',
  'north macedonia': 'macedonia',
  'myanmar (burma)': 'myanmar',
  'eswatini': 'swaziland',
  'bahamas': 'the bahamas',
  'tanzania': 'united republic of tanzania',
  'congo-brazzaville': 'republic of the congo',
  'congo-kinshasa': 'democratic republic of the congo',
  'dr congo': 'democratic republic of the congo',
  'russian federation': 'russia',
};

class CountryBoundariesService {
  static final _dataset = _GeoBoundaryDataset(
    'assets/countries.geo.json',
    aliases: countryNameAliases,
  );

  static Future<List<Polygon>> polygonsForCountries(
    Set<String> countryNames, {
    required Color color,
    required Color borderColor,
  }) {
    return _dataset.polygonsForNames(
      countryNames,
      color: color,
      borderColor: borderColor,
    );
  }
}

class UsStateBoundariesService {
  static final _dataset = _GeoBoundaryDataset('assets/us_states.geo.json');

  static Future<List<Polygon>> polygonsForStates(
    Set<String> stateNames, {
    required Color color,
    required Color borderColor,
  }) {
    return _dataset.polygonsForNames(
      stateNames,
      color: color,
      borderColor: borderColor,
    );
  }
}
