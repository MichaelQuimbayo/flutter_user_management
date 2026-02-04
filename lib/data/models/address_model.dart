import 'package:isar/isar.dart';
import '../../domain/entities/address_entity.dart';

part 'address_model.g.dart';

@collection
class AddressModel {
  Id id = Isar.autoIncrement;

  late String street;
  late String neighborhood;
  late String city;
  late String state;
  late String zipCode;
  
  @enumerated
  late AddressLabel label;
  
  late bool isPrimary;

  // Convert from Entity to Model
  static AddressModel fromEntity(AddressEntity entity) {
    return AddressModel()
      ..street = entity.street
      ..neighborhood = entity.neighborhood
      ..city = entity.city
      ..state = entity.state
      ..zipCode = entity.zipCode
      ..label = entity.label
      ..isPrimary = entity.isPrimary;
  }

  // Convert from Model to Entity
  AddressEntity toEntity() {
    return AddressEntity(
      id: id.toString(),
      street: street,
      neighborhood: neighborhood,
      city: city,
      state: state,
      zipCode: zipCode,
      label: label,
      isPrimary: isPrimary,
    );
  }
}
