import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import '../core/cubo_ui.dart';
import 'i18n_text.dart';

/// Una cara de la moneda dorada: en la cara un perfil en relieve y en la cruz
/// un número grande. Ambas llevan canto estriado, anillo de perlas y la
/// palabra CARA / CRUZ para que se distingan de un vistazo.
class CuboCoinFace extends StatelessWidget {
  final bool cara;
  final double size;

  const CuboCoinFace({super.key, required this.cara, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _CoinPainter(
          cara: cara,
          label: tr(cara ? 'CARA' : 'CRUZ').toUpperCase(),
        ),
      ),
    );
  }
}

class _CoinPainter extends CustomPainter {
  final bool cara;
  final String label;

  _CoinPainter({required this.cara, required this.label});

  static const _rimLight = Color(0xFFFFE9A3);
  static const _rimDark = Color(0xFFB37A16);
  static const _fieldLight = Color(0xFFFFE27A);
  static const _fieldMid = Color(0xFFF2BE3F);
  static const _fieldDark = Color(0xFFD39A22);
  static const _relief = Color(0xFFC8901C);
  static const _reliefShadow = Color(0xFF8A5A0C);
  static const _reliefLight = Color(0xFFFFF4C4);

  /// Número de estrías del canto.
  static const int _reeds = 72;

  /// Número de perlas del anillo interior.
  static const int _beads = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final c = Offset(size.width / 2, size.height / 2);

    _paintShadow(canvas, c, r);
    _paintRim(canvas, c, r);
    _paintField(canvas, c, r * 0.84);
    _paintBeads(canvas, c, r * 0.78, r);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    if (cara) {
      _paintProfile(canvas, r * 0.6);
    } else {
      _paintNumber(canvas, r);
    }
    _paintLabel(canvas, r);
    canvas.restore();

