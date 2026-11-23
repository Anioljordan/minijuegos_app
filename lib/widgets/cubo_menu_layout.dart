import 'package:flutter/material.dart' hide Text;

import '../core/app_settings.dart';
import 'app_logo_button.dart';
import 'app_settings_button.dart';
import 'cubo_game_widgets.dart';

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
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 28),
                            clipBehavior: Clip.none,
                            itemCount: games.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final game = games[index];
                              return CuboEntrance(
                                index: index + 1,
                                child: CuboGameTile(
                                  title: game.title,
                                  illustration: game.illustration,
                                  fallbackIcon: game.fallbackIcon,
                                  mirrored: mirrored,
                                  height: compact ? 64 : 70,
                                  accent: _accent,
                                  onTap: () => _open(context, game),
                                ),
                              );
                            },
                          ),
                        ),
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
