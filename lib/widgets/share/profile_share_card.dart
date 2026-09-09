import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/travel_stats_data.dart';
import '../../models/visit.dart';
import 'share_card_frame.dart';

class ProfileShareCard extends StatelessWidget {
  final AppUser user;
  final List<Visit> visits;

  const ProfileShareCard({super.key, required this.user, required this.visits});

  @override
  Widget build(BuildContext context) {
    final stats = TravelStatsData.compute(visits);

    return ShareCardFrame(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              backgroundImage: user.photoUrl != null
                  ? CachedNetworkImageProvider(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              user.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'My travel footprint',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _StatTile(value: '${stats.countries}', label: 'Countries'),
                _StatTile(value: '${stats.states}', label: 'US States'),
                _StatTile(value: '${stats.continents}', label: 'Continents'),
                _StatTile(
                  value: '${stats.worldPercent.toStringAsFixed(1)}%',
                  label: 'of the World',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
