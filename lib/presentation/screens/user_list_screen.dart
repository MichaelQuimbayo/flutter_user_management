import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_providers.dart';
import '../widgets/user_list_item.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
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
              ),
            ),
          ),
        ),
      ),
      body: usuariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error al cargar usuarios: $err'),
        ),
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                'No se encontraron usuarios.\n¡Agrega uno nuevo!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a la pantalla de creación/edición de usuario
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
