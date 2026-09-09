import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

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

  // Opens the native share sheet (Android) with the image. On web, where
  // there's no OS share sheet and the Web Share API's file support is
  // inconsistent across browsers, share_plus falls back to downloading
  // the image directly (downloadFallbackEnabled is on by default) — the
  // user then posts it to Instagram themselves from their downloads.
  static Future<void> shareImage(
    Uint8List pngBytes, {
    required String fileName,
    String? text,
  }) async {
    final file = XFile.fromData(pngBytes, mimeType: 'image/png');
    await SharePlus.instance.share(
      ShareParams(files: [file], fileNameOverrides: [fileName], text: text),
    );
  }
}
