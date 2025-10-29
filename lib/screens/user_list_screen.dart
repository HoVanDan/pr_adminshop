import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';

class UserListScreen extends StatelessWidget {
  UserListScreen({super.key});
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final database = DatabaseService();
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddUserScreen())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: database.streamUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading users'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('No users found'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final username = data['username'] ?? '';
              final email = data['email'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: imageUrl != '' ? NetworkImage(imageUrl) : null,
                  child: imageUrl == '' ? const Icon(Icons.person) : null,
                ),
                title: Text(username),
                subtitle: Text(email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditUserScreen(userId: doc.id)));
                      },
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Confirm'),
                            content: const Text('Delete this user?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await database.deleteUser(doc.id);
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
