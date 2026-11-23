import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/drink_dare_data.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class DrinkDareScreen extends StatefulWidget {
  const DrinkDareScreen({super.key});

  @override
  State<DrinkDareScreen> createState() => _DrinkDareScreenState();
}

class _DrinkDareScreenState extends State<DrinkDareScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  late final AnimationController controller;

  double angle = 0;
  double speed = 0;
  bool spinning = false;
  bool stopping = false;

  String resultado = 'Pulsa girar para empezar';

  final List<Color> wheelColors = const [
    Color(0xFFFF4D6D),
    Color(0xFFFFB86C),
    Color(0xFFFFD166),
    Color(0xFF22C55E),
    Color(0xFF60A5FA),
    Color(0xFF8B5CF6),
    Color(0xFFF472B6),
    Color(0xFF14B8A6),
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    );

    controller.addListener(() {
      if (!spinning) return;

      bool shouldFinish = false;

      setState(() {
        angle = (angle + speed) % (2 * pi);

        if (stopping) {
          speed *= 0.965;

          if (speed < 0.008) {
            shouldFinish = true;
          }
        }
      });

      if (shouldFinish) {
        finishSpin();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void girarRuleta() {
    if (spinning || drinkDareOpciones.isEmpty) return;

    setState(() {
      spinning = true;
      stopping = false;
      speed = 0.18 + random.nextDouble() * 0.08;
      resultado = 'Girando...';
    });

    controller.repeat();
  }

  void pararRuleta() {
    if (!spinning || stopping) return;

    setState(() {
      stopping = true;
      resultado = 'Frenando...';
    });
  }

  void finishSpin() {
    controller.stop();

    final selectedIndex = getSelectedIndex();
    final selectedNumber = selectedIndex + 1;
    final selectedText = drinkDareOpciones[selectedIndex];

    setState(() {
      spinning = false;
      stopping = false;
      speed = 0;
      resultado = 'Ha salido el número $selectedNumber';
    });

    mostrarResultado(selectedNumber, selectedText);
  }

  int getSelectedIndex() {
    final total = drinkDareOpciones.length;
    final segmentAngle = 2 * pi / total;
    final normalizedAngle = ((-angle) % (2 * pi) + (2 * pi)) % (2 * pi);

    return (normalizedAngle / segmentAngle).floor() % total;
  }

  ButtonStyle mainButtonStyle() =>
      CuboButtons.primary(padding: EdgeInsets.zero);

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 38.0 : 46.0;
    final illustrationSize = compact ? 60.0 : 78.0;

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
            CuboCircleButton(
              icon: Icons.question_mark_rounded,
              size: compact ? 44 : 50,
              onTap: mostrarNormas,
            ),
          ],
        ),
        SizedBox(height: compact ? 10 : 16),
        Padding(
          padding: EdgeInsets.only(left: compact ? 18 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'la ruleta',
                        maxLines: 1,
                        style: CuboText.title(size: titleSize),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CuboIllustration('ruleta', size: illustrationSize),
                ],
              ),
              SizedBox(height: compact ? 8 : 12),
              const CuboPillBar(width: 44, color: CuboColors.fiesta),
            ],
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
                    'DRINK & DARE',
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  rulesItem(
                    icon: Icons.rotate_right_rounded,
                    title: 'Cómo jugar',
                    text:
                        'Por turnos, gira la ruleta y pulsa PARAR cuando quieras. Cuando se detenga, cumple lo que indique el número que haya salido.',
                  ),

                  rulesItem(
                    icon: Icons.water_drop_rounded,
                    title: 'Cascada',
                    text:
                        'Quien saque CASCADA empieza el reto. Después empieza la persona de su derecha y así sucesivamente. Cuando la persona de tu izquierda pare, tú también puedes parar, aunque puedes seguir para obligar a la persona de tu derecha a continuar.',
                  ),

                  rulesItem(
                    icon: Icons.visibility_rounded,
                    title: 'Medusa',
                    text:
                        'Todos cierran los ojos. A la cuenta de 3, cada uno mira a un jugador cualquiera. Si dos personas cruzan la mirada, quedan eliminadas. Se repite hasta que quede un único ganador o solo dos jugadores en pie.',
                  ),

                  rulesItem(
                    icon: Icons.category_rounded,
                    title: 'Saco lleno de…',
                    text:
                        'Elige una temática, por ejemplo marcas de ropa. Por turnos, cada jugador debe decir algo de esa categoría sin repetir. El primero que no sepa qué decir recibe un reto.',
                  ),

                  rulesItem(
                    icon: Icons.rule_rounded,
                    title: 'Poner una norma',
                    text:
                        'Crea una norma que todos deberán cumplir durante toda la noche. Por ejemplo: solo se puede utilizar la mano izquierda.',
                  ),

                  rulesItem(
                    icon: Icons.comments_disabled_rounded,
                    title: 'Prohibir palabra',
                    text:
                        'Elige una palabra que queda prohibida. Cada vez que alguien la diga, recibe un reto.',
                  ),

                  rulesItem(
                    icon: Icons.flash_on_rounded,
                    title: 'ZAS',
                    text:
                        'Si te toca ZAS consigues este poder y puedes usarlo cuando quieras y tantas veces como quieras. Grita “ZAS” y haz 🤙 poniéndote la mano en la frente. El último jugador en imitarte recibe un reto.',
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

  void mostrarResultado(int number, String text) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CuboIllustration('ruleta', size: 88, popIn: true),
              const SizedBox(height: 14),
              Text(
                'número $number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CuboColors.fiesta,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'te ha tocado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: 34,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              const CuboPillBar(),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: CuboDecorations.whiteCard(),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuboColors.blueInk,
                    fontSize: 23,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'OK',
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
    );
  }

  /// Inclinación del puntero: da un "tic" cada vez que pasa una casilla.
  double pointerTilt() {
    if (!spinning || drinkDareOpciones.isEmpty) return 0;
    final segment = 2 * pi / drinkDareOpciones.length;
    final within = ((-angle) % segment + segment) % segment / segment;
    return -0.42 * max(0.0, 1 - within * 3.5);
  }

  /// Las luces del aro parpadean más rápido cuanto más rápido gira.
  bool lightsPhase() => spinning && (angle * 9).floor().isEven;

  Widget buildWheel(double wheelSize) {
    final hubSize = wheelSize * 0.2;
    final pointerWidth = wheelSize * 0.13;
    final wheelTop = pointerWidth * 0.55;

    return SizedBox(
      width: wheelSize,
      height: wheelSize + wheelTop,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Halo de luz detrás de la ruleta.
          Positioned(
            top: wheelTop - wheelSize * 0.12,
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: wheelSize * 1.24,
                height: wheelSize * 1.24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CuboColors.whiteA(spinning ? 0.22 : 0.12),
                      CuboColors.whiteA(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: wheelTop,
            width: wheelSize,
            height: wheelSize,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 26,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  painter: _DrinkWheelPainter(
                    itemCount: drinkDareOpciones.length,
                    colors: wheelColors,
                    lightsPhase: lightsPhase(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: wheelTop + (wheelSize - hubSize) / 2,
            child: buildHub(hubSize),
          ),
          Positioned(
            top: 0,
            child: Transform.rotate(
              angle: pointerTilt(),
              alignment: const Alignment(0, -0.4),
              child: CustomPaint(
                size: Size(pointerWidth, pointerWidth * 1.6),
                painter: const _WheelPointerPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHub(double size) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.07),
      decoration: BoxDecoration(
        color: CuboColors.blueDeep,
        border: Border.all(color: CuboColors.whiteA(0.45), width: 1.5),
        shape: BoxShape.circle,
        boxShadow: CuboShadows.soft,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [CuboColors.blueLight, CuboColors.blueDeep],
          ),
        ),
        child: Icon(
          Icons.local_bar_rounded,
          color: CuboColors.white,
          size: size * 0.44,
        ),
      ),
    );
  }

  Widget buildStatus(bool compact) {
    final icon = spinning
        ? (stopping ? Icons.slow_motion_video_rounded : Icons.autorenew_rounded)
        : Icons.touch_app_rounded;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(resultado),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 20,
          vertical: compact ? 9 : 11,
        ),
        decoration: BoxDecoration(
          color: CuboColors.whiteA(0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CuboColors.whiteA(0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: CuboColors.white, size: compact ? 18 : 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                resultado,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CuboText.label(
                  size: compact ? 15 : 17,
                  color: CuboColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameCard({required bool compact}) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: CuboDecorations.glass(radius: CuboRadii.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final statusSpace = compact ? 70.0 : 86.0;
          final availableWheel = min(
            constraints.maxWidth - (compact ? 32 : 40),
            (constraints.maxHeight - statusSpace) / 1.07,
          );
          final wheelSize = availableWheel
              .clamp(180.0, compact ? 300.0 : 360.0)
              .toDouble();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: compact ? 12 : 18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - (compact ? 24 : 36),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildWheel(wheelSize),
                  SizedBox(height: compact ? 14 : 22),
                  buildStatus(compact),
                ],
              ),
            ),
          );
        },
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
                  compact ? 12 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),
                    SizedBox(height: compact ? 10 : 14),
                    Expanded(child: buildGameCard(compact: compact)),
                    SizedBox(height: compact ? 10 : 14),
                    Row(
                      children: [
                        Expanded(
                          child: CuboChoiceButton(
                            icon: Icons.rotate_right_rounded,
                            label: 'GIRAR',
                            primary: true,
                            accent: CuboColors.fiesta,
                            height: compact ? 84 : 100,
                            onTap: spinning ? null : girarRuleta,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CuboChoiceButton(
                            icon: Icons.pan_tool_alt_rounded,
                            label: stopping ? 'FRENANDO' : 'PARAR',
                            primary: true,
                            height: compact ? 84 : 100,
                            onTap: spinning && !stopping ? pararRuleta : null,
                          ),
                        ),
                      ],
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

class _DrinkWheelPainter extends CustomPainter {
  final int itemCount;
  final List<Color> colors;
  final bool lightsPhase;

  const _DrinkWheelPainter({
    required this.itemCount,
    required this.colors,
    required this.lightsPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount == 0) return;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rimWidth = radius * 0.11;
    final faceRadius = radius - rimWidth;
    final faceRect = Rect.fromCircle(center: center, radius: faceRadius);
    final segmentAngle = 2 * pi / itemCount;

    // Aro exterior azul con un brillo suave arriba.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuboColors.blueLight, CuboColors.blueDeep],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white.withValues(alpha: 0.35),
    );

    // Casillas con un degradado suave hacia el centro.
    for (int i = 0; i < itemCount; i++) {
      final color = colors[i % colors.length];
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.35)!,
            color,
            Color.lerp(color, Colors.black, 0.08)!,
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(faceRect);
      canvas.drawArc(
        faceRect,
        -pi / 2 + segmentAngle * i,
        segmentAngle,
        true,
        paint,
      );
    }

    // Separadores finos.
    final divider = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = max(1.5, radius * 0.014)
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < itemCount; i++) {
      final a = -pi / 2 + segmentAngle * i;
      canvas.drawLine(
        center,
        center + Offset(cos(a), sin(a)) * faceRadius,
        divider,
      );
    }

    // Sombra interior junto al aro para dar profundidad.
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035
        ..color = Colors.black.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Luces de feria en el aro; se alternan mientras gira.
    final lights = max(16, itemCount * 2);
    final lightRadius = rimWidth * 0.24;
    for (int i = 0; i < lights; i++) {
      final a = -pi / 2 + 2 * pi * i / lights + pi / lights;
      final p = center + Offset(cos(a), sin(a)) * (radius - rimWidth / 2);
      final on = i.isEven != lightsPhase;
      canvas.drawCircle(
        p,
        lightRadius,
        Paint()
          ..color = on
              ? CuboColors.white
              : CuboColors.white.withValues(alpha: 0.28),
      );
    }

    // Números en una chapa blanca.
    for (int i = 0; i < itemCount; i++) {
      _drawNumber(
        canvas: canvas,
        center: center,
        radius: faceRadius,
        angle: -pi / 2 + segmentAngle * (i + 0.5),
        number: i + 1,
        color: colors[i % colors.length],
      );
    }
  }

  void _drawNumber({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required int number,
    required Color color,
  }) {
    final badgeRadius = radius * 0.13;
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: badgeRadius * 1.15,
          fontFamily: CuboText.fontFamily,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = center + Offset(cos(angle), sin(angle)) * (radius * 0.74);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle + pi / 2);
    canvas.drawCircle(
      const Offset(0, 1.5),
      badgeRadius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      Offset.zero,
      badgeRadius,
      Paint()..color = Color.lerp(color, CuboColors.blueDeep, 0.45)!,
    );
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrinkWheelPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount ||
        oldDelegate.colors != colors ||
        oldDelegate.lightsPhase != lightsPhase;
  }
}

