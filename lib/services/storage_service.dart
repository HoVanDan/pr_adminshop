import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadUserImage(File file, String userId) async {
    final fileName = path.basename(file.path);
    final ref = _storage.ref().child('user_images/$userId-$fileName');
    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();
    return url;
  }
}
