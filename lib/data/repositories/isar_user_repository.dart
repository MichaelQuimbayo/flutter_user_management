import 'package:isar/isar.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/address_model.dart';
import '../models/user_model.dart';

class IsarUserRepository implements UserRepository {
  final Isar isar;

  IsarUserRepository(this.isar);

  @override
  Future<List<UserEntity>> getUsers({String? query}) async {
    final List<UserModel> models;
    
    if (query != null && query.isNotEmpty) {
      // Si hay búsqueda, aplicamos los filtros
      models = await isar.userModels
          .filter()
          .firstNameContains(query, caseSensitive: false)
          .or()
          .lastNameContains(query, caseSensitive: false)
          .findAll();
    } else {
      // Si no hay búsqueda, usamos .where() que sí permite findAll() directamente
      models = await isar.userModels.where().findAll();
    }
    
    // Cargar direcciones para cada modelo
    for (var model in models) {
      await model.addresses.load();
    }
    
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UserEntity?> getUserById(int id) async {
    final model = await isar.userModels.get(id);
    if (model == null) return null;
    await model.addresses.load();
    return model.toEntity();
  }

  @override
  Future<int> saveUser(UserEntity user) async {
    return await isar.writeTxn(() async {
      final model = UserModel.fromEntity(user);
      
      // Guardar el usuario
      final userId = await isar.userModels.put(model);
      
      // Manejar direcciones
      if (user.id != null) {
        final existing = await isar.userModels.get(user.id!);
        if (existing != null) {
          await existing.addresses.load();
          await isar.addressModels.deleteAll(existing.addresses.map((e) => e.id).toList());
        }
      }

      for (var addrEntity in user.addresses) {
        final addrModel = AddressModel.fromEntity(addrEntity);
        await isar.addressModels.put(addrModel);
        model.addresses.add(addrModel);
      }
      
      await model.addresses.save();
      return userId;
    });
  }

  @override
  Future<void> deleteUser(int id) async {
    await isar.writeTxn(() async {
      final model = await isar.userModels.get(id);
      if (model != null) {
        await model.addresses.load();
        await isar.addressModels.deleteAll(model.addresses.map((e) => e.id).toList());
        await isar.userModels.delete(id);
      }
    });
  }
}
