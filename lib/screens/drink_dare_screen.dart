import 'dart:math';
import 'package:flutter/material.dart';
import '../data/drink_dare_data.dart';

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

  late AnimationController controller;

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
        angle += speed;
        angle %= 2 * pi;

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
      mostrarNormas();
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
    });
  }

  void finishSpin() {
    controller.stop();

    final selectedIndex = getSelectedIndex();
    final selectedText = drinkDareOpciones[selectedIndex];

    setState(() {
      spinning = false;
      stopping = false;
      speed = 0;
      resultado = selectedText;
    });

    mostrarResultado(selectedText);
  }

  int getSelectedIndex() {
    final total = drinkDareOpciones.length;
    final segmentAngle = 2 * pi / total;

    final normalizedAngle = ((-angle) % (2 * pi) + (2 * pi)) % (2 * pi);

    return (normalizedAngle / segmentAngle).floor() % total;
  }

  void reiniciarJuego() {
    if (spinning) return;

    setState(() {
      angle = 0;
      resultado = 'Pulsa girar para empezar';
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

  ButtonStyle stopButtonStyle() {
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
                    'drink\n& dare',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 42,
                      height: 0.88,
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

    if (spinning && stopping) {
      text = 'La ruleta está frenando...';
    } else if (spinning) {
      text = 'Pulsa parar cuando quieras';
    } else {
      text = 'Gira la ruleta y acepta el reto';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: const BorderSide(
            color: accentPink,
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
                    title: 'Gira la ruleta',
                    text:
                    'Pulsa GIRAR para que la ruleta empiece a moverse con todas las opciones.',
                  ),

                  rulesItem(
                    icon: Icons.pan_tool_alt_rounded,
                    title: 'Para cuando quieras',
                    text:
                    'Pulsa PARAR en el momento que quieras. La ruleta irá frenando poco a poco.',
                  ),

                  rulesItem(
                    icon: Icons.casino_rounded,
                    title: 'Acepta el resultado',
                    text:
                    'Cuando se detenga, aparecerá el reto o castigo que tiene que hacer el jugador.',
                  ),

                  rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Turnos',
                    text:
                    'Los jugadores se van turnando para girar la ruleta.',
                  ),

                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Si no quieres hacerlo',
                    text:
                    'Si alguien se niega a cumplir el reto, bebe como castigo.',
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

  void mostrarResultado(String text) {
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.1,
                  ),
                ),
                child: const Icon(
                  Icons.local_bar_rounded,
                  color: appWhite,
                  size: 30,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'te ha\ntocado',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 3,
                color: appWhite.withOpacity(0.58),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
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
                    fontSize: 24,
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

  Widget buildWheel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  painter: _DrinkWheelPainter(
                    options: drinkDareOpciones,
                    colors: wheelColors,
                  ),
                ),
              ),
            ),

            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: appBlue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: appWhite.withOpacity(0.85),
                  width: 2.2,
                ),
              ),
              child: const Icon(
                Icons.local_bar_rounded,
                color: appWhite,
                size: 28,
              ),
            ),

            Positioned(
              top: -8,
              child: Icon(
                Icons.arrow_drop_down_rounded,
                size: 76,
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
    );
  }

  Widget buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: Text(
          resultado,
          key: ValueKey(resultado),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: appWhite,
            fontSize: 22,
            height: 1.18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              buildTopBar(),

              const SizedBox(height: 14),

              buildInfoBar(),

              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildWheel(),
                        const SizedBox(height: 14),
                        buildResultCard(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: spinning ? null : girarRuleta,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'GIRAR',
                          style: TextStyle(
                            color: appBlue,
                            fontSize: 16,
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
                      onPressed: spinning && !stopping ? pararRuleta : null,
                      style: stopButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'PARAR',
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

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: spinning ? null : reiniciarJuego,
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
        ),
      ),
    );
  }
}

class _DrinkWheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors;

  const _DrinkWheelPainter({
    required this.options,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final segmentAngle = 2 * pi / options.length;
    double startAngle = -pi / 2;

    for (int i = 0; i < options.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, segmentAngle, true, paint);

      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(rect, startAngle, segmentAngle, true, borderPaint);

      _drawText(
        canvas: canvas,
        center: center,
        radius: radius,
        angle: startAngle + segmentAngle / 2,
        text: options[i],
      );

      startAngle += segmentAngle;
    }

    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(center, radius, outerPaint);
  }

  void _drawText({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double angle,
    required String text,
  }) {
    final shortText = text.length > 26 ? '${text.substring(0, 26)}...' : text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: shortText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          height: 1.05,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 6,
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );

    textPainter.layout(maxWidth: radius * 0.36);

    final textRadius = radius * 0.74;

    final offset = Offset(
      center.dx + cos(angle) * textRadius,
      center.dy + sin(angle) * textRadius,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(angle + pi / 2);

    textPainter.paint(
      canvas,
      Offset(
        -textPainter.width / 2,
        -textPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DrinkWheelPainter oldDelegate) {
    return oldDelegate.options != options || oldDelegate.colors != colors;
  }
}