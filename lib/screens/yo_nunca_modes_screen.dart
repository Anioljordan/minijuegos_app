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

  Widget buildModeCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool compact,
  }) {
    return CuboModeCard(
      title: title,
      icon: icon,
      iconBackground: color,
      compact: compact,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final modes = [
      (
        title: 'Yo Nunca',
        icon: Icons.chat_bubble_outline_rounded,
        color: CuboColors.fiesta,
        modo: 'normal',
      ),
      (
        title: 'Yo Nunca por equipos',
        icon: Icons.groups_rounded,
        color: CuboColors.white,
        modo: 'equipos',
      ),
      (
        title: 'Yo Nunca Lobo',
        icon: Icons.visibility_off_rounded,
        color: CuboColors.chill,
        modo: 'lobo',
      ),
    ];

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
                final veryNarrow = constraints.maxWidth < 340;
                final compact = constraints.maxHeight < 680;

                final horizontalPadding = veryNarrow
                    ? 10.0
                    : narrow
                    ? 14.0
                    : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 38,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          buildTopBar(context),
                          const Spacer(),
                          SizedBox(height: compact ? 20 : 28),
                          for (var i = 0; i < modes.length; i++) ...[
                            if (i > 0) SizedBox(height: compact ? 10 : 14),
                            CuboEntrance(
                              index: i + 1,
                              child: buildModeCard(
                                title: modes[i].title,
                                icon: modes[i].icon,
                                color: modes[i].color,
                                compact: compact,
                                onTap: () => abrirModo(context, modes[i].modo),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
