import 'package:flutter/material.dart';
import 'package:practiceapp/auth/auth_service.dart';
import 'package:practiceapp/pages/colors.dart';
import 'package:practiceapp/auth/login_page.dart';
import 'package:practiceapp/auth/signup_page.dart';
import 'appbar.dart';
import 'navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 1; // Profile tab
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final TextEditingController _fakePasswordController = TextEditingController(
    text: '********',
  );
  String? errorMessage;
  bool isUpdating = false;
  bool emailVerificationPending = false;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      // Already on Profile, do nothing
    } else if (index == 2) {
      // Bookmarks page (implement if you have it)
      // Navigator.pushReplacementNamed(context, '/bookmarks');
    }
  }

  @override
  void initState() {
    super.initState();
    final user = authService.value.currentUser;
    _usernameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      isUpdating = true;
      errorMessage = null;
    });
    final user = authService.value.currentUser;
    print(
      'Provider data: ${user?.providerData.map((p) => p.providerId).toList()}',
    );

    try {
      if (user != null) {
        print(user.providerData.map((p) => p.providerId).toList());
        // Update username if changed
        if (_usernameController.text != user.displayName) {
          await user.updateDisplayName(_usernameController.text);
        }
        // Update email if changed
        if (_emailController.text != user.email) {
          // Prompt for password
          final password = await _askPassword(context);
          if (password == null || password.isEmpty) {
            setState(() {
              errorMessage = 'Password is required to update email.';
            });
            return;
          }
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(cred);
          // This sends a verification email to the new address
          await user.verifyBeforeUpdateEmail(_emailController.text);
          setState(() {
            errorMessage =
                'Please verify your new email address to complete the update.';
            emailVerificationPending = true;
          });
          return;
        }
        await user.reload();
        authService.value = AuthService(); // Triggers listeners
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved!')));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        setState(() {
          errorMessage = 'Please sign in again to update your email.';
        });
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          errorMessage = 'This email is already in use by another account.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          errorMessage = 'The email address is not valid.';
        });
      } else {
        setState(() {
          errorMessage = e.message;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<String?> _askPassword(BuildContext context) async {
    String? password;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Re-authenticate'),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Enter your password'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                password = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return password;
  }

  Future<void> _resetPassword() async {
    final user = authService.value.currentUser;
    final email = user?.email ?? _emailController.text;
    if (email.isEmpty) {
      setState(() {
        errorMessage = 'No email found for password reset.';
      });
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() {
        errorMessage = 'Password reset email sent to $email';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to send password reset email: $e';
      });
    }
  }

  Future<void> _checkEmailVerified() async {
    final user = authService.value.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      setState(() {
        errorMessage = 'Email verified and updated successfully!';
        emailVerificationPending = false;
        // Optionally, update the controller to reflect the new email
        _emailController.text = user.email ?? '';
      });
    } else {
      setState(() {
        errorMessage = 'Email not verified yet. Please check your inbox.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.value.currentUser;

    // Update controllers if user changes
    if (_usernameController.text != (user?.displayName ?? '')) {
      _usernameController.text = user?.displayName ?? '';
    }
    if (_emailController.text != (user?.email ?? '')) {
      _emailController.text = user?.email ?? '';
    }

    return Scaffold(
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      appBar: const CustomAppBar(title: 'Profile', actions: []),
      backgroundColor: offwhite,
      body: Center(
        child: Card(
          color: mint,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                if (user != null) ...[
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: darkp),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lightp),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      // labelStyle: TextStyle(color: blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Fake password field
                  GestureDetector(
                    onTap: () async {
                      final shouldReset = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Reset Password'),
                          content: const Text(
                            'Do you want to reset your password?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (shouldReset == true) {
                        await _resetPassword();
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _fakePasswordController,
                        enabled: false,
                        obscureText:
                            false, // No need to obscure, since it's already stars
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: '********',
                          labelStyle: TextStyle(color: darkp),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: lightp),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (emailVerificationPending)
                    ElevatedButton(
                      onPressed: _checkEmailVerified,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightp,
                        foregroundColor: mint,
                      ),
                      child: const Text('I have verified my email'),
                    ),
                  isUpdating
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightp,
                            foregroundColor: mint,
                          ),
                          child: const Text('Save Changes'),
                        ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await authService.value.signOut();
                      setState(() {});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightp,
                      foregroundColor: mint,
                    ),
                    child: const Text('Sign Out'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        final password = await _askPassword(context);
                        if (password == null || password.isEmpty) {
                          setState(() {
                            errorMessage =
                                'Password is required to delete your account.';
                          });
                          return;
                        }
                        try {
                          await authService.value.deleteAccount(
                            email: _emailController.text,
                            password: password,
                          );
                          if (mounted) {
                            await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Profile Deleted'),

                                content: const Text(
                                  'Your account has been deleted successfully.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            errorMessage = 'Failed to delete account: $e';
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Delete Profile'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ).then((_) => setState(() {}));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightp,
                      foregroundColor: mint,
                    ),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ).then((_) => setState(() {}));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightp,
                      foregroundColor: mint,
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