/// Puntero tipo chincheta: cabeza redonda blanca con punto azul y pico abajo.
class _WheelPointerPainter extends CustomPainter {
  const _WheelPointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final headRadius = w / 2;
    final head = Offset(w / 2, headRadius);

    final path = Path()
      ..addOval(Rect.fromCircle(center: head, radius: headRadius))
      ..moveTo(w / 2 - headRadius * 0.8, head.dy + headRadius * 0.5)
      ..quadraticBezierTo(
        w / 2 - headRadius * 0.2,
        size.height * 0.85,
        w / 2,
        size.height,
      )
      ..quadraticBezierTo(
        w / 2 + headRadius * 0.2,
        size.height * 0.85,
        w / 2 + headRadius * 0.8,
        head.dy + headRadius * 0.5,
      )
      ..close();

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: head, radius: headRadius)),
      Colors.black,
      5,
      false,
    );
    canvas.drawPath(path, Paint()..color = CuboColors.white);
    canvas.drawCircle(
      head,
      headRadius * 0.42,
      Paint()..color = CuboColors.blue,
    );
    canvas.drawCircle(
      head + Offset(-headRadius * 0.13, -headRadius * 0.13),
      headRadius * 0.12,
      Paint()..color = CuboColors.blueLight,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPointerPainter oldDelegate) => false;
}
