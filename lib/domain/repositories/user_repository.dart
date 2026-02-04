import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers({String? query});
  Future<UserEntity?> getUserById(int id);
  Future<int> saveUser(UserEntity user);
  Future<void> deleteUser(int id);
}
