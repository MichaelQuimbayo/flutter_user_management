import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/address_entity.dart';
import 'custom_text_form_field.dart';

class AddressFormModal extends StatefulWidget {
  final Function(AddressEntity) onSave;

  const AddressFormModal({super.key, required this.onSave});

  @override
  State<AddressFormModal> createState() => _AddressFormModalState();
}

class _AddressFormModalState extends State<AddressFormModal> {
  final _formKey = GlobalKey<FormState>();
  
  String street = '';
  String neighborhood = '';
  String city = '';
  String state = '';
  String zipCode = '';
  AddressLabel label = AddressLabel.home;
  bool isPrimary = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nueva Dirección',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Calle y Número',
                onChanged: (v) => street = v,
                icon: Icons.location_on_outlined,
              ),
              CustomTextFormField(
                label: 'Colonia/Barrio',
                onChanged: (v) => neighborhood = v,
                icon: Icons.map_outlined,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      label: 'Ciudad',
                      onChanged: (v) => city = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomTextFormField(
                      label: 'Estado',
                      onChanged: (v) => state = v,
                    ),
                  ),
                ],
              ),
              CustomTextFormField(
                label: 'Código Postal',
                onChanged: (v) => zipCode = v,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<AddressLabel>(
                value: label,
                decoration: const InputDecoration(
                  labelText: 'Etiqueta',
                  border: OutlineInputBorder(),
                ),
                items: AddressLabel.values.map((l) {
                  return DropdownMenuItem(
                    value: l,
                    child: Text(l.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => label = v!),
              ),
              SwitchListTile(
                title: const Text('Dirección Principal'),
                value: isPrimary,
                onChanged: (v) => setState(() => isPrimary = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (street.isEmpty || city.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor completa los campos básicos')),
                    );
                    return;
                  }
                  
                  final newAddress = AddressEntity(
                    id: const Uuid().v4(), // Generamos un ID temporal
                    street: street,
                    neighborhood: neighborhood,
                    city: city,
                    state: state,
                    zipCode: zipCode,
                    label: label,
                    isPrimary: isPrimary,
                  );
                  
                  widget.onSave(newAddress);
                  Navigator.pop(context);
                },
                child: const Text('Añadir Dirección'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
