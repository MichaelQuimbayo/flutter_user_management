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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
