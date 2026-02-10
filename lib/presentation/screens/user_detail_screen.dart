import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/user_providers.dart';
import 'user_form_screen.dart';

class UserDetailScreen extends ConsumerWidget {
  final int userId;

  const UserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Detalle del Usuario'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar: $err')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          return _UserDetailView(user: user);
        },
      ),
    );
  }
}

class _UserDetailView extends StatelessWidget {
  final UserEntity user;

  const _UserDetailView({required this.user});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Header de Perfil
          Center(
            child: Column(
              children: [
                Hero(
                  tag: 'avatar_${user.id}',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 20),
                // Botones de Acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Editar',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Consumer(
                      builder: (context, ref, _) => _ActionButton(
                        icon: Icons.delete_outline,
                        label: 'Eliminar',
                        color: Colors.redAccent,
                        onPressed: () => _showDeleteConfirmation(context, ref, user.id!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Sección: Datos Personales
          _InfoCard(
            title: 'Datos Personales',
            icon: Icons.person_outline,
            children: [
              _InfoTile(icon: Icons.phone_outlined, label: 'Teléfono', value: user.phone),
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Edad',
                value: '${DateFormat.yMMMd().format(user.birthDate)} (${user.age} años)',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sección: Direcciones
          _InfoCard(
            title: 'Direcciones',
            icon: Icons.location_on_outlined,
            children: user.addresses.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay direcciones registradas.', style: TextStyle(color: Colors.grey)),
                    )
                  ]
                : user.addresses.map((addr) => _AddressTile(addr: addr)).toList(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar usuario?'),
        content: const Text('Esta acción borrará permanentemente al usuario y sus direcciones.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
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
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressEntity addr;
  const _AddressTile({required this.addr});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(
            addr.isPrimary ? Icons.star : Icons.circle,
            size: 12,
            color: addr.isPrimary ? Colors.orange : colorScheme.outlineVariant,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${addr.street}, ${addr.neighborhood}', style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('${addr.city}, ${addr.state} - ${addr.zipCode}', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              addr.label.name[0].toUpperCase() + addr.label.name.substring(1),
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color ?? colorScheme.primary),
      label: Text(label, style: TextStyle(color: color ?? colorScheme.primary)),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: color?.withOpacity(0.5) ?? colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
