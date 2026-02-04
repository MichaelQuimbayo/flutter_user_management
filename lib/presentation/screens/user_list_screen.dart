import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_providers.dart';
import '../widgets/user_list_item.dart';
import 'user_form_screen.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (query) {
                ref.read(userSearchQueryProvider.notifier).state = query;
              },
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o apellido...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: usuariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text('Error al cargar usuarios: $err', textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron usuarios.\n¡Agrega uno nuevo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return UserListItem(usuario: usuario);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
        },
        label: const Text('Añadir Usuario'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
