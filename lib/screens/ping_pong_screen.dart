import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/ping_pong_data.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class PingPongScreen extends StatefulWidget {
  const PingPongScreen({super.key});

  @override
  State<PingPongScreen> createState() => _PingPongScreenState();
}

class _PingPongScreenState extends State<PingPongScreen> {
  final Random random = Random();

  String preguntaActual = 'Pulsa empezar para jugar';
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

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: EdgeInsets.zero);
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
            color: CuboColors.white.withValues(alpha: 0.85),
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
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
            ),
            circleButton(
              compact: compact,
              onTap: mostrarNormas,
              child: Icon(
                Icons.question_mark_rounded,
                color: CuboColors.white,
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
                          color: CuboColors.white,
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
                  child: const CuboPillBar(width: 44, color: CuboColors.fiesta),
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
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void mostrarNormas() {
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),
                  const SizedBox(height: 18),
                  const Text(
                    'PING PONG',
                    style: TextStyle(
                      color: CuboColors.white,
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
                    text:
                        'Tienes 10 segundos para responder antes de llegar a cero.',
                  ),
                  rulesItem(
                    icon: Icons.warning_rounded,
                    title: 'Si falla o duda',
                    text:
                        'Si duda, falla o tarda demasiado PIERDE y tiene que hacer un reto.',
                  ),
                  rulesItem(
                    icon: Icons.arrow_forward_rounded,
                    title: 'Siguiente',
                    text:
                        'Pulsa SIGUIENTE para sacar otra pregunta y reiniciar el tiempo.',
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
        ? CuboColors.alert
        : danger
        ? CuboColors.fiesta
        : CuboColors.white;

    final size = compact ? 82.0 : 104.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: timerColor.withValues(alpha: 0.14),
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
    return Column(
      children: [
        SizedBox(height: compact ? 4 : 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: juegoIniciado
              ? KeyedSubtree(
                  key: const ValueKey('timer'),
                  child: buildTimer(compact: compact),
                )
              : CuboIllustration(
                  'ping_pong',
                  key: const ValueKey('illustration'),
                  size: compact ? 82 : 110,
                ),
        ),
        SizedBox(height: compact ? 8 : 14),
        Expanded(
          child: CuboCardStack(
            maxHeight: 400,
            child: CuboPlayCard(
              key: ValueKey(preguntaActual),
              chip: 'ping pong',
              chipIcon: Icons.sports_tennis_rounded,
              maxFontSize: compact ? 24 : 30,
              text: preguntaActual,
            ),
          ),
        ),
      ],
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
              ? backgroundColor.withValues(alpha: 0.35)
              : backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: CuboColors.white.withValues(
                    alpha: disabled ? 0.12 : 0.28,
                  ),
                  width: 2.4,
                ),
                boxShadow: disabled
                    ? null
                    : [
                        BoxShadow(
                          color: backgroundColor.withValues(alpha: 0.28),
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
                    color: foregroundColor.withValues(
                      alpha: disabled ? 0.42 : 1,
                    ),
                    size: compact ? 36 : 48,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor.withValues(
                        alpha: disabled ? 0.42 : 1,
                      ),
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
      backgroundColor: CuboColors.blue,
      body: CuboGameBackground(
        accent: CuboColors.fiesta,
        halo: CuboHalo.topRight,
        child: SafeArea(
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
                    Container(
                      width: double.infinity,
                      height: compact ? 68 : 76,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                        boxShadow: CuboShadows.float,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: juegoIniciado
                            ? siguientePregunta
                            : empezarRonda,
                        style: mainButtonStyle(),
                        icon: Icon(
                          juegoIniciado
                              ? Icons.arrow_forward_rounded
                              : Icons.play_arrow_rounded,
                          size: compact ? 24 : 28,
                        ),
                        label: Text(
                          juegoIniciado ? 'SIGUIENTE PREGUNTA' : 'EMPEZAR',
                          style: TextStyle(
                            fontSize: compact ? 15 : 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
