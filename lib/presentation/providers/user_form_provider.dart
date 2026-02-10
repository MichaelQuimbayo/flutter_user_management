import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/address_entity.dart';
import 'user_providers.dart';

class UserFormState {
  final UserEntity user;
  final bool isEditing;
  final bool isSaving;
  final String? errorMessage;

  UserFormState({
    required this.user,
    this.isEditing = false,
    this.isSaving = false,
    this.errorMessage,
  });

  UserFormState copyWith({
    UserEntity? user,
    bool? isEditing,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserFormState(
      user: user ?? this.user,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class UserFormNotifier extends StateNotifier<UserFormState> {
  final Ref ref;

  UserFormNotifier(this.ref, [UserEntity? initialUser])
      : super(UserFormState(
          user: initialUser ?? UserEntity(
            firstName: '',
            lastName: '',
            birthDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
            email: '',
            phone: '',
            addresses: [],
          ),
          isEditing: initialUser != null,
        ));

  void updateField(UserEntity newUser) {
    state = state.copyWith(user: newUser, clearError: true);
  }

  void addAddress(AddressEntity address) {
    final updatedAddresses = List<AddressEntity>.from(state.user.addresses)..add(address);
    _syncAddresses(updatedAddresses, address.isPrimary);
  }

  void removeAddress(String id) {
    final updatedAddresses = state.user.addresses.where((a) => a.id != id).toList();
    state = state.copyWith(user: state.user.copyWith(addresses: updatedAddresses));
  }

  void setPrimaryAddress(String id) {
    final updatedAddresses = state.user.addresses.map((a) {
      return a.copyWith(isPrimary: a.id == id);
    }).toList();
    state = state.copyWith(user: state.user.copyWith(addresses: updatedAddresses));
  }

  void _syncAddresses(List<AddressEntity> addresses, bool newIsPrimary) {
    if (newIsPrimary) {
      final synced = addresses.map((a) {
        if (addresses.isNotEmpty && a.id == addresses.last.id) return a;
        return a.copyWith(isPrimary: false);
      }).toList();
      state = state.copyWith(user: state.user.copyWith(addresses: synced));
    } else {
      if (addresses.isNotEmpty && !addresses.any((a) => a.isPrimary)) {
        addresses[0] = addresses[0].copyWith(isPrimary: true);
      }
      state = state.copyWith(user: state.user.copyWith(addresses: addresses));
    }
  }

  Future<bool> saveUser() async {
    if (state.user.firstName.trim().length < 2) {
      state = state.copyWith(errorMessage: 'El nombre debe tener al menos 2 caracteres.');
      return false;
    }
    if (state.user.lastName.trim().length < 2) {
      state = state.copyWith(errorMessage: 'El apellido debe tener al menos 2 caracteres.');
      return false;
    }
    if (!state.user.isValidAge) {
      state = state.copyWith(errorMessage: 'Edad inválida. Debe tener entre 18 y 100 años.');
      return false;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(state.user.email)) {
      state = state.copyWith(errorMessage: 'Ingrese un correo electrónico válido.');
      return false;
    }

    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(state.user.phone.replaceAll(RegExp(r'\D'), ''))) {
      state = state.copyWith(errorMessage: 'El teléfono debe contener 10 dígitos.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.saveUser(state.user);

    return result.fold(
      (failure) {
        state = state.copyWith(isSaving: false, errorMessage: failure.message);
        return false;
      },
      (userId) {
        ref.invalidate(userListProvider);
        // NUEVO: Invalidar el detalle de este usuario específico para forzar recarga
        ref.invalidate(userByIdProvider(userId));
        state = state.copyWith(isSaving: false);
        return true;
      },
    );
  }
}

final userFormProvider = StateNotifierProvider.autoDispose.family<UserFormNotifier, UserFormState, UserEntity?>((ref, user) {
  return UserFormNotifier(ref, user);
});
