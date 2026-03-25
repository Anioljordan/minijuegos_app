import 'dart:math';
import 'package:flutter/material.dart';
import '../data/uno_dos_data.dart';

class UnoDosScreen extends StatefulWidget {
  const UnoDosScreen({super.key});

  @override
  State<UnoDosScreen> createState() => _UnoDosScreenState();
}

class _UnoDosScreenState extends State<UnoDosScreen> {
  final Random random = Random();
  String accionActual = 'Pulsa el botón para empezar';

  void siguienteAccion() {
    setState(() {
      accionActual =
      unoDosAcciones[random.nextInt(unoDosAcciones.length)];
    });
  }

  void reiniciarJuego() {
    setState(() {
      accionActual = 'Pulsa el botón para empezar';
    });
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Se eligen dos jugadores: el número 1 y el número 2.\n\n'
              'Lee la acción en voz alta y los jugadores deben cumplirla.\n\n'
              'Si alguien no quiere hacerlo, bebe.',
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
        title: const Text('1 y 2'),
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
              accionActual,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: siguienteAccion,
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