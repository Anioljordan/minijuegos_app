import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/cubo_secret_reveal.dart';

class AsambleaRolesScreen extends StatefulWidget {
  final List<AsambleaPlayer> players;

  const AsambleaRolesScreen({super.key, required this.players});

  @override
  State<AsambleaRolesScreen> createState() => _AsambleaRolesScreenState();
}

class _AsambleaRolesScreenState extends State<AsambleaRolesScreen> {
  int currentIndex = 0;

  /// El jugador actual ya ha levantado su carta secreta.
  bool _roleHasBeenRevealed = false;

  String _roleTitle(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Izquierda';

      case AsambleaRole.derecha:
        return 'Derecha';

      case AsambleaRole.liderOculto:
        return 'Dictador';

      default:
        return '';
    }
  }

  String _roleDescription(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Tu objetivo es aprobar 5 leyes de izquierda o eliminar al Líder Oculto.';

      case AsambleaRole.derecha:
        return 'Tu objetivo es aprobar 6 leyes de derecha o ayudar al Líder Oculto a llegar al poder.';

      case AsambleaRole.liderOculto:
        return 'Eres el Dictador. Debes llegar al poder sin que te descubran.';

      default:
        return '';
    }
  }

  Color _roleColor(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return CuboColors.chill;

      case AsambleaRole.derecha:
        return CuboColors.alert;

      case AsambleaRole.liderOculto:
        return CuboColors.fiesta;

      default:
        return CuboColors.white;
    }
  }

  IconData _roleIcon(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return Icons.shield_outlined;

      case AsambleaRole.derecha:
        return Icons.gavel_outlined;

      case AsambleaRole.liderOculto:
        return Icons.visibility_off_outlined;

      default:
        return Icons.help_outline;
    }
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CuboColors.whiteA(0.08),
          border: Border.all(color: CuboColors.whiteA(0.85), width: 2.2),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;

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

            Row(
              children: [
                circleButton(
                  compact: compact,
                  onTap: () => showAsambleaRulesDialog(context),
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: CuboColors.white,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 20),

        Padding(
          padding: EdgeInsets.only(right: compact ? 4 : 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CuboSectionTitle(
                  barColor: CuboColors.chill,
                  'reparto de roles',
                  alignEnd: true,
                  size: titleSize,
                  gap: compact ? 8 : 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (!_roleHasBeenRevealed) {
      return;
    }

    if (currentIndex < widget.players.length - 1) {
      setState(() {
        currentIndex++;

        // El siguiente jugador todavía no ha visto su rol.
        _roleHasBeenRevealed = false;
      });

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AsambleaBoardScreen(players: widget.players),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.players[currentIndex];
    final role = player.role;

    return Scaffold(
      backgroundColor: CuboColors.blue,
      body: CuboGameBackground(
        accent: CuboColors.chill,
        halo: CuboHalo.topLeft,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 740;
              final horizontalPadding = compact ? 13.0 : 18.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compact ? 11 : 18,
                  horizontalPadding,
                  compact ? 11 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),
                    SizedBox(height: compact ? 10 : 16),
                    CuboRevealProgress(
                      current: currentIndex + 1,
                      total: widget.players.length,
                    ),
                    SizedBox(height: compact ? 10 : 14),
                    Expanded(
                      child: CuboSecretReveal(
                        revealKey: currentIndex,
                        playerName: player.name,
                        onRevealed: () {
                          if (!_roleHasBeenRevealed) {
                            setState(() => _roleHasBeenRevealed = true);
                          }
                        },
                        face: CuboSecretFace(
                          icon: _roleIcon(role),
                          color: _roleColor(role),
                          label: 'TU ROL',
                          title: tr(_roleTitle(role)),
                          description: _roleDescription(role),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 10 : 14),
                    CuboRevealNextButton(
                      enabled: _roleHasBeenRevealed,
                      isLast: currentIndex == widget.players.length - 1,
                      lastLabel: 'EMPEZAR PARTIDA',
                      lastIcon: Icons.play_arrow_rounded,
                      onTap: _nextStep,
                    ),
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
