import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/visit.dart';
import '../../models/visit_comment.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/star_rating.dart';
import '../profile/other_profile_screen.dart';
import '../report/report_sheet.dart';
import 'edit_visit_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String visitId;

  const PlaceDetailScreen({super.key, required this.visitId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Visit?>(
      stream: VisitService.visitStream(widget.visitId),
      builder: (context, snapshot) {
        final visit = snapshot.data;
        final isOwner =
            visit != null && visit.userId == AuthService.currentUser?.uid;
        return Scaffold(
          appBar: AppBar(
            actions: [
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditVisitScreen(visit: visit),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => ReportSheet(
                    targetType: ReportTargetType.visit,
                    targetId: widget.visitId,
                  ),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (visit == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FutureBuilder<AppUser?>(
                    future: UserService.getUser(visit.userId),
                    builder: (context, authorSnap) {
                      final author = authorSnap.data;
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OtherProfileScreen(uid: visit.userId),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: author?.photoUrl != null
                                  ? NetworkImage(author!.photoUrl!)
                                  : null,
                              child: author?.photoUrl == null
                                  ? Text(
                                      author != null &&
                                              author.displayName.isNotEmpty
                                          ? author.displayName[0].toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              author?.displayName ?? '...',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${visit.placeName}, ${visit.country}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (visit.dateRangeLabel != null) Text(visit.dateRangeLabel!),
                  if (visit.rating != null) ...[
                    const SizedBox(height: 8),
                    StarRating(rating: visit.rating!),
                  ],
                  if (visit.comment != null) ...[
                    const SizedBox(height: 12),
                    Text(visit.comment!),
                  ],
                  if (visit.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                      itemCount: visit.photoUrls.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: visit.photoUrls[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  StreamBuilder<bool>(
                    stream: VisitService.isLikedByCurrentUser(widget.visitId),
                    builder: (context, likedSnap) {
                      final liked = likedSnap.data ?? false;
                      return IconButton(
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? Colors.red : null,
                        ),
                        onPressed: AuthService.currentUser == null
                            ? null
                            : () =>
                                  VisitService.setLiked(widget.visitId, !liked),
                      );
                    },
                  ),
                  const Divider(),
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  StreamBuilder<List<VisitComment>>(
                    stream: VisitService.commentsForVisit(widget.visitId),
                    builder: (context, snapshot) {
                      final comments = snapshot.data ?? [];
                      return Column(
                        children: comments
                            .map(
                              (c) => ListTile(
                                title: Text(c.text),
                                subtitle: Text(
                                  DateFormat.yMMMd().add_jm().format(
                                    c.createdAt,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_commentController.text.trim().isEmpty) return;
                          VisitService.addComment(
                            widget.visitId,
                            _commentController.text.trim(),
                          );
                          _commentController.clear();
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: const AdBanner(),
        );
      },
    );
  }
}
