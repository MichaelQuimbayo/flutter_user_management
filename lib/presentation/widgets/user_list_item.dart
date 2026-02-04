import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

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
          child: Text(usuario.firstName[0] + usuario.lastName[0]),
        ),
        title: Text('${usuario.firstName} ${usuario.lastName}'),
        subtitle: Text(usuario.email),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navegar al detalle del usuario
        },
      ),
    );
  }
}
