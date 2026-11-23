import 'package:flutter/material.dart' hide Text;

import '../core/app_settings.dart';
import 'app_logo_button.dart';
import 'app_settings_button.dart';
import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

/// Un juego del menú: título (clave de traducción), ilustración y pantalla.
class CuboMenuGame {
  final String title;
  final String illustration;
  final IconData fallbackIcon;
  final WidgetBuilder builder;

  const CuboMenuGame({
    required this.title,
    required this.illustration,
    required this.fallbackIcon,
    required this.builder,
  });
}

/// Maqueta compartida de los menús Fiesta y Chill. [mirrored] alinea todo a
/// la derecha (Chill) para conservar el efecto espejo.
class CuboMenuLayout extends StatelessWidget {
  final String title;
  final String heroIllustration;
  final bool mirrored;
  final List<CuboMenuGame> games;

  const CuboMenuLayout({
    super.key,
    required this.title,
    required this.heroIllustration,
    required this.mirrored,
    required this.games,
  });

  /// Chill va en espejo; Fiesta no.
  Color get _accent => mirrored ? CuboColors.chill : CuboColors.fiesta;

  Widget _topIcons(BuildContext context, bool compact) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 35, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppLogoButton(compact: compact, onTap: () => Navigator.pop(context)),
          const AppSettingsButton(
            blue: CuboColors.blue,
            white: CuboColors.white,
          ),
        ],
      ),
    );
  }

  Widget _titleBlock(bool compact) {
    final heroSize = compact ? 116.0 : 150.0;
    final hero = CuboIllustration(
      heroIllustration,
      size: heroSize,
      opacity: 0.55,
    );
    final titleWidget = CuboSectionTitle(
      title,
      alignEnd: mirrored,
      size: compact ? 58 : 66,
      barColor: _accent,
    );

    return SizedBox(
      height: heroSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: mirrored ? -10 : null,
            right: mirrored ? null : -10,
            child: hero,
          ),
          Align(
            alignment: mirrored ? Alignment.bottomRight : Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: mirrored ? 0 : 6,
                right: mirrored ? 6 : 0,
                bottom: 6,
              ),
              child: titleWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gamesGrid(BuildContext context, bool compact) {
    final featured = games.first;
    final rest = games.skip(1).toList();
    return CustomScrollView(
      clipBehavior: Clip.none,
      slivers: [
        SliverToBoxAdapter(
          child: CuboEntrance(
            index: 1,
            child: _FeaturedGameCard(
              game: featured,
              accent: _accent,
              height: compact ? 150 : 176,
              onTap: () => _open(context, featured),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: compact ? 1.05 : 0.95,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => CuboEntrance(
              index: index + 2,
              child: _GridGameCard(
                game: rest[index],
                accent: _accent,
                highlighted: index % 3 == 2,
                onTap: () => _open(context, rest[index]),
              ),
            ),
            childCount: rest.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }

  void _open(BuildContext context, CuboMenuGame game) {
    Navigator.push(context, MaterialPageRoute(builder: game.builder));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        final compact = MediaQuery.sizeOf(context).height < 740;
        return Scaffold(
          backgroundColor: CuboColors.blue,
          body: CuboGameBackground(
            accent: _accent,
            halo: mirrored ? CuboHalo.topLeft : CuboHalo.topRight,
            child: Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, compact ? 92 : 120, 24, 0),
                    child: Column(
                      crossAxisAlignment: mirrored
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        CuboEntrance(child: _titleBlock(compact)),
                        SizedBox(height: compact ? 24 : 40),
                        Expanded(child: _gamesGrid(context, compact)),
                      ],
                    ),
                  ),
                ),
                _topIcons(context, compact),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Carta grande del primer juego: ilustración sobre un círculo del acento,
/// título y botón de jugar.
class _FeaturedGameCard extends StatelessWidget {
  final CuboMenuGame game;
  final Color accent;
  final double height;
  final VoidCallback onTap;

  const _FeaturedGameCard({
    required this.game,
    required this.accent,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tr(game.title),
      excludeSemantics: true,
      child: CuboPressable(
        onTap: onTap,
        child: Container(
          height: height,
          decoration: CuboDecorations.playCard,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -16,
                bottom: -16,
                child: Container(
                  width: height * 1.1,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CuboIllustration(
                    game.illustration,
                    onBlue: false,
                    size: height * 0.66,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: height * 1.0,
                      child: Text(
                        game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CuboText.cardPhrase(size: 27),
                      ),
                    ),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: const BoxDecoration(
                        color: CuboColors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: CuboColors.white,
                            size: 24,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'JUGAR',
                            style: TextStyle(
                              color: CuboColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carta de la cuadrícula: ilustración grande arriba y título abajo.
/// [highlighted] la pinta en el acento del modo.
class _GridGameCard extends StatelessWidget {
  final CuboMenuGame game;
  final Color accent;
  final bool highlighted;
  final VoidCallback onTap;

  const _GridGameCard({
    required this.game,
    required this.accent,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tr(game.title),
      excludeSemantics: true,
      child: CuboPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: highlighted ? accent : CuboColors.paper,
            borderRadius: CuboRadii.cardAll,
            boxShadow: CuboShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? CuboColors.white.withValues(alpha: 0.45)
                        : CuboColors.blueTint,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: LayoutBuilder(
                    builder: (context, c) => CuboIllustration(
                      game.illustration,
                      onBlue: false,
                      size: c.maxHeight * 0.78,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CuboColors.blueInk,
                    fontSize: 17,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
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
