import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'data/models/address_model.dart';
import 'data/models/user_model.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/user_list_screen.dart';

// Provider for Isar instance
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  
  if (Isar.instanceNames.isEmpty) {
    return await Isar.open(
      [UserModelSchema, AddressModelSchema],
      directory: dir.path,
      inspector: true, // Enable inspector for debugging
    );
  }
  return Isar.getInstance()!;
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isarAsyncValue = ref.watch(isarProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'User Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: isarAsyncValue.when(
        data: (isar) => const UserListScreen(), // Pantalla de inicio
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error al cargar Isar: $err'))),
      ),
    );
  }
}
