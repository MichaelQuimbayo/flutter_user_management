enum AddressLabel { casa, trabajo, otro }

class AddressEntity {
  final String id;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String zipCode;
  final AddressLabel label;
  final bool isPrimary;

  AddressEntity({
    required this.id,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.label,
    this.isPrimary = false,
  });

  AddressEntity copyWith({
    String? id,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
    AddressLabel? label,
    bool? isPrimary,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      label: label ?? this.label,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
