import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/isar_user_repository.dart';
import '../../main.dart';

// Provider para el repositorio (depende de que Isar esté listo)
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarUserRepository(isar);
});

// Estado para la búsqueda
final userSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider para la lista de usuarios (reacciona a la búsqueda)
final userListProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final searchQuery = ref.watch(userSearchQueryProvider);
  
  return repository.getUsers(query: searchQuery);
});
