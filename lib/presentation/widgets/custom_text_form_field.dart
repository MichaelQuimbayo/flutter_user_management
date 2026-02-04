import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final IconData? icon;
  final void Function(String) onChanged;
  final TextInputType? keyboardType;
  final bool readOnly;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue,
    this.icon,
    required this.onChanged,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    // Obtenemos los colores del tema actual para que sean adaptables
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        keyboardType: keyboardType,
        // Eliminamos el color fijo para que use el color de texto del tema (blanco en dark, negro en light)
        style: const TextStyle(fontSize: 16), 
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Ingrese $label',
          // Usamos colores del esquema del tema
          labelStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: icon != null ? Icon(icon, color: colorScheme.primary) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          
          // Nota: Los bordes ya están definidos globalmente en AppTheme, 
          // pero los dejamos aquí para asegurar la consistencia del radio de 16.0.
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
