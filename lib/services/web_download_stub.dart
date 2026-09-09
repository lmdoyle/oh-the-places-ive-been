import 'dart:typed_data';

// Real implementation lives in web_download_web.dart, swapped in for web
// builds via a conditional import — this stub exists so non-web builds have
// something to compile against; it's never actually called there, since
// ShareService only reaches for it after a web-only share failure.
void downloadBytes(Uint8List bytes, String fileName) {
  throw UnsupportedError('downloadBytes is only available on web');
}
