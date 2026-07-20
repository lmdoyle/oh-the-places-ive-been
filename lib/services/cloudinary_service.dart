import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // From your Cloudinary dashboard (Settings > Upload > Upload presets).
  // The upload preset must be "Unsigned" — that's what lets a client app
  // upload directly without exposing the account's API secret.
  static const _cloudName = 'mltx9mcs';
  static const _uploadPreset = 'PresetPublic';

  static Future<String> uploadImage(XFile file) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final bytes = await file.readAsBytes();
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Cloudinary upload failed: $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  static Future<List<String>> uploadImages(List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      urls.add(await uploadImage(file));
    }
    return urls;
  }
}
