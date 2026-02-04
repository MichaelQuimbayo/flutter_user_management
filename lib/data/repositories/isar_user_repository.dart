import 'package:dartz/dartz.dart';
import 'package:isar/isar.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class IsarUserRepository implements UserRepository {
  final Isar isar;

  IsarUserRepository(this.isar);

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({String? query}) async {
    try {
      final List<UserModel> models;
      if (query != null && query.isNotEmpty) {
        models = await isar.userModels
            .filter()
            .firstNameContains(query, caseSensitive: false)
            .or()
            .lastNameContains(query, caseSensitive: false)
            .findAll();
      } else {
        models = await isar.userModels.where().findAll();
      }
      for (var model in models) {
        await model.addresses.load();
      }
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener usuarios: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getUserById(int id) async {
    try {
      final model = await isar.userModels.get(id);
      if (model == null) return const Right(null);
      await model.addresses.load();
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> saveUser(UserEntity user) async {
    try {
      return await isar.writeTxn(() async {
        final userModel = UserModel.fromEntity(user);
        
        // Si es edición, limpiamos direcciones viejas para evitar duplicados
        if (user.id != null) {
          final existing = await isar.userModels.get(user.id!);
          if (existing != null) {
            await existing.addresses.load();
            await isar.addressModels.deleteAll(existing.addresses.map((e) => e.id).toList());
          }
        }

        // Guardar nuevas direcciones
        final addressModels = user.addresses.map(AddressModel.fromEntity).toList();
        await isar.addressModels.putAll(addressModels);
        
        // Vincular y guardar usuario
        userModel.addresses.addAll(addressModels);
        final userId = await isar.userModels.put(userModel);
        await userModel.addresses.save();
        
        return Right(userId);
      });
    } catch (e) {
      return Left(DatabaseFailure('Error al guardar usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await isar.writeTxn(() async {
        final user = await isar.userModels.get(id);
        if (user != null) {
          await user.addresses.load();
          // Borrar direcciones asociadas primero
          await isar.addressModels.deleteAll(user.addresses.map((addr) => addr.id).toList());
          await isar.userModels.delete(id);
        }
      });
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Error al eliminar usuario: $e'));
    }
  }
}
