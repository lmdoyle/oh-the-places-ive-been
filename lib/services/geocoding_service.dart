import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceResult {
  final String displayName;
  final String placeName;
  final String country;
  final String? state;
  final double latitude;
  final double longitude;

  const PlaceResult({
    required this.displayName,
    required this.placeName,
    required this.country,
    this.state,
    required this.latitude,
    required this.longitude,
  });
}

class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  // Nominatim's usage policy requires a descriptive User-Agent and caps
  // requests at ~1/sec: https://operations.osmfoundation.org/policies/nominatim/
  static const _userAgent = 'OhThePlacesIveBeen/1.0';

  static Future<List<PlaceResult>> search(String query,
      {String? languageCode}) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '8',
      // Falls back to English when a result has no translation in the
      // device's language, rather than showing the place's local script.
      'accept-language': languageCode != null ? '$languageCode,en' : 'en',
    });

    final response = await http.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) return [];

    final results = jsonDecode(response.body) as List;
    return results.map((r) {
      final address = r['address'] as Map<String, dynamic>? ?? {};
      final placeName = address['city'] ??
          address['town'] ??
          address['village'] ??
          address['county'] ??
          r['name'] ??
          r['display_name'];
      return PlaceResult(
        displayName: r['display_name'] as String,
        placeName: placeName as String,
        country: address['country'] as String? ?? '',
        state: address['state'] as String?,
        latitude: double.parse(r['lat'] as String),
        longitude: double.parse(r['lon'] as String),
      );
    }).toList();
  }
}
