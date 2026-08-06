import 'package:flutter/material.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CovoiturageApp());
}

class CovoiturageApp extends StatelessWidget {
  const CovoiturageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covoiturage',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeShell(),
    );
  }
}
