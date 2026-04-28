import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/ping_pong_data.dart';

class PingPongScreen extends StatefulWidget {
  const PingPongScreen({super.key});

  @override
  State<PingPongScreen> createState() => _PingPongScreenState();
}
ButtonStyle mainButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF005C),
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}

ButtonStyle stopButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF7A00),
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}

ButtonStyle secondaryButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: BorderSide(color: Colors.white.withOpacity(0.20)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );
}
class _PingPongScreenState extends State<PingPongScreen> {
  final Random random = Random();

  String preguntaActual = 'Pulsa empezar para jugar';
  String castigoActual = '';
  int tiempoRestante = 10;
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
      tiempoRestante = 10;
    });

    iniciarTemporizador();
  }

  void siguientePregunta() {
    timer?.cancel();

    setState(() {
      castigoActual = '';
      preguntaActual =
      preguntasPingPong[random.nextInt(preguntasPingPong.length)];
      tiempoRestante = 10;
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
      tiempoRestante = 10;
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
      backgroundColor: const Color(0xFF180027),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF005C),
                Color(0xFF7C2D12),
                Color(0xFF180027),
                Color(0xFF08051A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [

              /// DECORACIÓN FONDO

              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              Positioned(
                bottom: -90,
                right: -70,
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent.withOpacity(0.10),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [

                      /// TOP BAR

                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.home_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Text(
                              'Ping Pong',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              onPressed: mostrarNormas,
                              icon: const Icon(
                                Icons.help_outline_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// PREGUNTA (CARD GRANDE)

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            preguntaActual,
                            key: ValueKey(preguntaActual),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      /// TEMPORIZADOR CIRCULAR

                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.35),
                              blurRadius: 30,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$tiempoRestante',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// CASTIGO

                      if (castigoActual.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.35),
                            ),
                          ),
                          child: Text(
                            castigoActual,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),

                      const Spacer(),

                      /// BOTONES

                      Row(
                        children: [

                          /// EMPEZAR

                          Expanded(
                            child: ElevatedButton(
                              onPressed: empezarRonda,
                              style: mainButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'EMPEZAR',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// SIGUIENTE

                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                              juegoIniciado ? siguientePregunta : null,
                              style: mainButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'SIGUIENTE',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          /// CASTIGO

                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                              juegoIniciado ? sacarCastigo : null,
                              style: stopButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'CASTIGO',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// REINICIAR

                          Expanded(
                            child: OutlinedButton(
                              onPressed: reiniciarJuego,
                              style: secondaryButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'REINICIAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}