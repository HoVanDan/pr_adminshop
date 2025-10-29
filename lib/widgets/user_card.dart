import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String username;
  final String email;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.username,
    required this.email,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: imageUrl != '' ? NetworkImage(imageUrl) : null,
          child: imageUrl == '' ? const Icon(Icons.person) : null,
        ),
        title: Text(username),
        subtitle: Text(email),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ]),
      ),
    );
  }
}
