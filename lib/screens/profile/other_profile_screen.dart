import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/visit.dart';
import '../../services/user_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/travel_stats.dart';
import '../../widgets/visit_card.dart';
import '../place/place_detail_screen.dart';
import 'follow_list_screen.dart';

class OtherProfileScreen extends StatelessWidget {
  final String uid;

  const OtherProfileScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<AppUser?>(
        stream: UserService.userStream(uid),
        builder: (context, userSnap) {
          if (userSnap.hasError) {
            return Center(child: Text('Error: ${userSnap.error}'));
          }
          final user = userSnap.data;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          Widget header(List<Visit> visits) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName.isNotEmpty
                              ? user.displayName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FollowListScreen(uid: uid, showFollowers: true),
                        ),
                      ),
                      child: _Stat(
                        label: 'Followers',
                        value: user.followerCount,
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FollowListScreen(uid: uid, showFollowers: false),
                        ),
                      ),
                      child: _Stat(
                        label: 'Following',
                        value: user.followingCount,
                      ),
                    ),
                  ],
                ),
                if (!user.isPrivate) ...[
                  const SizedBox(height: 12),
                  TravelStats(visits: visits),
                ],
                const SizedBox(height: 12),
                StreamBuilder<bool>(
                  stream: UserService.isFollowing(uid),
                  builder: (context, followSnap) {
                    final following = followSnap.data ?? false;
                    return OutlinedButton(
                      onPressed: () => following
                          ? UserService.unfollow(uid)
                          : UserService.follow(uid),
                      child: Text(following ? 'Unfollow' : 'Follow'),
                    );
                  },
                ),
              ],
            ),
          );

          if (user.isPrivate) {
            return Column(
              children: [
                header(const []),
                const Divider(height: 1),
                const Expanded(
                  child: Center(child: Text('This account is private')),
                ),
              ],
            );
          }

          return StreamBuilder<List<Visit>>(
            stream: VisitService.visitsForUser(uid),
            builder: (context, snapshot) {
              final visits = (snapshot.data ?? [])
                  .where((v) => v.isPublic)
                  .toList();
              return Column(
                children: [
                  header(visits),
                  const Divider(height: 1),
                  Expanded(
                    child: visits.isEmpty
                        ? const Center(child: Text('No places yet'))
                        : ListView.builder(
                            itemCount: visits.length,
                            itemBuilder: (context, i) => VisitCard(
                              visit: visits[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PlaceDetailScreen(visitId: visits[i].id),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
