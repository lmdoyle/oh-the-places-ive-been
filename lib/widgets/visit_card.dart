import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/visit.dart';
import '../services/user_service.dart';
import 'star_rating.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VoidCallback onTap;
  final bool showAuthor;

  const VisitCard({
    super.key,
    required this.visit,
    required this.onTap,
    this.showAuthor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAuthor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FutureBuilder<AppUser?>(
                    future: UserService.getUser(visit.userId),
                    builder: (context, snapshot) {
                      final author = snapshot.data;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: author?.photoUrl != null
                                ? NetworkImage(author!.photoUrl!)
                                : null,
                            child: author?.photoUrl == null
                                ? Text(
                                    author != null &&
                                            author.displayName.isNotEmpty
                                        ? author.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            author?.displayName ?? '...',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${visit.placeName}, ${visit.country}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (visit.rating != null)
                    StarRating(rating: visit.rating!, size: 16),
                ],
              ),
              if (visit.dateRangeLabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    visit.dateRangeLabel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (visit.comment != null && visit.comment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(visit.comment!),
                ),
              if (visit.photoUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: visit.photoUrls.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 6),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: visit.photoUrls[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.favorite, size: 16),
                    const SizedBox(width: 4),
                    Text('${visit.likeCount}'),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment, size: 16),
                    const SizedBox(width: 4),
                    Text('${visit.commentCount}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
