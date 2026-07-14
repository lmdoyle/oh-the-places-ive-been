import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/follow_event.dart';
import '../../models/visit.dart';
import '../../services/auth_service.dart';
import '../../services/feed_service.dart';
import '../../services/user_service.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/visit_card.dart';
import '../place/place_detail_screen.dart';
import '../profile/other_profile_screen.dart';

class _FeedItem {
  final DateTime timestamp;
  final Visit? visit;
  final FollowEvent? followEvent;

  _FeedItem.visit(Visit v)
    : timestamp = v.createdAt,
      visit = v,
      followEvent = null;

  _FeedItem.follow(FollowEvent f)
    : timestamp = f.createdAt,
      visit = null,
      followEvent = f;
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      body: userId == null
          ? const Center(child: Text('Sign in to see your feed'))
          : StreamBuilder<List<Visit>>(
              stream: FeedService.feedForUser(userId),
              builder: (context, visitSnap) {
                return StreamBuilder<List<FollowEvent>>(
                  stream: UserService.followerEvents(userId),
                  builder: (context, followSnap) {
                    if (visitSnap.hasError || followSnap.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${visitSnap.error ?? followSnap.error}',
                        ),
                      );
                    }

                    final items = <_FeedItem>[
                      ...(visitSnap.data ?? []).map(_FeedItem.visit),
                      ...(followSnap.data ?? []).map(_FeedItem.follow),
                    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                    if (items.isEmpty) {
                      return const Center(
                        child: Text('Follow people to see their places here'),
                      );
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        if (item.visit != null) {
                          return VisitCard(
                            visit: item.visit!,
                            showAuthor: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PlaceDetailScreen(visitId: item.visit!.id),
                              ),
                            ),
                          );
                        }
                        final event = item.followEvent!;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: event.followerPhotoUrl != null
                                ? NetworkImage(event.followerPhotoUrl!)
                                : null,
                            child: event.followerPhotoUrl == null
                                ? const Icon(Icons.person_add)
                                : null,
                          ),
                          title: Text(
                            '${event.followerName} started following you',
                          ),
                          subtitle: Text(
                            DateFormat.yMMMd().format(event.createdAt),
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OtherProfileScreen(uid: event.followerId),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
