import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../auth/sign_in_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: userId == null
          ? const SizedBox.shrink()
          : StreamBuilder<AppUser?>(
              stream: UserService.userStream(userId),
              builder: (context, snapshot) {
                final user = snapshot.data;
                if (user == null) return const SizedBox.shrink();
                return ListView(
                  children: [
                    SwitchListTile(
                      title: const Text('Private account'),
                      subtitle: const Text(
                          'When on, only approved followers can see your visited places'),
                      value: user.isPrivate,
                      onChanged: (value) => UserService.createUserProfile(
                        AppUser(
                          uid: user.uid,
                          displayName: user.displayName,
                          email: user.email,
                          photoUrl: user.photoUrl,
                          bio: user.bio,
                          isPrivate: value,
                          followerCount: user.followerCount,
                          followingCount: user.followingCount,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Log out'),
                      leading: const Icon(Icons.logout),
                      onTap: () async {
                        await AuthService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
