import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/user_providers.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends ConsumerWidget {
  final UserEntity user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Usuario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref, user.id!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(Icons.person, 'Información Personal'),
            _buildDetailTile('Nombre Completo', '${user.firstName} ${user.lastName}'),
            _buildDetailTile('Email', user.email),
            _buildDetailTile('Teléfono', user.phone),
            _buildDetailTile(
              'Fecha de Nacimiento', 
              '${DateFormat.yMMMd().format(user.birthDate)} (${user.age} años)'
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionHeader(Icons.location_on, 'Direcciones'),
            if (user.addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No hay direcciones registradas.', style: TextStyle(color: Colors.grey)),
              )
            else
              ...user.addresses.map((addr) => _buildAddressCard(addr)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este usuario? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final repo = ref.read(userRepositoryProvider);
              await repo.deleteUser(userId);
              ref.invalidate(userListProvider); 
              Navigator.of(ctx).pop(); 
              Navigator.of(context).pop(); 
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity addr) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          addr.isPrimary ? Icons.star : Icons.location_on_outlined,
          color: addr.isPrimary ? Colors.orange : Colors.blue,
        ),
        title: Text(addr.street),
        subtitle: Text('${addr.neighborhood}, ${addr.city}, ${addr.state} ${addr.zipCode}'),
        trailing: Chip(
          label: Text(
            addr.label.name.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }
}
