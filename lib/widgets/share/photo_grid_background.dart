import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Tiles the given photos into a dense mosaic filling the whole card, meant
// to sit behind ShareCardFrame's scrim as decorative texture rather than
// anything that needs to stay legible on its own. Cycles back through the
// list if there aren't enough photos to fill every tile — a handful of
// photos repeated still reads as a nice textured backdrop, the way a
// Spotify-Wrapped-style collage does.
class PhotoGridBackground extends StatelessWidget {
  final List<String> photoUrls;
  static const _columns = 4;
  static const _rows = 6;

  const PhotoGridBackground({super.key, required this.photoUrls});

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF00695C)),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      // More tiles than could plausibly fit the card's fixed height — the
      // grid just clips whatever doesn't fit, which is fine for a
      // background texture.
      itemCount: _columns * _rows,
      itemBuilder: (context, i) => CachedNetworkImage(
        imageUrl: photoUrls[i % photoUrls.length],
        fit: BoxFit.cover,
        // Sits behind a scrim already, so a broken tile just needs to not
        // dump raw error text into the mosaic — a flat tile is invisible
        // enough here.
        errorWidget: (context, url, error) =>
            const ColoredBox(color: Colors.black26),
      ),
    );
  }
}
