import 'dart:math';
import 'package:flutter/material.dart';
import '../data/drink_dare_data.dart';

class DrinkDareScreen extends StatefulWidget {
  const DrinkDareScreen({super.key});

  @override
  State<DrinkDareScreen> createState() => _DrinkDareScreenState();
}

class _DrinkDareScreenState extends State<DrinkDareScreen> {
  final Random random = Random();

  String resultado = 'Pulsa girar para empezar';

  void girarRuleta() {
    setState(() {
      resultado =
      drinkDareOpciones[random.nextInt(drinkDareOpciones.length)];
    });
  }

  void reiniciarJuego() {
    setState(() {
      resultado = 'Pulsa girar para empezar';
    });
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Los jugadores se turnan para girar la ruleta.\n\n'
              'El resultado indica lo que debe hacer el jugador.\n\n'
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
        title: const Text('Drink & Dare'),
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
              resultado,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: girarRuleta,
              child: const Text('Girar'),
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