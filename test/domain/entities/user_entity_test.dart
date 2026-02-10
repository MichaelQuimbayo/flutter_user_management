import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_user/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('debe calcular la edad correctamente', () {
      final dob = DateTime(2000, 1, 1);
      final user = UserEntity(
        firstName: 'John',
        lastName: 'Doe',
        birthDate: dob,
        email: 'john@example.com',
        phone: '123456789',
      );

      // Calculamos la edad esperada dinámicamente
      final now = DateTime.now();
      int expectedAge = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        expectedAge--;
      }

      expect(user.age, expectedAge);
    });

    test('debe validar edad entre 18 y 100 años correctamente', () {
      final now = DateTime.now();
      
      final youngUser = UserEntity(
        firstName: 'Young',
        lastName: 'User',
        birthDate: DateTime(now.year - 17, now.month, now.day),
        email: 'young@test.com',
        phone: '123',
      );
      
      final validUser = UserEntity(
        firstName: 'Valid',
        lastName: 'User',
        birthDate: DateTime(now.year - 25, now.month, now.day),
        email: 'valid@test.com',
        phone: '123',
      );

      final oldUser = UserEntity(
        firstName: 'Old',
        lastName: 'User',
        birthDate: DateTime(now.year - 101, now.month, now.day),
        email: 'old@test.com',
        phone: '123',
      );

      expect(youngUser.isValidAge, isFalse);
      expect(validUser.isValidAge, isTrue);
      expect(oldUser.isValidAge, isFalse);
    });
  });
}
