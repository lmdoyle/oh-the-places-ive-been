import 'package:flutter/material.dart';
import '../../models/visit.dart';
import '../star_rating.dart';
import 'photo_grid_background.dart';
import 'share_card_frame.dart';

class TripShareCard extends StatelessWidget {
  final Visit visit;

  const TripShareCard({super.key, required this.visit});

  // Same idea as ProfileShareCard's background — every photo tiled into a
  // mosaic rather than a curated few, capped well below "every photo this
  // trip has" so the preview isn't precaching dozens of images before
  // Share becomes usable.
  static const maxBackgroundPhotos = 24;

  static List<String> backgroundPhotoUrls(Visit visit) {
    return visit.photoUrls.take(maxBackgroundPhotos).toList();
  }

  @override
  Widget build(BuildContext context) {
    final photoUrls = backgroundPhotoUrls(visit);

    return ShareCardFrame(
      background: photoUrls.isEmpty
          ? null
          : PhotoGridBackground(photoUrls: photoUrls),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrls.isEmpty)
            const Expanded(
              child: Center(
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.white38,
                  size: 56,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.placeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  visit.country,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                if (visit.dateRangeLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    visit.dateRangeLabel!,
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
                if (visit.rating != null) ...[
                  const SizedBox(height: 6),
                  StarRating(rating: visit.rating!, size: 16),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
