import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _error;

  Future<void> _submitEmailForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final user = _isRegistering
          ? await AuthService.registerWithEmail(email, password)
          : await AuthService.signInWithEmail(email, password);
      if (user != null && _isRegistering) {
        await UserService.createUserProfile(
          AppUser(uid: user.uid, displayName: email.split('@').first),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null) {
        final existing = await UserService.getUser(user.uid);
        if (existing == null) {
          await UserService.createUserProfile(AppUser(
            uid: user.uid,
            displayName: user.displayName ?? 'Traveler',
            email: user.email,
            photoUrl: user.photoURL,
          ));
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Oh the Places I've Been",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submitEmailForm,
                child: Text(_isRegistering ? 'Create account' : 'Sign in'),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _isRegistering = !_isRegistering),
                child: Text(_isRegistering
                    ? 'Already have an account? Sign in'
                    : "Don't have an account? Register"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
