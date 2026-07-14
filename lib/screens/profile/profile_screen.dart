import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/visit.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/ad_banner.dart';
import '../../widgets/travel_stats.dart';
import '../../widgets/visit_card.dart';
import '../notifications/notifications_screen.dart';
import '../place/place_detail_screen.dart';
import '../settings/settings_screen.dart';
import 'follow_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Sign in to view your profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<AppUser?>(
        stream: UserService.userStream(userId),
        builder: (context, userSnap) {
          if (userSnap.hasError) {
            return Center(child: Text('Error: ${userSnap.error}'));
          }
          final user = userSnap.data;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<List<Visit>>(
            stream: VisitService.visitsForUser(userId),
            builder: (context, visitSnap) {
              final visits = visitSnap.data ?? [];
              return Column(
                children: [
                  Padding(
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
                        if (user.bio != null) Text(user.bio!),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FollowListScreen(
                                    uid: userId,
                                    showFollowers: true,
                                  ),
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
                                  builder: (_) => FollowListScreen(
                                    uid: userId,
                                    showFollowers: false,
                                  ),
                                ),
                              ),
                              child: _Stat(
                                label: 'Following',
                                value: user.followingCount,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TravelStats(visits: visits),
                      ],
                    ),
                  ),
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
