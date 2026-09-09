import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/visit.dart';
import '../star_rating.dart';
import 'share_card_frame.dart';

class TripShareCard extends StatelessWidget {
  final Visit visit;

  const TripShareCard({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return ShareCardFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (visit.photoUrls.isNotEmpty)
            Expanded(
              child: CachedNetworkImage(
                imageUrl: visit.photoUrls.first,
                fit: BoxFit.cover,
              ),
            )
          else
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
