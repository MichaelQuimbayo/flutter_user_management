import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_user/domain/repositories/user_repository.dart';
import 'package:flutter_user/domain/entities/user_entity.dart';
import 'package:flutter_user/presentation/providers/user_form_provider.dart';
import 'package:flutter_user/presentation/providers/user_providers.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    // Configuración para que el mock siempre devuelva éxito por defecto
    when(() => mockUserRepository.saveUser(any())).thenAnswer((_) async => const Right(1));
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  }

  group('UserFormNotifier', () {
    test('saveUser debe fallar si el nombre es muy corto', () async {
      final container = createContainer();
      final notifier = container.read(userFormProvider(null).notifier);

      // Actualizar el estado con un nombre inválido
      final invalidUser = UserEntity(
        firstName: 'J', // inválido
        lastName: 'Doe',
        birthDate: DateTime(1990, 1, 1),
        email: 'john.doe@example.com',
        phone: '1234567890',
      );
      notifier.updateField(invalidUser);

      final result = await notifier.saveUser();

      expect(result, isFalse);
      expect(container.read(userFormProvider(null)).errorMessage, isNotNull);
      expect(container.read(userFormProvider(null)).errorMessage, contains('nombre'));
    });

    test('saveUser debe llamar al repositorio si los datos son válidos', () async {
      final container = createContainer();
      final notifier = container.read(userFormProvider(null).notifier);

      final validUser = UserEntity(
        firstName: 'John',
        lastName: 'Doe',
        birthDate: DateTime(1990, 1, 1),
        email: 'john.doe@example.com',
        phone: '1234567890',
      );
      notifier.updateField(validUser);

      final result = await notifier.saveUser();

      expect(result, isTrue);
      verify(() => mockUserRepository.saveUser(any())).called(1);
      expect(container.read(userFormProvider(null)).errorMessage, isNull);
    });
  });
}
