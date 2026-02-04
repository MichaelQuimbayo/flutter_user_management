import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../screens/user_form_screen.dart';

class UserListItem extends StatelessWidget {
  final UserEntity usuario;

  const UserListItem({
    super.key,
    required this.usuario,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            (usuario.firstName.isNotEmpty ? usuario.firstName[0] : '') + 
            (usuario.lastName.isNotEmpty ? usuario.lastName[0] : ''),
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text('${usuario.firstName} ${usuario.lastName}'),
        subtitle: Text(usuario.email),
        trailing: const Icon(Icons.edit_outlined, size: 20),
        onTap: () {
          // Navegar a la pantalla de edición pasando el usuario actual
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserFormScreen(user: usuario),
            ),
          );
        },
      ),
    );
  }
}
