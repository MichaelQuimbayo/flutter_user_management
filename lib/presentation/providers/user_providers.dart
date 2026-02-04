import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/isar_user_repository.dart';
import '../../main.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final isar = ref.watch(isarProvider).requireValue;
  return IsarUserRepository(isar);
});

final userSearchQueryProvider = StateProvider<String>((ref) => '');

final userListProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final searchQuery = ref.watch(userSearchQueryProvider);
  
  final result = await repository.getUsers(query: searchQuery);
  
  return result.fold(
    (failure) => throw failure,
    (users) => users,
  );
});

// NUEVO: Provider para observar un único usuario por su ID
final userByIdProvider = FutureProvider.family.autoDispose<UserEntity?, int>((ref, id) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getUserById(id);
  
  return result.fold(
    (failure) => throw failure,
    (user) => user,
  );
});
