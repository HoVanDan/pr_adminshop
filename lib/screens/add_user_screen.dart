import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});
  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  final db = DatabaseService();
  final storage = StorageService();

  bool _loading = false;

  // Future<void> _pickImage() async {
  //   final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  //   if (picked != null) {
  //     setState(() { _image = File(picked.path); });
  //   }
  // }
  //
  // Future<void> _takePhoto() async {
  //   final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
  //   if (picked != null) {
  //     setState(() { _image = File(picked.path); });
  //   }
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; });

    try {
      final id =  Uuid().v4();
      String imageUrl = '';
      if (_image != null) {
        imageUrl = await storage.uploadUserImage(_image!, id);
      }

      final user = UserModel(
        id: id,
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        imageUrl: imageUrl,
      );

      await db.addUser(user);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => SafeArea(
                child: Wrap(children: [
                  ListTile(leading: const Icon(Icons.photo), title: const Text('Choose from gallery'), onTap: () {
                    // Navigator.pop(context); _pickImage();
                  }),
                  ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take photo'), onTap: () {
                    // Navigator.pop(context); _takePhoto();
                  }),
                ]),
              ),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null ? const Icon(Icons.add_a_photo, size: 36) : null,
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
              _loading ? const CircularProgressIndicator() :
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ]),
          ),
        ]),
      ),
    );
  }
}
