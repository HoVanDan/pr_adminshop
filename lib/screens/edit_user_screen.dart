import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  const EditUserScreen({super.key, required this.userId});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  File? _imageFile;
  String _imageUrl = '';
  final picker = ImagePicker();
  final db = DatabaseService();
  final storage = StorageService();

  bool _loading = false;
  bool _fetching = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final doc = await db.getUser(widget.userId);
      final data = doc.data() as Map<String, dynamic>;
      _username.text = data['username'] ?? '';
      _email.text = data['email'] ?? '';
      _password.text = data['password'] ?? '';
      _imageUrl = data['imageUrl'] ?? '';
    } catch (e) {
      // ignore
    } finally {
      setState(() { _fetching = false; });
    }
  }

  Future<void> _pickImage() async {
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() { _imageFile = File(picked.path); });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; });

    try {
      String newImageUrl = _imageUrl;
      if (_imageFile != null) {
        newImageUrl = await storage.uploadUserImage(_imageFile!, widget.userId);
      }

      await db.updateUser(widget.userId, {
        'username': _username.text.trim(),
        'email': _email.text.trim(),
        'password': _password.text.trim(),
        'imageUrl': newImageUrl,
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fetching) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : (_imageUrl != '' ? NetworkImage(_imageUrl) as ImageProvider : null),
              child: (_imageFile == null && _imageUrl == '') ? const Icon(Icons.person, size: 36) : null,
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(controller: _username, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => v==null||v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => v==null||v.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => v==null||v.length<4 ? 'Min 4 chars' : null),
              const SizedBox(height: 20),
              _loading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _save, child: const Text('Update')),
            ]),
          ),
        ]),
      ),
    );
  }
}
