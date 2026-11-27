import 'dart:math';
import 'package:flutter/foundation.dart' show listEquals;
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
    CuboColors.fiesta,
    CuboColors.white,
    CuboColors.chill,
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

    setState(() {
      spinning = false;
      stopping = false;
      speed = 0;
      resultado = _sliceAt(selectedIndex).label;
    });

    mostrarResultado(selectedIndex);
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
        CuboGameTitle(
          'la ruleta',
          side: CuboTitleSide.fiesta,
          illustration: 'ruleta',
          compact: compact,
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
                    'RULETA DE RETOS',
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
                        'Quien saque CASCADA dice una palabra. La persona de su derecha dice otra que empiece por la última letra, y así sucesivamente. Quien se quede en blanco o repita una palabra recibe un reto.',
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

  void mostrarResultado(int index) {
    final slice = _sliceAt(index);
    final text = drinkDareOpciones[index];
    final color = _DrinkWheelPainter.segmentColor(
      index,
      drinkDareOpciones.length,
      wheelColors,
    );
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // El quesito que ha salido: su color y su icono.
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: CuboShadows.soft,
                  ),
                  child: Icon(slice.icon, color: CuboColors.blueInk, size: 42),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                tr('te ha tocado').toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.whiteA(0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: CuboColors.whiteA(0.12),
                  borderRadius: CuboRadii.mdAll,
                ),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuboColors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CuboPressable(
                onTap: () => Navigator.pop(dialogContext),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: CuboColors.fiesta,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: CuboColors.blueInk,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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
    return -0.35 * max(0.0, 1 - within * 3.5);
  }

  Widget buildWheel(double wheelSize) {
    final hubSize = wheelSize * 0.17;
    final pointerWidth = wheelSize * 0.12;
    final wheelTop = pointerWidth * 0.7;
    final count = drinkDareOpciones.length;

    return SizedBox(
      width: wheelSize,
      height: wheelSize + wheelTop,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: wheelTop,
            width: wheelSize,
            height: wheelSize,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x38000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: angle,
                child: CustomPaint(
                  painter: _DrinkWheelPainter(
                    labels: [
                      for (var i = 0; i < count; i++) tr(_sliceAt(i).label),
                    ],
                    icons: [for (var i = 0; i < count; i++) _sliceAt(i).icon],
                    colors: wheelColors,
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
              alignment: const Alignment(0, -0.5),
              child: CustomPaint(
                size: Size(pointerWidth, pointerWidth * 1.25),
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: CuboColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: CuboColors.blue, width: size * 0.09),
        boxShadow: CuboShadows.soft,
      ),
      child: Container(
        width: size * 0.3,
        height: size * 0.3,
        decoration: const BoxDecoration(
          color: CuboColors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// Un único botón: GIRAR en reposo, PARAR mientras gira.
  void toggleSpin() => spinning ? pararRuleta() : girarRuleta();

  Widget buildStatus(bool compact) {
    // Mientras gira se ve el nombre del quesito que pasa por el puntero.
    final style = TextStyle(
      color: CuboColors.white,
      fontSize: compact ? 18 : 21,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.2,
    );
    if (spinning && drinkDareOpciones.isNotEmpty) {
      return Text(
        _sliceAt(getSelectedIndex()).label,
        textAlign: TextAlign.center,
        maxLines: 1,
        style: style,
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Text(
        resultado,
        key: ValueKey(resultado),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      ),
    );
  }

  Widget buildGameArea({required bool compact}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final statusSpace = compact ? 44.0 : 56.0;
        final wheelSize = min(
          constraints.maxWidth,
          (constraints.maxHeight - statusSpace) / 1.08,
        ).clamp(180.0, 420.0).toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: stopping ? null : toggleSpin,
              child: buildWheel(wheelSize),
            ),
            SizedBox(height: compact ? 14 : 20),
            buildStatus(compact),
          ],
        );
      },
    );
  }

  Widget buildSpinButton({required bool compact}) {
    final label = !spinning
        ? 'GIRAR'
        : stopping
        ? 'FRENANDO'
        : 'PARAR';
    final icon = spinning
        ? Icons.pan_tool_alt_rounded
        : Icons.rotate_right_rounded;
    final enabled = !stopping;
    final background = !spinning
        ? CuboColors.fiesta
        : enabled
        ? CuboColors.white
        : CuboColors.whiteA(0.16);
    final fg = enabled ? CuboColors.blueInk : CuboColors.whiteA(0.6);

    return CuboPressable(
      onTap: enabled ? toggleSpin : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: compact ? 64 : 72,
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          boxShadow: enabled ? CuboShadows.soft : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
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
                  compact ? 12 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),
                    SizedBox(height: compact ? 10 : 14),
                    Expanded(child: buildGameArea(compact: compact)),
                    SizedBox(height: compact ? 12 : 16),
                    buildSpinButton(compact: compact),
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

/// Nombre corto e icono de cada quesito, en el orden de [drinkDareOpciones].
const List<({String label, IconData icon})> _slices = [
  (label: '2 RETOS', icon: Icons.looks_two_rounded),
  (label: '3 RETOS', icon: Icons.looks_3_rounded),
  (label: 'CASCADA', icon: Icons.water_drop_rounded),
  (label: 'REPARTE 4', icon: Icons.call_split_rounded),
  (label: 'ESCLAVO', icon: Icons.link_rounded),
  (label: 'MEDUSA', icon: Icons.visibility_rounded),
  (label: 'SACO LLENO', icon: Icons.category_rounded),
  (label: 'SÚPER RETO', icon: Icons.local_fire_department_rounded),
  (label: 'NORMA', icon: Icons.rule_rounded),
  (label: 'PROHIBIR', icon: Icons.comments_disabled_rounded),
  (label: 'ZAS', icon: Icons.flash_on_rounded),
  (label: 'TODOS', icon: Icons.groups_rounded),
  (label: 'TÚ ELIGES', icon: Icons.touch_app_rounded),
];

({String label, IconData icon}) _sliceAt(int i) => i < _slices.length
    ? _slices[i]
    : (label: '${i + 1}', icon: Icons.casino_rounded);

/// Ruleta plana: quesitos de color separados por líneas azules, cada uno
/// con su icono junto al borde y su nombre a lo largo del radio.
class _DrinkWheelPainter extends CustomPainter {
  final List<String> labels;
  final List<IconData> icons;
  final List<Color> colors;

  const _DrinkWheelPainter({
    required this.labels,
    required this.icons,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final count = labels.length;
    if (count == 0) return;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final faceRadius = radius * 0.95;
    final faceRect = Rect.fromCircle(center: center, radius: faceRadius);
    final segmentAngle = 2 * pi / count;

    // Aro blanco fino.
    canvas.drawCircle(center, radius, Paint()..color = CuboColors.white);

    for (int i = 0; i < count; i++) {
      canvas.drawArc(
        faceRect,
        -pi / 2 + segmentAngle * i,
        segmentAngle,
        true,
        Paint()..color = segmentColor(i, count, colors),
      );
    }

    // Separadores del azul del fondo que recortan cada quesito.
    final divider = Paint()
      ..color = CuboColors.blue
      ..strokeWidth = max(2.0, radius * 0.022);
    for (int i = 0; i < count; i++) {
      final a = -pi / 2 + segmentAngle * i;
      canvas.drawLine(
        center,
        center + Offset(cos(a), sin(a)) * faceRadius,
        divider,
      );
    }
    canvas.drawCircle(
      center,
      faceRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = divider.strokeWidth
        ..color = CuboColors.blue,
    );

    for (int i = 0; i < count; i++) {
      final mid = -pi / 2 + segmentAngle * (i + 0.5);
      _drawSlice(canvas, center, faceRadius, mid, labels[i], icons[i]);
    }
  }

  /// Icono cerca del borde y nombre en el radio, leyendo hacia fuera.
  void _drawSlice(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String label,
    IconData icon,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: radius * 0.13,
          color: CuboColors.blueInk,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(radius * 0.83, 0);
    canvas.rotate(pi / 2);
    iconPainter.paint(
      canvas,
      Offset(-iconPainter.width / 2, -iconPainter.height / 2),
    );
    canvas.restore();

    // El nombre se encoge si no cabe entre el centro y el icono.
    final start = radius * 0.25;
    final end = radius * 0.72;
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: CuboColors.blueInk,
          fontSize: radius * 0.085,
          fontFamily: CuboText.fontFamily,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          height: 1,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    final scale = min(1.0, (end - start) / textPainter.width);
    canvas.translate(end, 0);
    canvas.scale(scale);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width, -textPainter.height / 2),
    );
    canvas.restore();
  }

  /// Color de la casilla [i]; la última evita repetir con sus dos vecinas.
  static Color segmentColor(int i, int count, List<Color> colors) {
    final k = colors.length;
    if (i == count - 1 && count % k == 1 && k > 2) {
      return colors[(count - 2) % k == 1 ? 2 : 1];
    }
    return colors[i % k];
  }

  @override
  bool shouldRepaint(covariant _DrinkWheelPainter oldDelegate) {
    return !listEquals(oldDelegate.labels, labels) ||
        !listEquals(oldDelegate.icons, icons) ||
        oldDelegate.colors != colors;
  }
}

/// Puntero: triángulo redondeado amarillo con borde blanco, apuntando abajo.
class _WheelPointerPainter extends CustomPainter {
  const _WheelPointerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w * 0.2;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w - r * 0.6, r)
      ..lineTo(w / 2 + r * 0.4, h - r * 0.5)
      ..quadraticBezierTo(w / 2, h, w / 2 - r * 0.4, h - r * 0.5)
      ..lineTo(r * 0.6, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();

    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, Paint()..color = CuboColors.fiesta);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2.0, w * 0.07)
        ..strokeJoin = StrokeJoin.round
        ..color = CuboColors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPointerPainter oldDelegate) => false;
}
