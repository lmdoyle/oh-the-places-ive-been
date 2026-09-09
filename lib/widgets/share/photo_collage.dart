import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Lays out 1-4 photos adaptively — a single hero shot, a side-by-side
// split, one big + two small, or a 2x2 grid — rather than only ever
// showing a trip's first photo.
class PhotoCollage extends StatelessWidget {
  final List<String> photoUrls;

  const PhotoCollage({super.key, required this.photoUrls});

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

    // 4 or more — only the first 4 are shown, the caller is expected to
    // have already capped the list to match what it preloaded.
    final four = photoUrls.take(4).toList();
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
}
