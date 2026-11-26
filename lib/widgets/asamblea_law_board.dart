import 'package:flutter/material.dart' hide Text;

import 'cubo_widgets.dart';
import 'i18n_text.dart';

/// Colores de un bando de La Asamblea.
class AsambleaBoardPalette {
  final Color light;
  final Color dark;
  final Color accent;
  final Color onAccent;

  const AsambleaBoardPalette({
    required this.light,
    required this.dark,
    required this.accent,
    required this.onAccent,
  });

  static const izquierda = AsambleaBoardPalette(
    light: Color(0xFF3D7BEA),
    dark: Color(0xFF1C47A6),
    accent: Color(0xFF9FD3FF),
    onAccent: Color(0xFF10306F),
  );

  static const derecha = AsambleaBoardPalette(
    light: Color(0xFFC8323F),
    dark: Color(0xFF7D1424),
    accent: Color(0xFFFF8F8F),
    onAccent: Color(0xFF5C0D19),
  );
}

/// Tablero de leyes de un bando: cabecera con emblema, una fila de casillas
/// altas (como cartas de ley) que ocupa todo el alto disponible y, debajo,
/// la leyenda de poderes. La última casilla es la victoria.
class AsambleaLawBoard extends StatelessWidget {
  final String title;
  final IconData emblem;
  final int total;
  final int active;
  final AsambleaBoardPalette palette;

  /// Icono del poder de cada casilla (1..total), si lo tiene.
  final Map<int, IconData> powers;

  /// Explicación de los iconos de poder.
  final List<(IconData, String)> legend;
  final bool compact;

  const AsambleaLawBoard({
    super.key,
    required this.title,
    required this.emblem,
    required this.total,
    required this.active,
    required this.palette,
    this.powers = const {},
    this.legend = const [],
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(compact ? 24 : 28);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.light, palette.dark],
        ),
        border: Border.all(color: CuboColors.whiteA(0.28), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: palette.dark.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _StripesPainter(CuboColors.whiteA(0.05)),
          child: Stack(
            children: [
              // Emblema enorme y muy tenue como marca de agua.
              Positioned(
                right: -30,
                bottom: -40,
                child: Icon(
                  emblem,
                  size: compact ? 170 : 220,
                  color: CuboColors.whiteA(0.07),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 12 : 16,
                  compact ? 12 : 16,
                  compact ? 12 : 16,
                  compact ? 12 : 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _header(),
                    SizedBox(height: compact ? 10 : 14),
                    Expanded(child: _slots()),
                    if (legend.isNotEmpty) ...[
                      SizedBox(height: compact ? 8 : 10),
                      _legend(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final size = compact ? 36.0 : 42.0;
    return Row(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: CuboColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: palette.dark.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(emblem, color: palette.dark, size: size * 0.55),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              tr(title).toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 19 : 23,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: CuboColors.whiteA(0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: CuboColors.whiteA(0.3)),
          ),
          child: Text(
            '$active/$total',
            style: TextStyle(
              color: CuboColors.white,
              fontSize: compact ? 16 : 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  /// Proporción máxima alto/ancho de una casilla, para que no queden como
  /// palillos en pantallas muy altas.
  static const double _maxSlotRatio = 2.4;

  Widget _slots() {
    return LayoutBuilder(
      builder: (context, box) {
        final gap = compact ? 5.0 : 7.0;
        final slotWidth = (box.maxWidth - gap * (total - 1)) / total;
        final height = box.maxHeight.clamp(0.0, slotWidth * _maxSlotRatio);
        return Center(
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 1; i <= total; i++) ...[
                  if (i > 1) SizedBox(width: gap),
                  Expanded(child: _slot(i)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _slot(int number) {
    final filled = number <= active;
    final isGoal = number == total;
    final power = powers[number];
    final radius = BorderRadius.circular(compact ? 12 : 14);

    final Widget content;
    if (filled) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(emblem, color: palette.onAccent, size: compact ? 24 : 30),
          const SizedBox(height: 4),
          Text(
            tr('LEY'),
            style: TextStyle(
              color: palette.onAccent,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    } else {
      final icon = isGoal ? Icons.emoji_events_rounded : power;
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: isGoal ? palette.accent : CuboColors.whiteA(0.85),
              size: compact ? 22 : 27,
            ),
          if (icon != null) const SizedBox(height: 4),
          Text(
            '$number',
            style: TextStyle(
              color: CuboColors.whiteA(icon == null ? 0.75 : 0.5),
              fontSize: icon == null
                  ? (compact ? 22 : 28)
                  : (compact ? 12 : 13),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: filled ? palette.accent : Colors.black.withValues(alpha: 0.16),
        border: Border.all(
          color: filled
              ? CuboColors.white
              : isGoal
              ? palette.accent.withValues(alpha: 0.8)
              : CuboColors.whiteA(0.22),
          width: filled || isGoal ? 2 : 1.2,
        ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: content),
      ),
    );
  }

  Widget _legend() {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final (icon, text) in legend)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: CuboColors.whiteA(0.8), size: 15),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(
                  color: CuboColors.whiteA(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Rayas diagonales muy suaves para dar textura de tablero.
class _StripesPainter extends CustomPainter {
  final Color color;

  const _StripesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 10;
    const gap = 26.0;
    for (var x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => oldDelegate.color != color;
}
