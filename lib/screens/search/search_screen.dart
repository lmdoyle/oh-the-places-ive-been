import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';
import '../../widgets/ad_banner.dart';
import '../profile/other_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Timer? _debounce;
  List<AppUser> _results = [];

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await UserService.searchByName(query);
      if (mounted) setState(() => _results = results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search travelers',
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
      ),
      body: ListView(
        children: _results
            .map(
              (u) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: u.photoUrl != null
                      ? NetworkImage(u.photoUrl!)
                      : null,
                  child: u.photoUrl == null
                      ? Text(
                          u.displayName.isNotEmpty
                              ? u.displayName[0].toUpperCase()
                              : '?',
                        )
                      : null,
                ),
                title: Text(u.displayName),
                subtitle: u.isPrivate ? const Text('Private account') : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtherProfileScreen(uid: u.uid),
                  ),
                ),
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }
}
