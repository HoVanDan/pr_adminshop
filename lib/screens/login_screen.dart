import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'user_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() { _loading = true; });
    try {
      await authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => UserListScreen()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() { _loading = false; });
    }
  }

  // For testing: quick-create an admin account (only if needed)
  Future<void> _createTestAdmin() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'admin@example.com',
        password: 'admin123',
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin created: admin@example.com / admin123')));
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
              child: Text('Login', style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),),
          )),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _loading ? const CircularProgressIndicator() :
            ElevatedButton.icon(onPressed: _login, icon: const Icon(Icons.login), label: const Text('Login')),
            const SizedBox(height: 10),
            TextButton(onPressed: _createTestAdmin, child: const Text('Create test admin')),
            const SizedBox(height: 20),
            const Text('Use an admin account to manage users.'),
          ],
        ),
      ),
    );
  }
}
