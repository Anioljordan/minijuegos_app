import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/ping_pong_data.dart';

class PingPongScreen extends StatefulWidget {
  const PingPongScreen({super.key});

  @override
  State<PingPongScreen> createState() => _PingPongScreenState();
}

class _PingPongScreenState extends State<PingPongScreen> {
  final Random random = Random();

  String preguntaActual = 'Pulsa empezar para jugar';
  String castigoActual = '';
  int tiempoRestante = 5;
  Timer? timer;
  bool juegoIniciado = false;

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Se lee la pregunta en voz alta.\n\n'
              'El jugador debe responder antes de que se acabe el tiempo.\n\n'
              'Si falla, duda o no responde a tiempo, recibe un castigo.',
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

  void empezarRonda() {
    setState(() {
      juegoIniciado = true;
      castigoActual = '';
      preguntaActual =
      preguntasPingPong[random.nextInt(preguntasPingPong.length)];
      tiempoRestante = 5;
    });

    iniciarTemporizador();
  }

  void siguientePregunta() {
    timer?.cancel();

    setState(() {
      castigoActual = '';
      preguntaActual =
      preguntasPingPong[random.nextInt(preguntasPingPong.length)];
      tiempoRestante = 5;
    });

    iniciarTemporizador();
  }

  void iniciarTemporizador() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (tiempoRestante > 1) {
        setState(() {
          tiempoRestante--;
        });
      } else {
        timer.cancel();
        setState(() {
          tiempoRestante = 0;
        });
      }
    });
  }

  void sacarCastigo() {
    setState(() {
      castigoActual =
      castigosPingPong[random.nextInt(castigosPingPong.length)];
    });
  }

  void reiniciarJuego() {
    timer?.cancel();

    setState(() {
      juegoIniciado = false;
      preguntaActual = 'Pulsa empezar para jugar';
      castigoActual = '';
      tiempoRestante = 5;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ping Pong'),
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

            Text(
              preguntaActual,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Tiempo: $tiempoRestante',
              style: const TextStyle(
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 24),

            if (castigoActual.isNotEmpty)
              Text(
                castigoActual,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: empezarRonda,
              child: const Text('Empezar'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: juegoIniciado ? siguientePregunta : null,
              child: const Text('Siguiente pregunta'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: juegoIniciado ? sacarCastigo : null,
              child: const Text('Castigo'),
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