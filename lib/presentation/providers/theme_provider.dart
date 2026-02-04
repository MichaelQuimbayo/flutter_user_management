import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider que maneja el modo de tema (Light/Dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
