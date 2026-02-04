import 'package:isar/isar.dart';
import '../../domain/entities/user_entity.dart';
import 'address_model.dart';

part 'user_model.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;

  late String firstName;
  late String lastName;
  late DateTime birthDate;
  late String email;
  late String phone;

  final addresses = IsarLinks<AddressModel>();

  // Convert from Entity to Model
  static UserModel fromEntity(UserEntity entity) {
    final model = UserModel()
      ..firstName = entity.firstName
      ..lastName = entity.lastName
      ..birthDate = entity.birthDate
      ..email = entity.email
      ..phone = entity.phone;
    
    if (entity.id != null) {
      model.id = entity.id!;
    }
    
    return model;
  }

  // Convert from Model to Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      birthDate: birthDate,
      email: email,
      phone: phone,
      addresses: addresses.map((a) => a.toEntity()).toList(),
    );
  }
}
