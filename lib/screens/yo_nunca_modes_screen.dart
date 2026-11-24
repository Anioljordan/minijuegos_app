import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'yo_nunca_screen.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class YoNuncaModesScreen extends StatelessWidget {
  const YoNuncaModesScreen({super.key});

  void abrirModo(BuildContext context, String modo) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => YoNuncaScreen(modo: modo)),
    );
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: null);
  }

  Widget buildTopBar(BuildContext context) {
    final compact = MediaQuery.of(context).size.height < 740;

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
              onTap: () => mostrarNormas(context),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CuboIllustration('yo_nunca', size: compact ? 72 : 104),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'yo nunca',
                  maxLines: 1,
                  style: CuboText.title(size: 46),
                ),
              ),
              const SizedBox(height: 12),
              const CuboPillBar(width: 44, color: CuboColors.fiesta),
            ],
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
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void mostrarNormas(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => CuboGameScope(
        child: Dialog(
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
                      'YO NUNCA',
                      style: TextStyle(
                        color: CuboColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 14),

                    rulesItem(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Yo Nunca',
                      text:
                          'El modo clásico. Aparece una frase de “Yo nunca...” y cada persona responde según si lo ha hecho o no.',
                    ),

                    rulesItem(
                      icon: Icons.groups_rounded,
                      title: 'Por equipos',
                      text:
                          'Una variante de Yo Nunca en la que los jugadores se dividen en equipos y compiten durante la partida.',
                    ),

                    rulesItem(
                      icon: Icons.visibility_off_rounded,
                      title: 'Lobo',
                      text:
                          'Una variante con identidades ocultas en la que tendrás que descubrir quién está jugando como lobo.',
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
                            maxLines: 1,
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
      ),
    );
  }

  /// Carta grande del modo clásico: icono sobre un círculo del acento,
  /// título, subtítulo y botón de jugar (mismo lenguaje que los menús).
  Widget buildFeaturedCard({required VoidCallback onTap}) {
    return CuboPressable(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight;
          return Container(
            decoration: CuboDecorations.playCard,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned(
                  right: -h * 0.18,
                  top: -h * 0.1,
                  bottom: -h * 0.1,
                  child: Container(
                    width: h * 1.2,
                    decoration: BoxDecoration(
                      color: CuboColors.fiesta.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: h * 0.12,
                  top: 0,
                  bottom: 0,
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    color: CuboColors.blue,
                    size: h * 0.42,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yo Nunca', style: CuboText.cardPhrase(size: 30)),
                      const SizedBox(height: 4),
                      Text(
                        'El clásico de siempre',
                        style: TextStyle(
                          color: CuboColors.blueInk.withValues(alpha: 0.65),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
          );
        },
      ),
    );
  }

  /// Carta de variante: icono grande en un recuadro y título abajo.
  /// [highlighted] la pinta en el acento.
  Widget buildModeCard({
    required String title,
    required IconData icon,
    required Color accent,
    required bool highlighted,
    required VoidCallback onTap,
  }) {
    return CuboPressable(
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
                  builder: (context, c) => Icon(
                    icon,
                    color: CuboColors.blue,
                    size: (c.maxHeight * 0.5).clamp(28.0, 72.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuboColors.blue,
      body: CuboGameScope(
        child: CuboBackground(
          halo: CuboHalo.topRight,
          accent: CuboColors.fiesta,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 380;
                final compact = constraints.maxHeight < 680;
                final gap = compact ? 12.0 : 14.0;
                final featuredHeight = (constraints.maxHeight * 0.3).clamp(
                  170.0,
                  240.0,
                );

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    narrow ? 14 : 20,
                    18,
                    narrow ? 14 : 20,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildTopBar(context),
                      SizedBox(height: compact ? 18 : 26),
                      SizedBox(
                        height: featuredHeight,
                        child: CuboEntrance(
                          index: 1,
                          child: buildFeaturedCard(
                            onTap: () => abrirModo(context, 'normal'),
                          ),
                        ),
                      ),
                      SizedBox(height: gap),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: CuboEntrance(
                                index: 2,
                                child: buildModeCard(
                                  title: 'Yo Nunca por equipos',
                                  icon: Icons.groups_rounded,
                                  accent: CuboColors.fiesta,
                                  highlighted: false,
                                  onTap: () => abrirModo(context, 'equipos'),
                                ),
                              ),
                            ),
                            SizedBox(width: gap),
                            Expanded(
                              child: CuboEntrance(
                                index: 3,
                                child: buildModeCard(
                                  title: 'Yo Nunca Lobo',
                                  icon: Icons.visibility_off_rounded,
                                  accent: CuboColors.fiesta,
                                  highlighted: true,
                                  onTap: () => abrirModo(context, 'lobo'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
