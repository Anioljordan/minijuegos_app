import 'package:flutter/material.dart' hide Text;

import 'cubo_widgets.dart';
import 'i18n_text.dart';

/// Categoría del juego: decide hacia qué lado va el título.
enum CuboTitleSide {
  /// Fiesta: título a la izquierda y dibujo a su derecha en la misma fila.
  fiesta,

  /// Chill: dibujo encima, todo alineado a la derecha.
  chill,
}

/// Título grande de un juego con su dibujo y la barrita de color. Es el
/// mismo en todas las pantallas de una categoría, para que no bailen
/// márgenes ni tamaños entre juegos.
class CuboGameTitle extends StatelessWidget {
  final String text;
  final CuboTitleSide side;
  final String? illustration;
  final bool compact;

  const CuboGameTitle(
    this.text, {
    super.key,
    required this.side,
    this.illustration,
    this.compact = false,
  });

  static double inset(bool compact) => compact ? 18 : 28;

  @override
  Widget build(BuildContext context) {
    return side == CuboTitleSide.fiesta ? _fiesta() : _chill();
  }

  TextStyle get _style => CuboText.title(size: compact ? 42 : 50);

  Widget _fiesta() {
    return Padding(
      padding: EdgeInsets.only(left: inset(compact)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(text, maxLines: 1, softWrap: false, style: _style),
                ),
              ),
              if (illustration != null) ...[
                const SizedBox(width: 8),
                CuboIllustration(illustration!, size: compact ? 64 : 84),
              ],
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          const CuboPillBar(width: 44, color: CuboColors.fiesta),
        ],
      ),
    );
  }

  Widget _chill() {
    return Padding(
      padding: EdgeInsets.only(right: inset(compact)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (illustration != null) ...[
            CuboIllustration(illustration!, size: compact ? 68 : 96),
            SizedBox(height: compact ? 4 : 6),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.right,
              style: _style,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          const CuboPillBar(width: 44, color: CuboColors.chill),
        ],
      ),
    );
  }
}
