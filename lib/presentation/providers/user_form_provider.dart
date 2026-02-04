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
            birthDate: DateTime.now(),
            email: '',
            phone: '',
            addresses: [],
          ),
          isEditing: initialUser != null,
        ));

  void updateField(UserEntity newUser) {
    state = state.copyWith(user: newUser, clearError: true);
  }

  // --- Gestión de Direcciones ---

  void addAddress(AddressEntity address) {
    final updatedAddresses = List<AddressEntity>.from(state.user.addresses)..add(address);
    
    // Si es la primera dirección o se marca como principal, ajustamos las demás
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
      // Si la nueva es principal, desmarcamos las demás
      final synced = addresses.map((a) {
        if (a.id == addresses.last.id) return a;
        return a.copyWith(isPrimary: false);
      }).toList();
      state = state.copyWith(user: state.user.copyWith(addresses: synced));
    } else {
      // Si ninguna es principal, la primera lo será por defecto
      if (addresses.isNotEmpty && !addresses.any((a) => a.isPrimary)) {
        addresses[0] = addresses[0].copyWith(isPrimary: true);
      }
      state = state.copyWith(user: state.user.copyWith(addresses: addresses));
    }
  }

  // --- Guardado ---

  Future<bool> saveUser() async {
    if (state.user.firstName.length < 2) {
      state = state.copyWith(errorMessage: 'El nombre debe tener al menos 2 caracteres.');
      return false;
    }
    if (state.user.lastName.length < 2) {
      state = state.copyWith(errorMessage: 'El apellido debe tener al menos 2 caracteres.');
      return false;
    }
    if (!state.user.isValidAge) {
      state = state.copyWith(errorMessage: 'La edad debe estar entre 18 y 100 años.');
      return false;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(state.user.email)) {
      state = state.copyWith(errorMessage: 'El formato del email no es válido.');
      return false;
    }
    if (state.user.phone.isEmpty) {
      state = state.copyWith(errorMessage: 'El teléfono es requerido.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repository = ref.read(userRepositoryProvider);
      await repository.saveUser(state.user);
      ref.invalidate(userListProvider);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Error al guardar: $e');
      return false;
    }
  }
}

final userFormProvider = StateNotifierProvider.family<UserFormNotifier, UserFormState, UserEntity?>((ref, user) {
  return UserFormNotifier(ref, user);
});
