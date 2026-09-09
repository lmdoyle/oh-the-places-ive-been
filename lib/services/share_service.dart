import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'web_download_stub.dart'
    if (dart.library.js_interop) 'web_download_web.dart'
    as web_download;

class ShareService {
  // Renders whatever's wrapped in the given RepaintBoundary key to a PNG.
  // pixelRatio is well past 1x so the exported image stays sharp at
  // Instagram's typical display size rather than looking pixelated.
  static Future<Uint8List> captureBoundary(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Opens the native share sheet on Android. On web there's no OS share
  // sheet, so share_plus falls back to the Web Share API or a direct
  // download — but that fallback isn't reliable everywhere: iOS Safari's
  // partial Web Share API support has been seen making it fall through to
  // a MissingPluginException for a native-only method channel that simply
  // doesn't exist on web. Rather than trust share_plus's own fallback
  // chain, catch any failure on web and do a plain browser download
  // ourselves — a straightforward Blob + <a download> click that works
  // uniformly across browsers, iOS Safari included.
  static Future<void> shareImage(
    Uint8List pngBytes, {
    required String fileName,
    String? text,
  }) async {
    final file = XFile.fromData(pngBytes, mimeType: 'image/png');
    try {
      await SharePlus.instance.share(
        ShareParams(files: [file], fileNameOverrides: [fileName], text: text),
      );
    } catch (e) {
      if (!kIsWeb) rethrow;
      web_download.downloadBytes(pngBytes, fileName);
    }
  }
}
