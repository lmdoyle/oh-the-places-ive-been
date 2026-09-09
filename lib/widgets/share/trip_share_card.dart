import 'package:flutter/material.dart';
import '../../models/visit.dart';
import '../star_rating.dart';
import 'photo_collage.dart';
import 'share_card_frame.dart';

class TripShareCard extends StatelessWidget {
  final Visit visit;

  const TripShareCard({super.key, required this.visit});

  static const maxCollagePhotos = 4;

  static List<String> collagePhotoUrls(Visit visit) {
    return visit.photoUrls.take(maxCollagePhotos).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ShareCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: PhotoCollage(photoUrls: collagePhotoUrls(visit))),
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
