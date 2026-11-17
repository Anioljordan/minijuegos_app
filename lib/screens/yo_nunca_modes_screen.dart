import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'yo_nunca_screen.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class YoNuncaModesScreen extends StatelessWidget {
  const YoNuncaModesScreen({super.key});

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);

  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPurple = Color(0xFF8B5CF6);

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
                  style: CuboText.title(size: 42),
                ),
              ),
              const SizedBox(height: 12),
              const CuboPillBar(),
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
                    'YO NUNCA',
                    style: TextStyle(
                      color: appWhite,
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
    );
  }

  Widget buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 170;

        final iconBoxSize = compact ? 58.0 : 82.0;

        final iconSize = compact ? 34.0 : 50.0;

        return CuboPressable(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18,
              vertical: compact ? 8 : 14,
            ),
            decoration: CuboDecorations.glass(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: iconSize),
                ),

                SizedBox(height: compact ? 7 : 11),

                SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tr(title).toUpperCase(),
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: compact ? 16 : 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: compact ? 3 : 6),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.72),
                    fontSize: compact ? 11 : 13,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: CuboBackground(
        halo: CuboHalo.topRight,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;

              final veryNarrow = constraints.maxWidth < 340;

              // Cabecera más alta por la ilustración sobre el título.
              final headerExtra =
                  MediaQuery.sizeOf(context).height < 740 ? 44.0 : 76.0;

              final availableForCards =
                  constraints.maxHeight - 220 - headerExtra;

              final cardHeight = ((availableForCards - 24) / 3).clamp(
                142.0,
                210.0,
              );

              final horizontalPadding = veryNarrow
                  ? 8.0
                  : narrow
                  ? 12.0
                  : 18.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 34,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTopBar(context),

                      const SizedBox(height: 18),

                      CuboEntrance(
                        index: 1,
                        child: SizedBox(
                          height: cardHeight,
                          child: buildModeCard(
                            title: 'Yo Nunca',
                            subtitle:
                                'El clásico. Lee la frase y responde si alguna vez lo has hecho.',
                            icon: Icons.chat_bubble_outline_rounded,
                            color: accentGreen,
                            onTap: () => abrirModo(context, 'normal'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      CuboEntrance(
                        index: 2,
                        child: SizedBox(
                          height: cardHeight,
                          child: buildModeCard(
                            title: 'Yo Nunca por equipos',
                            subtitle:
                                'Forma equipos y competid durante las rondas.',
                            icon: Icons.groups_rounded,
                            color: accentOrange,
                            onTap: () => abrirModo(context, 'equipos'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      CuboEntrance(
                        index: 3,
                        child: SizedBox(
                          height: cardHeight,
                          child: buildModeCard(
                            title: 'Yo Nunca Lobo',
                            subtitle:
                                'Un modo con identidades ocultas y sospechas.',
                            icon: Icons.visibility_off_rounded,
                            color: accentPurple,
                            onTap: () => abrirModo(context, 'lobo'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
