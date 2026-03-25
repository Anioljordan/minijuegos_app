import 'dart:math';
import 'package:flutter/material.dart';
import '../data/piccolo_data.dart';

class PiccoloScreen extends StatefulWidget {
  const PiccoloScreen({super.key});

  @override
  State<PiccoloScreen> createState() => _PiccoloScreenState();
}

class _PiccoloScreenState extends State<PiccoloScreen> {
  final Random random = Random();
  String fraseActual = 'Pulsa el botón para empezar';

  void siguienteFrase() {
    setState(() {
      fraseActual = piccoloFrases[random.nextInt(piccoloFrases.length)];
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
          'Lee la frase en voz alta. Todos señalan a una persona del grupo. '
              'La persona más señalada bebe. Después pasáis a la siguiente frase.',
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
        title: const Text('Piccolo'),
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