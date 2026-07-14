import 'package:flutter/material.dart';
import '../../widgets/ad_banner.dart';

// New followers, likes, and comments will populate this once a Cloud
// Function writes to a per-user notifications collection on those events.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const Center(child: Text('No notifications yet')),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
