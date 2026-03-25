import 'dart:math';
import 'package:flutter/material.dart';
import '../data/prueba_verdad_data.dart';

class PruebaVerdadScreen extends StatefulWidget {
  const PruebaVerdadScreen({super.key});

  @override
  State<PruebaVerdadScreen> createState() => _PruebaVerdadScreenState();
}

class _PruebaVerdadScreenState extends State<PruebaVerdadScreen> {
  final Random random = Random();

  String textoActual = 'Elige Verdad o Prueba';
  String tipoActual = '';

  void sacarVerdad() {
    setState(() {
      tipoActual = 'Verdad';
      textoActual =
      preguntasVerdad[random.nextInt(preguntasVerdad.length)];
    });
  }

  void sacarPrueba() {
    setState(() {
      tipoActual = 'Prueba';
      textoActual = pruebas[random.nextInt(pruebas.length)];
    });
  }

  void reiniciarJuego() {
    setState(() {
      tipoActual = '';
      textoActual = 'Elige Verdad o Prueba';
    });
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Un jugador elige entre verdad o prueba.\n\n'
              'Si elige verdad, debe responder sinceramente.\n\n'
              'Si elige prueba, debe hacer el reto.\n\n'
              'Si no quiere hacerlo, bebe.',
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
        title: const Text('Prueba o Verdad'),
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
            const SizedBox(height: 30),

            if (tipoActual.isNotEmpty)
              Text(
                tipoActual,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            Text(
              textoActual,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: sacarVerdad,
              child: const Text('Verdad'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: sacarPrueba,
              child: const Text('Prueba'),
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