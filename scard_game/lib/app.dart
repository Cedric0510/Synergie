import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

class ScardApp extends StatelessWidget {
  const ScardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S\'Card - Jeu de Cartes Coquin',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
