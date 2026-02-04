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
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, color: Color(0xFF2D3243)),
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Enter $label',
          labelStyle: const TextStyle(
            color: Color(0xFF707E94),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(color: Colors.black26),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF707E94)) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          
          // Borde redondeado sutil
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
