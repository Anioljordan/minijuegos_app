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
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void empezarRonda() {
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

  void siguientePregunta() {
    empezarRonda();
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

    timer?.cancel();

    setState(() {
      castigoActual =
      castigosPingPong[random.nextInt(castigosPingPong.length)];
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

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 38.0 : 48.0;
    final titleHeight = compact ? 72.0 : 94.0;
    final lineTop = compact ? 62.0 : 82.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
              child: Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: compact ? 17 : 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            circleButton(
              compact: compact,
              onTap: mostrarNormas,
              child: Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 14 : 24),
        Padding(
          padding: EdgeInsets.only(left: compact ? 18 : 28),
          child: SizedBox(
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: Text(
                        'ping pong',
                        maxLines: 1,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 1.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: lineTop,
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
          Icon(icon, color: appWhite, size: 22),
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
                  Container(height: 3, color: appWhite.withOpacity(0.58)),
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
                    title: 'Empieza',
                    text: 'Pulsa EMPEZAR para sacar una pregunta aleatoria.',
                  ),
                  rulesItem(
                    icon: Icons.timer_rounded,
                    title: 'Responde rápido',
                    text: 'Tienes 10 segundos para responder antes de llegar a cero.',
                  ),
                  rulesItem(
                    icon: Icons.warning_rounded,
                    title: 'Si falla o duda',
                    text: 'Pulsa CASTIGO si no responde, falla o tarda demasiado.',
                  ),
                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Castigo',
                    text: 'Aparecerá una penalización aleatoria para el jugador.',
                  ),
                  rulesItem(
                    icon: Icons.arrow_forward_rounded,
                    title: 'Siguiente',
                    text: 'Pulsa SIGUIENTE para sacar otra pregunta y reiniciar el tiempo.',
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

  Widget buildTimer({required bool compact}) {
    final bool danger = juegoIniciado && tiempoRestante <= 3;
    final bool finished = juegoIniciado && tiempoRestante == 0;

    final Color timerColor = finished
        ? accentPink
        : danger
        ? accentOrange
        : accentYellow;

    final size = compact ? 82.0 : 104.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: timerColor.withOpacity(0.14),
        border: Border.all(color: timerColor, width: 3),
      ),
      child: Center(
        child: Text(
          '$tiempoRestante',
          style: TextStyle(
            color: timerColor,
            fontSize: compact ? 34 : 44,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  Widget buildGameCard({required bool compact}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 24,
              vertical: compact ? 16 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: max(0.0, constraints.maxHeight - (compact ? 32 : 48)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 68 : 88,
                    height: compact ? 68 : 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentYellow.withOpacity(0.15),
                      border: Border.all(color: accentYellow, width: 3),
                    ),
                    child: Icon(
                      Icons.sports_tennis_rounded,
                      color: accentYellow,
                      size: compact ? 36 : 48,
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 20),
                  buildTimer(compact: compact),
                  SizedBox(height: compact ? 16 : 24),
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
                      style: TextStyle(
                        color: appWhite,
                        fontSize: compact ? 24 : 30,
                        height: 1.14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  if (castigoActual.isNotEmpty) ...[
                    SizedBox(height: compact ? 16 : 22),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        key: ValueKey(castigoActual),
                        width: double.infinity,
                        padding: EdgeInsets.all(compact ? 13 : 16),
                        decoration: BoxDecoration(
                          color: accentPink.withOpacity(0.20),
                          border: Border.all(
                            color: accentPink,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'CASTIGO',
                              style: TextStyle(
                                color: accentPink,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              castigoActual,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: appWhite,
                                fontSize: compact ? 18 : 22,
                                height: 1.16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final disabled = onTap == null;

    return Expanded(
      child: AspectRatio(
        aspectRatio: compact ? 1.55 : 1.4,
        child: Material(
          color: disabled
              ? backgroundColor.withOpacity(0.35)
              : backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appWhite.withOpacity(disabled ? 0.12 : 0.28),
                  width: 2.4,
                ),
                boxShadow: disabled
                    ? null
                    : [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor.withOpacity(disabled ? 0.42 : 1),
                    size: compact ? 36 : 48,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor.withOpacity(disabled ? 0.42 : 1),
                      fontSize: compact ? 12.5 : 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 740;
            final horizontalPadding = compact ? 14.0 : 18.0;
            final verticalPadding = compact ? 12.0 : 18.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                compact ? 10 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(compact: compact),
                  SizedBox(height: compact ? 8 : 14),
                  Expanded(child: buildGameCard(compact: compact)),
                  SizedBox(height: compact ? 9 : 14),
                  Row(
                    children: [
                      buildActionButton(
                        icon: juegoIniciado
                            ? Icons.arrow_forward_rounded
                            : Icons.play_arrow_rounded,
                        label: juegoIniciado ? 'SIGUIENTE' : 'EMPEZAR',
                        backgroundColor: appBlue,
                        foregroundColor: appWhite,
                        onTap:
                        juegoIniciado ? siguientePregunta : empezarRonda,
                        compact: compact,
                      ),
                      const SizedBox(width: 12),
                      buildActionButton(
                        icon: Icons.warning_rounded,
                        label: 'CASTIGO',
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        onTap: juegoIniciado ? sacarCastigo : null,
                        compact: compact,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
