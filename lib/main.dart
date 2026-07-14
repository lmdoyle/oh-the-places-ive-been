import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'firebase_options.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/main_nav_shell.dart';
import 'services/theme_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  MobileAds.instance.initialize();
  await ThemeService.load();
  runApp(const OhThePlacesIveBeenApp());
}

class OhThePlacesIveBeenApp extends StatelessWidget {
  const OhThePlacesIveBeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: "Oh the Places I've Been",
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
          themeMode: mode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.hasData
                  ? const MainNavShell()
                  : const SignInScreen();
            },
          ),
        );
      },
    );
  }
}
