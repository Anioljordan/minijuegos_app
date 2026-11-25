import 'package:flutter/material.dart' hide Text;

import 'cubo_game_widgets.dart';
import 'cubo_menu_layout.dart';
import 'i18n_text.dart';

/// Formas de presentar los juegos en Fiesta y Chill (se elige en Ajustes).
enum CuboMenuStyle { destacado, carrusel }

/// Botón pequeño de jugar en azul.
class _PlayPill extends StatelessWidget {
  const _PlayPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: CuboColors.blue,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_arrow_rounded, color: CuboColors.white, size: 22),
          SizedBox(width: 4),
          Text(
            'JUGAR',
            style: TextStyle(
              color: CuboColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _tappable(CuboMenuGame game, VoidCallback onTap, Widget child) {
  return Semantics(
    button: true,
    label: tr(game.title),
    excludeSemantics: true,
    child: CuboPressable(onTap: onTap, child: child),
  );
}

/// Carrusel: cartas altas que se pasan de lado, con puntos debajo.
class CuboMenuCarousel extends StatefulWidget {
  final List<CuboMenuGame> games;
  final Color accent;
  final double height;
  final void Function(CuboMenuGame) onOpen;

  const CuboMenuCarousel({
    super.key,
    required this.games,
    required this.accent,
    required this.height,
    required this.onOpen,
  });

  @override
  State<CuboMenuCarousel> createState() => _CuboMenuCarouselState();
}

class _CuboMenuCarouselState extends State<CuboMenuCarousel> {
  final _controller = PageController(viewportFraction: 0.8);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _card(CuboMenuGame game, bool active) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 220),
      scale: active ? 1 : 0.9,
      child: _tappable(
        game,
        () => widget.onOpen(game),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          decoration: CuboDecorations.playCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) => CuboIllustration(
                      game.illustration,
                      onBlue: false,
                      size: c.maxHeight * 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CuboText.cardPhrase(size: 26),
              ),
              const SizedBox(height: 12),
              const _PlayPill(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            clipBehavior: Clip.none,
            itemCount: widget.games.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, i) => _card(widget.games[i], i == _page),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.games.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? widget.accent : CuboColors.whiteA(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
