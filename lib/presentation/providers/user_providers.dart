import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/isar_user_repository.dart';
import '../../main.dart';

// Provider para el repositorio
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Obtenemos la instancia de Isar. 
  // requireValue es seguro aquí porque la UI solo carga tras la inicialización.
  final isar = ref.watch(isarProvider).requireValue;
  return IsarUserRepository(isar);
});

// Estado para la búsqueda
final userSearchQueryProvider = StateProvider<String>((ref) => '');

// Provider para la lista de usuarios (reacciona a la búsqueda)
final userListProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final searchQuery = ref.watch(userSearchQueryProvider);
  
  final result = await repository.getUsers(query: searchQuery);
  
  // Usamos fold para manejar el Either
  return result.fold(
    // Lanzamos el objeto Failure completo. 
    // Riverpod lo capturará en el estado 'error' del AsyncValue.
    (failure) => throw failure,
    (users) => users,
  );
});
