import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Lays out up to 8 photos adaptively: 1-4 get curated layouts (a single
// hero shot, a side-by-side split, one big + two small, or a 2x2 grid);
// 5-8 fall back to a plain grid (3 columns for 5-6, 4 columns for 7-8) —
// past that it stops reading as a collage and starts looking cluttered on
// a card this size.
class PhotoCollage extends StatelessWidget {
  final List<String> photoUrls;

  const PhotoCollage({super.key, required this.photoUrls});

  static const maxPhotos = 8;

  static Widget _tile(String url) => CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    // A broken/undecodable photo shouldn't dump raw error text onto a
    // branded card — just a quiet placeholder tile instead.
    errorWidget: (context, url, error) => const ColoredBox(
      color: Colors.black26,
      child: Icon(Icons.broken_image_outlined, color: Colors.white38),
    ),
  );

  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return const Center(
        child: Icon(
          Icons.photo_camera_outlined,
          color: Colors.white38,
          size: 56,
        ),
      );
    }
    if (photoUrls.length == 1) {
      return _tile(photoUrls[0]);
    }
    if (photoUrls.length == 2) {
      return Row(
        children: [
          Expanded(child: _tile(photoUrls[0])),
          const SizedBox(width: _gap),
          Expanded(child: _tile(photoUrls[1])),
        ],
      );
    }
    if (photoUrls.length == 3) {
      return Row(
        children: [
          Expanded(child: _tile(photoUrls[0])),
          const SizedBox(width: _gap),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _tile(photoUrls[1])),
                const SizedBox(height: _gap),
                Expanded(child: _tile(photoUrls[2])),
              ],
            ),
          ),
        ],
      );
    }
    if (photoUrls.length == 4) {
      final four = photoUrls;
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _tile(four[0])),
                const SizedBox(width: _gap),
                Expanded(child: _tile(four[1])),
              ],
            ),
          ),
          const SizedBox(height: _gap),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _tile(four[2])),
                const SizedBox(width: _gap),
                Expanded(child: _tile(four[3])),
              ],
            ),
          ),
        ],
      );
    }

    // 5-8 photos — a plain grid instead of a bespoke layout; caller is
    // expected to have already capped the list at maxPhotos.
    final shown = photoUrls.take(maxPhotos).toList();
    final columns = shown.length <= 6 ? 3 : 4;
    return _gridFill(shown, columns);
  }

  // Fills the available (bounded) space exactly regardless of row/column
  // count, via nested Expanded Rows/Columns rather than a GridView with a
  // fixed aspect ratio — a GridView's square tiles wouldn't necessarily add
  // up to the collage area's actual height, leaving an ugly gap under a
  // short grid or clipping a tall one. Pads a short last row with blank
  // space instead of stretching its tiles wider.
  static Widget _gridFill(List<String> urls, int columns) {
    final rows = <List<String?>>[];
    for (var i = 0; i < urls.length; i += columns) {
      rows.add(
        List.generate(columns, (c) => i + c < urls.length ? urls[i + c] : null),
      );
    }
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: rows[r][c] != null
                        ? _tile(rows[r][c]!)
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
