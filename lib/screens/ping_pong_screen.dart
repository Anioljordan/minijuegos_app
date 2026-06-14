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

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentGreen = Color(0xFF22C55E);

  String preguntaActual = 'Pulsa empezar para jugar';
  String castigoActual = '';
  int tiempoRestante = 10;
  Timer? timer;
  bool juegoIniciado = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      mostrarNormas();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
      juegoIniciado = true;
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
      if (!mounted) {
        timer.cancel();
        return;
      }

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
    if (!juegoIniciado) return;

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

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentPink,
      foregroundColor: appWhite,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: appWhite,
      side: BorderSide(
        color: appWhite.withOpacity(0.70),
        width: 2,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appWhite.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              onTap: () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            circleButton(
              onTap: mostrarNormas,
              child: const Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'ping pong',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 48,
                      height: 2.00,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: 82,
                  left: 0,
                  right: -18,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoBar() {
    String text;

    if (!juegoIniciado) {
      text = 'Pulsa empezar y responde antes de que acabe el tiempo';
    } else if (tiempoRestante == 0) {
      text = 'Tiempo terminado. Si ha fallado, pulsa castigo';
    } else {
      text = 'Responde rápido. Si duda o falla, recibe castigo';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: tiempoRestante == 0 ? accentPink : accentYellow,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.26),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: appWhite,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.72),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.75),
              width: 2.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appWhite.withOpacity(0.85),
                            width: 2.1,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          color: appWhite,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'normas',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 38,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'PING PONG',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.play_arrow_rounded,
                    title: 'Empieza la ronda',
                    text:
                    'Pulsa EMPEZAR para sacar una pregunta aleatoria y activar el temporizador.',
                  ),

                  rulesItem(
                    icon: Icons.timer_rounded,
                    title: 'Responde rápido',
                    text:
                    'El jugador tiene 10 segundos para responder antes de que el tiempo llegue a cero.',
                  ),

                  rulesItem(
                    icon: Icons.question_answer_rounded,
                    title: 'Preguntas variadas',
                    text:
                    'Pueden salir preguntas de cultura general, categorías rápidas, cosas graciosas o retos mentales.',
                  ),

                  rulesItem(
                    icon: Icons.warning_rounded,
                    title: 'Si falla o duda',
                    text:
                    'Si el jugador no responde, se queda en blanco o tarda demasiado, pulsa CASTIGO.',
                  ),

                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Castigo',
                    text:
                    'El botón CASTIGO saca una penalización aleatoria para el jugador.',
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'ENTENDIDO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appWhite.withOpacity(0.85),
                width: 2.2,
              ),
            ),
            child: const Icon(
              Icons.sports_tennis_rounded,
              color: appWhite,
              size: 38,
            ),
          ),

          const SizedBox(height: 22),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: slide,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              preguntaActual,
              key: ValueKey(preguntaActual),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontSize: 27,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimerCircle() {
    final bool danger = tiempoRestante <= 3 && juegoIniciado;
    final bool finished = tiempoRestante == 0 && juegoIniciado;

    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: finished
              ? accentPink
              : danger
              ? accentOrange
              : appWhite.withOpacity(0.80),
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          '$tiempoRestante',
          style: TextStyle(
            color: finished
                ? accentPink
                : danger
                ? accentOrange
                : appWhite,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget buildCastigoCard() {
    if (castigoActual.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentPink.withOpacity(0.22),
        border: Border.all(
          color: appWhite.withOpacity(0.30),
          width: 1.4,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'CASTIGO',
            style: TextStyle(
              color: appWhite,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            castigoActual,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: appWhite,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              buildTopBar(),

              const SizedBox(height: 14),

              buildInfoBar(),

              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildQuestionCard(),
                      const SizedBox(height: 22),
                      buildTimerCircle(),
                      const SizedBox(height: 18),
                      buildCastigoCard(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: empezarRonda,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'EMPEZAR',
                          style: TextStyle(
                            color: appBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: juegoIniciado ? siguientePregunta : null,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'SIGUIENTE',
                          style: TextStyle(
                            color: appBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: juegoIniciado ? sacarCastigo : null,
                      style: dangerButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'CASTIGO',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: reiniciarJuego,
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'REINICIAR',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}