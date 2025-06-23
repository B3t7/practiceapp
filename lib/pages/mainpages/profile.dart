import 'package:flutter/material.dart';
import 'package:practiceapp/auth/signup_page.dart';
import 'package:practiceapp/auth/login_page.dart';
import 'package:practiceapp/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;
    final username = user?.displayName ?? 'Guest';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text('Username: $username'),
            const SizedBox(height: 24),
            if (user == null) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ).then((_) => setState(() {}));
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ).then((_) => setState(() {}));
                },
                child: const Text('Sign In'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  await authService.value.signOut();
                  setState(() {});
                },
                child: const Text('Sign Out'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
