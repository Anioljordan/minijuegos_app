import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MiniJuegosApp());
}

class MiniJuegosApp extends StatelessWidget {
  const MiniJuegosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MiniJuegos',
      home: const HomeScreen(),
    );
  }
}