    _paintShine(canvas, c, r);
  }

  void _paintShadow(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c.translate(0, r * 0.06),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
  }

  void _paintRim(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rimLight, _fieldMid, _rimDark, _fieldLight],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(rect),
    );

    // Estrías del canto.
    final reed = Paint()
      ..color = _rimDark.withValues(alpha: 0.55)
      ..strokeWidth = math.max(1, r * 0.012)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < _reeds; i++) {
      final a = i * 2 * math.pi / _reeds;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r * 0.9), c + dir * (r * 0.985), reed);
    }

    // Bisel entre el canto y el campo.
    canvas.drawCircle(
      c,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.035
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_rimDark, _rimLight],
        ).createShader(rect),
    );
  }

  void _paintField(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          radius: 1.05,
          colors: [_fieldLight, _fieldMid, _fieldDark],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _paintBeads(Canvas canvas, Offset c, double ring, double r) {
    final shadow = Paint()..color = _reliefShadow.withValues(alpha: 0.45);
    final bead = Paint()..color = _reliefLight.withValues(alpha: 0.9);
    final radius = r * 0.018;
    for (var i = 0; i < _beads; i++) {
      final a = i * 2 * math.pi / _beads;
      final p = c + Offset(math.cos(a), math.sin(a)) * ring;
      canvas.drawCircle(
        p.translate(radius * 0.4, radius * 0.5),
        radius,
        shadow,
      );
      canvas.drawCircle(p, radius, bead);
    }
  }

  /// Dibuja [path] con relieve: sombra abajo a la derecha, luz arriba a la
  /// izquierda y el metal encima.
  void _emboss(Canvas canvas, Path path, double unit) {
    final o = unit * 0.035;
    canvas.drawPath(
      path.shift(Offset(o, o)),
      Paint()..color = _reliefShadow.withValues(alpha: 0.7),
    );
    canvas.drawPath(
      path.shift(Offset(-o * 0.6, -o * 0.6)),
      Paint()..color = _reliefLight,
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_fieldMid, _relief],
        ).createShader(path.getBounds()),
    );
  }

  /// Perfil de una cabeza mirando a la derecha (coordenadas de -1 a 1).
  void _paintProfile(Canvas canvas, double s) {
    Offset p(double x, double y) => Offset(x * s, (y - 0.12) * s);
    final start = p(-0.34, 0.66);
    final head = Path()..moveTo(start.dx, start.dy);
    void cubic(Offset a, Offset b, Offset e) =>
        head.cubicTo(a.dx, a.dy, b.dx, b.dy, e.dx, e.dy);
    void line(Offset e) => head.lineTo(e.dx, e.dy);

    // Nuca y parte de atrás de la cabeza.
    cubic(p(-0.30, 0.46), p(-0.30, 0.36), p(-0.36, 0.24));
    cubic(p(-0.58, 0.02), p(-0.58, -0.40), p(-0.30, -0.62));
    // Coronilla y frente.
    cubic(p(-0.06, -0.80), p(0.30, -0.72), p(0.36, -0.40));
    cubic(p(0.38, -0.30), p(0.36, -0.24), p(0.38, -0.18));
    // Nariz.
    cubic(p(0.44, -0.08), p(0.52, 0.00), p(0.50, 0.04));
    cubic(p(0.48, 0.08), p(0.42, 0.08), p(0.40, 0.09));
    // Labios y barbilla.
    line(p(0.43, 0.15));
    line(p(0.39, 0.19));
    line(p(0.42, 0.24));
    cubic(p(0.42, 0.36), p(0.34, 0.40), p(0.24, 0.40));
    // Cuello y hombros.
    cubic(p(0.18, 0.40), p(0.14, 0.44), p(0.14, 0.52));
    cubic(p(0.16, 0.62), p(0.40, 0.66), p(0.56, 0.78));
    line(p(-0.62, 0.78));
    cubic(p(-0.52, 0.70), p(-0.44, 0.66), p(-0.34, 0.66));
    head.close();

    _emboss(canvas, head, s);

    // Ojo, oreja y pelo en hueco para dar detalle.
    final detail = Paint()
      ..color = _reliefShadow.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(0.22, -0.20), p(0.32, -0.20), detail);
    canvas.drawArc(
      Rect.fromCenter(
        center: p(-0.10, -0.06),
        width: s * 0.2,
        height: s * 0.28,
      ),
      -math.pi / 2,
      math.pi,
      false,
      detail,
    );
    for (var i = 0; i < 3; i++) {
      final y = -0.52 + i * 0.16;
      canvas.drawArc(
        Rect.fromCenter(center: p(-0.18, y), width: s * 0.5, height: s * 0.22),
        math.pi * 1.1,
        math.pi * 0.8,
        false,
        detail,
      );
    }
  }

  void _paintNumber(Canvas canvas, double r) {
    final fontSize = r * 0.95;
    final tp = _textPainter('1', fontSize, _relief);
    final at = Offset(-tp.width / 2, -tp.height / 2 - r * 0.05);
    final o = r * 0.02;

    _textPainter('1', fontSize, _reliefShadow).paint(canvas, at + Offset(o, o));
    _textPainter(
      '1',
      fontSize,
      _reliefLight,
    ).paint(canvas, at - Offset(o, o) * 0.6);
    tp.paint(canvas, at);

    // Dos ramas de laurel estilizadas alrededor del número.
    final leaf = Paint()..color = _relief;
    final leafShadow = Paint()..color = _reliefShadow.withValues(alpha: 0.6);
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < 5; i++) {
        final a = math.pi / 2 + side * (0.55 + i * 0.22);
        final centre = Offset(math.cos(a), math.sin(a)) * (r * 0.56);
        canvas.save();
        canvas.translate(centre.dx, centre.dy - r * 0.05);
        canvas.rotate(a + side * math.pi / 2);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: r * 0.07,
          height: r * 0.15,
        );
        canvas.drawOval(rect.shift(Offset(o, o)), leafShadow);
        canvas.drawOval(rect, leaf);
        canvas.restore();
      }
    }
  }

  TextPainter _textPainter(String text, double fontSize, Color color) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: CuboText.fontFamily,
          fontWeight: FontWeight.w900,
          height: 1,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  void _paintLabel(Canvas canvas, double r) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: r * 0.13,
          fontFamily: CuboText.fontFamily,
          fontWeight: FontWeight.w900,
          letterSpacing: r * 0.02,
          color: _reliefShadow,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, r * 0.5));
  }

  void _paintShine(Canvas canvas, Offset c, double r) {
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r * 0.98,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0, 0.4, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) =>
      old.cara != cara || old.label != label;
}
