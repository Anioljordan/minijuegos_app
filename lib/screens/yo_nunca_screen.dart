import 'dart:math';
import 'package:flutter/material.dart';
import '../data/yo_nunca_data.dart';

class YoNuncaScreen extends StatefulWidget {
  const YoNuncaScreen({super.key});

  @override
  State<YoNuncaScreen> createState() => _YoNuncaScreenState();
}

class _YoNuncaScreenState extends State<YoNuncaScreen> {
  final Random random = Random();
  String fraseActual = 'Pulsa el botón para empezar';

  void siguienteFrase() {
    setState(() {
      fraseActual = yoNuncaFrases[random.nextInt(yoNuncaFrases.length)];
    });
  }

  void reiniciarJuego() {
    setState(() {
      fraseActual = 'Pulsa el botón para empezar';
    });
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Se lee la frase en voz alta. '
              'Las personas que sí lo hayan hecho, beben. '
              'Después se pasa a la siguiente frase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yo Nunca Nunca'),
        actions: [
          IconButton(
            onPressed: mostrarNormas,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              fraseActual,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: siguienteFrase,
              child: const Text('Siguiente'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: reiniciarJuego,
              child: const Text('Reiniciar'),
            ),
          ],
        ),
      ),
    );
  }
}