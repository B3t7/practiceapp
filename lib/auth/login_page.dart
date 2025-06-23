import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../pages/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String? errorMessage;
  bool isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await authService.value.signIn(email: email, password: password);
      if (mounted) {
        Navigator.pop(context); // This returns to ProfilePage and triggers setState
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: lightp,
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          color: mint,
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: darkp),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lightp),
                      ),
                    ),
                    onChanged: (value) => email = value,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Enter an email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: darkp),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lightp),
                      ),
                    ),
                    onChanged: (value) => password = value,
                    validator: (value) =>
                        value == null || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightp,
                        foregroundColor: mint,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _signIn();
                        }
                      },
                      child: const Text('Sign In'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
