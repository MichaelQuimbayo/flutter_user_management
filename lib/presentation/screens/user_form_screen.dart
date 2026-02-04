import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/user_form_provider.dart';
import '../widgets/custom_text_form_field.dart';
import '../widgets/address_form_modal.dart';

class UserFormScreen extends ConsumerWidget {
  final UserEntity? user;

  const UserFormScreen({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formProvider = userFormProvider(user);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);

    // Escuchamos los cambios de estado para efectos secundarios (navegación y mensajes)
    ref.listen(formProvider, (previous, next) {
      // 1. Manejo de Errores
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 2. Manejo de Éxito (Cuando deja de guardar y no hay error)
      if (!next.isSaving && (previous?.isSaving ?? false) && next.errorMessage == null) {
        final isEditing = previous?.isEditing ?? false;
        
        // Mostramos el SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(isEditing 
                  ? 'Usuario actualizado con éxito' 
                  : 'Usuario creado con éxito'
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        // Regresamos a la pantalla anterior
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(formState.isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información Personal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextFormField(
              label: 'Nombre',
              initialValue: formState.user.firstName,
              onChanged: (v) => formNotifier.updateField(formState.user.copyWith(firstName: v)),
            ),
            CustomTextFormField(
              label: 'Apellido',
              initialValue: formState.user.lastName,
              onChanged: (v) => formNotifier.updateField(formState.user.copyWith(lastName: v)),
            ),
            CustomTextFormField(
              label: 'Email',
              initialValue: formState.user.email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => formNotifier.updateField(formState.user.copyWith(email: v)),
            ),
            CustomTextFormField(
              label: 'Teléfono',
              initialValue: formState.user.phone,
              keyboardType: TextInputType.phone,
              onChanged: (v) => formNotifier.updateField(formState.user.copyWith(phone: v)),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: formState.user.birthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) formNotifier.updateField(formState.user.copyWith(birthDate: date));
                },
                borderRadius: BorderRadius.circular(16.0),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha de Nacimiento',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(formState.user.birthDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Direcciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AddressFormModal(onSave: formNotifier.addAddress),
                    );
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Añadir'),
                ),
              ],
            ),

            if (formState.user.addresses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No hay direcciones añadidas', style: TextStyle(color: Colors.grey))),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: formState.user.addresses.length,
                itemBuilder: (context, index) {
                  final addr = formState.user.addresses[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(
                        addr.isPrimary ? Icons.star : Icons.location_on,
                        color: addr.isPrimary ? Colors.orange : Colors.blue,
                      ),
                      title: Text(addr.street),
                      subtitle: Text('${addr.neighborhood}, ${addr.city}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => formNotifier.removeAddress(addr.id),
                      ),
                      onTap: () => formNotifier.setPrimaryAddress(addr.id),
                    ),
                  );
                },
              ),

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: formState.isSaving ? null : formNotifier.saveUser,
              child: formState.isSaving 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                  ) 
                : const Text('Guardar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
