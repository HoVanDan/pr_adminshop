import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final CollectionReference usersRef =
  FirebaseFirestore.instance.collection('users');

  Future<String> addUser(UserModel user) async {
    final docRef = await usersRef.add(user.toMap());
    return docRef.id;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await usersRef.doc(id).update(data);
  }

  Future<void> deleteUser(String id) async {
    await usersRef.doc(id).delete();
  }

  Stream<QuerySnapshot> streamUsers() {
    return usersRef.snapshots();
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await usersRef.doc(id).get();
  }
}
