import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../pages/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  bool isLoading = false;
  String? errorMessage;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      await authService.value.createAccount(email: email, password: password);
      await authService.value.updateUsername(username: username);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context); // Go back or navigate as needed
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
        title: const Text('Register', style: TextStyle(color: Colors.white)),
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
                      labelText: 'Username',
                      labelStyle: TextStyle(color: darkp),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lightp),
                      ),
                    ),
                    onChanged: (value) => username = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter a username'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: darkp),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lightp),
                      ),
                    ),
                    onChanged: (value) => email = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter an email'
                        : null,
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
                    validator: (value) => value == null || value.length < 6
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
                          _register();
                        }
                      },
                      child: const Text('Register'),
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
