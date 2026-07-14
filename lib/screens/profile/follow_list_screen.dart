import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';
import '../../widgets/ad_banner.dart';
import 'other_profile_screen.dart';

class FollowListScreen extends StatelessWidget {
  final String uid;
  final bool showFollowers;

  const FollowListScreen({
    super.key,
    required this.uid,
    required this.showFollowers,
  });

  @override
  Widget build(BuildContext context) {
    final subcollection = showFollowers ? 'followers' : 'following';
    return Scaffold(
      appBar: AppBar(title: Text(showFollowers ? 'Followers' : 'Following')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection(subcollection)
            .snapshots(),
        builder: (context, snapshot) {
          final ids = snapshot.data?.docs.map((d) => d.id).toList() ?? [];
          if (ids.isEmpty) {
            return Center(
              child: Text(
                showFollowers ? 'No followers yet' : 'Not following anyone yet',
              ),
            );
          }
          return ListView.builder(
            itemCount: ids.length,
            itemBuilder: (context, i) => FutureBuilder<AppUser?>(
              future: UserService.getUser(ids[i]),
              builder: (context, userSnap) {
                final user = userSnap.data;
                if (user == null) return const SizedBox.shrink();
                return ListTile(
                  leading: CircleAvatar(
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
                  title: Text(user.displayName),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtherProfileScreen(uid: user.uid),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
