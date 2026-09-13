import 'dart:math';
import 'package:flutter/material.dart';
import '../data/drink_dare_data.dart';
import '../widgets/app_logo_button.dart';

class DrinkDareScreen extends StatefulWidget {
  const DrinkDareScreen({super.key});

  @override
  State<DrinkDareScreen> createState() => _DrinkDareScreenState();
}

class _DrinkDareScreenState extends State<DrinkDareScreen>
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentGreen = Color(0xFF22C55E);

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
    final titleSize = compact ? 35.0 : 42.0;
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
                        'la ruleta',
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 2.0,
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
                    'DRINK & DARE',
                    style: TextStyle(
                      color: appWhite,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentPink.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentPink, width: 2.4),
                ),
                child: const Icon(
                  Icons.local_bar_rounded,
                  color: accentPink,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'número $number',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: accentPink,
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
                  color: appWhite,
                  fontSize: 34,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 3, color: appWhite.withOpacity(0.58)),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.26),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
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
          final maxWheel = compact ? 250.0 : 330.0;
          final availableWheel = min(
            constraints.maxWidth - 28,
            constraints.maxHeight * (compact ? 0.66 : 0.72),
          );
          final wheelSize = availableWheel.clamp(180.0, maxWheel).toDouble();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18,
              vertical: compact ? 14 : 20,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: wheelSize,
                    height: wheelSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned.fill(
                          child: Transform.rotate(
                            angle: angle,
                            child: CustomPaint(
                              painter: _DrinkWheelPainter(
                                itemCount: drinkDareOpciones.length,
                                colors: wheelColors,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: compact ? 48 : 58,
                          height: compact ? 48 : 58,
                          decoration: BoxDecoration(
                            color: appBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: appWhite.withOpacity(0.88),
                              width: 2.2,
                            ),
                          ),
                          child: Icon(
                            Icons.local_bar_rounded,
                            color: appWhite,
                            size: compact ? 25 : 30,
                          ),
                        ),
                        Positioned(
                          top: -9,
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: compact ? 64 : 76,
                            color: appWhite,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.55),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: Text(
                      resultado,
                      key: ValueKey(resultado),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: compact ? 18 : 22,
                        height: 1.18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
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
    return Expanded(
      child: AspectRatio(
        aspectRatio: compact ? 1.55 : 1.45,
        child: Material(
          color: onTap == null
              ? backgroundColor.withOpacity(0.35)
              : backgroundColor,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 12,
                vertical: compact ? 10 : 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: appWhite.withOpacity(onTap == null ? 0.12 : 0.28),
                  width: 2.4,
                ),
                boxShadow: onTap == null
                    ? null
                    : [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor.withOpacity(onTap == null ? 0.45 : 1),
                    size: compact ? 38 : 48,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor.withOpacity(onTap == null ? 0.45 : 1),
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
                      buildActionButton(
                        icon: Icons.rotate_right_rounded,
                        label: 'GIRAR',
                        backgroundColor: appBlue,
                        foregroundColor: appWhite,
                        onTap: spinning ? null : girarRuleta,
                        compact: compact,
                      ),
                      const SizedBox(width: 12),
                      buildActionButton(
                        icon: Icons.pan_tool_alt_rounded,
                        label: stopping ? 'FRENANDO' : 'PARAR',
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        onTap: spinning && !stopping ? pararRuleta : null,
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

class _DrinkWheelPainter extends CustomPainter {
  final int itemCount;
  final List<Color> colors;

  const _DrinkWheelPainter({
    required this.itemCount,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount == 0) return;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final segmentAngle = 2 * pi / itemCount;
    double startAngle = -pi / 2;

    for (int i = 0; i < itemCount; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, segmentAngle, true, paint);

      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(rect, startAngle, segmentAngle, true, borderPaint);

      _drawNumber(
        canvas: canvas,
        center: center,
        radius: radius,
        angle: startAngle + segmentAngle / 2,
        number: i + 1,
      );

      startAngle += segmentAngle;
    }

    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(center, radius, outerPaint);
  }

  void _drawNumber({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required int number,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius < 120 ? 18 : 24,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(
              color: Colors.black54,
              blurRadius: 5,
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final textRadius = radius * 0.72;
    final offset = Offset(
      center.dx + cos(angle) * textRadius,
      center.dy + sin(angle) * textRadius,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle + pi / 2);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrinkWheelPainter oldDelegate) {
    return oldDelegate.itemCount != itemCount || oldDelegate.colors != colors;
  }
}
