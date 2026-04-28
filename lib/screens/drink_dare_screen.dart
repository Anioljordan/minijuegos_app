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

  late AnimationController controller;

  double angle = 0;
  double speed = 0;
  bool spinning = false;
  bool stopping = false;

  String resultado = 'Pulsa girar para empezar';

  final List<Color> colors = const [
    Color(0xFFFF005C),
    Color(0xFFFF7A00),
    Color(0xFFFFD60A),
    Color(0xFF00D084),
    Color(0xFF00A3FF),
    Color(0xFF8A2BE2),
    Color(0xFFFF3D71),
    Color(0xFF00C2A8),
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

      setState(() {
        angle += speed;
        angle %= 2 * pi;

        if (stopping) {
          speed *= 0.965;

          if (speed < 0.008) {
            finishSpin();
          }
        }
      });
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

    // La ruleta empieza dibujando el primer segmento arriba (-pi/2)
    // Cuando giramos la ruleta, el segmento bajo la flecha es el ángulo contrario
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

  void mostrarResultado(String text) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.pinkAccent.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Te ha tocado',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF171027),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cómo se juega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Los jugadores se turnan para girar la ruleta.\n\n'
                    'Pulsa GIRAR y luego PARAR cuando quieras.\n\n'
                    'El resultado indica lo que debe hacer el jugador.\n\n'
                    'Si alguien no quiere hacerlo, bebe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w800),
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
                              'Drink & Dare',
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

                      Text(
                        spinning
                            ? stopping
                            ? 'La ruleta está frenando...'
                            : 'Pulsa PARAR cuando quieras'
                            : 'Gira la ruleta y acepta el reto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pinkAccent.withOpacity(0.45),
                                          blurRadius: 50,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),

                                  Transform.rotate(
                                    angle: angle,
                                    child: CustomPaint(
                                      painter: _DrinkWheelPainter(
                                        options: drinkDareOpciones,
                                        colors: colors,
                                      ),
                                      size: const Size.square(360),
                                    ),
                                  ),

                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF111827),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.18),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.local_bar_rounded,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),

                                  Positioned(
                                    top: -4,
                                    child: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      size: 78,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.pinkAccent.withOpacity(0.9),
                                          blurRadius: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.11),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.14),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            resultado,
                            key: ValueKey(resultado),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: spinning ? null : girarRuleta,
                              style: mainButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'GIRAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: spinning && !stopping ? pararRuleta : null,
                              style: stopButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'PARAR',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: spinning ? null : reiniciarJuego,
                          style: secondaryButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Reiniciar',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
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
    // Limitar longitud visual
    final shortText =
    text.length > 28 ? '${text.substring(0, 28)}...' : text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: shortText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1.1,
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

    // MÁS margen lateral
    textPainter.layout(maxWidth: radius * 0.38);

    // MÁS cerca del borde (mejora visibilidad)
    final textRadius = radius * 0.78;

    final offset = Offset(
      center.dx + cos(angle) * textRadius,
      center.dy + sin(angle) * textRadius,
    );

    canvas.save();

    canvas.translate(offset.dx, offset.dy);

    // Rotación más natural
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