import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_user/presentation/screens/user_list_screen.dart';
import 'package:flutter_user/presentation/providers/user_providers.dart';
import 'package:flutter_user/domain/repositories/user_repository.dart';
import 'package:flutter_user/domain/entities/user_entity.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  testWidgets('debe mostrar mensaje cuando la lista está vacía', (tester) async {
    when(() => mockUserRepository.getUsers(query: any(named: 'query')))
        .thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
        child: const MaterialApp(home: UserListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No se encontraron usuarios.\n¡Agrega uno nuevo!'), findsOneWidget);
  });

  testWidgets('debe mostrar la lista de usuarios cuando hay datos', (tester) async {
    final usuarios = [
      UserEntity(
        id: 1,
        firstName: 'Michael',
        lastName: 'Test',
        birthDate: DateTime(1990, 1, 1),
        email: 'michael@test.com',
        phone: '123456',
      ),
    ];

    when(() => mockUserRepository.getUsers(query: any(named: 'query')))
        .thenAnswer((_) async => Right(usuarios));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
        child: const MaterialApp(home: UserListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Michael Test'), findsOneWidget);
    expect(find.text('michael@test.com'), findsOneWidget);
  });
}
