import 'address_entity.dart';

class UserEntity {
  final int? id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String email;
  final String phone;
  final List<AddressEntity> addresses;

  UserEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phone,
    this.addresses = const [],
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get isValidAge => age >= 18 && age <= 100;

  UserEntity copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? email,
    String? phone,
    List<AddressEntity>? addresses,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addresses: addresses ?? this.addresses,
    );
  }
}
