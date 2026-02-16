import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/admin/database_check_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SafeCareApp());
}

class SafeCareApp extends StatelessWidget {
  const SafeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeCare',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const RoleSelectionScreen(),
      routes: {
        '/database-check': (context) => const DatabaseCheckScreen(),
      },
    );
  }
}
