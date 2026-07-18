import 'package:flutter/material.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';

class AsambleaRolesScreen extends StatefulWidget {
  final List<AsambleaPlayer> players;

  const AsambleaRolesScreen({
    super.key,
    required this.players,
  });

  @override
  State<AsambleaRolesScreen> createState() => _AsambleaRolesScreenState();
}

class _AsambleaRolesScreenState extends State<AsambleaRolesScreen> {
  int currentIndex = 0;
  bool revealed = false;

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color leftBlue = Color(0xFF60A5FA);
  static const Color rightRed = Color(0xFFE63946);
  static const Color leaderGold = Color(0xFFFFD166);

  String _roleTitle(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Izquierda';
      case AsambleaRole.derecha:
        return 'Derecha';
      case AsambleaRole.liderOculto:
        return 'Líder Oculto';
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
        return 'Eres el Líder Oculto. Debes llegar al poder sin que te descubran.';
      default:
        return '';
    }
  }

  Color _roleColor(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return leftBlue;
      case AsambleaRole.derecha:
        return rightRed;
      case AsambleaRole.liderOculto:
        return leaderGold;
      default:
        return appWhite;
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

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: appWhite,
      side: BorderSide(
        color: appWhite.withOpacity(0.70),
        width: 2,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
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
          border: Border.all(
            color: appWhite.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;

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
                    color: appWhite,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: compact ? 14 : 24),

        Padding(
          padding: EdgeInsets.only(
            right: compact ? 18 : 28,
          ),
          child: SizedBox(
            width: double.infinity,
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: Text(
                        'reparto de roles',
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 1.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: lineTop,
                  left: compact ? -13 : -18,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget buildMainCard(
      AsambleaPlayer player,
      AsambleaRole? role, {
        required bool compact,
      }) {
    final roleColor = _roleColor(role);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 24,
              vertical: compact ? 18 : 28,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - (compact ? 36 : 56))
                    .clamp(0.0, double.infinity).toDouble(),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: !revealed
                      ? Column(
                    key: const ValueKey('hidden'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PASA EL MÓVIL A',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite.withOpacity(0.68),
                          fontSize: compact ? 11.5 : 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.9,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          player.name.toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite,
                            fontSize: compact ? 34 : 43,
                            height: 0.94,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 20 : 28),
                      Container(
                        width: compact ? 76 : 92,
                        height: compact ? 76 : 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appWhite.withOpacity(0.14),
                          border: Border.all(
                            color: appWhite,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          Icons.phone_android_rounded,
                          color: appWhite,
                          size: compact ? 38 : 47,
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 20),
                      Text(
                        'Cuando esté listo, pulsa para revelar su rol.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite.withOpacity(0.72),
                          fontSize: compact ? 13 : 14,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    key: const ValueKey('revealed'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: compact ? 80 : 98,
                        height: compact ? 80 : 98,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: roleColor.withOpacity(0.18),
                          border: Border.all(
                            color: roleColor,
                            width: 2.7,
                          ),
                        ),
                        child: Icon(
                          _roleIcon(role),
                          color: roleColor,
                          size: compact ? 40 : 50,
                        ),
                      ),
                      SizedBox(height: compact ? 16 : 22),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _roleTitle(role).toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite,
                            fontSize: compact ? 35 : 44,
                            height: 0.94,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(compact ? 12 : 15),
                        decoration: BoxDecoration(
                          color: appWhite.withOpacity(0.08),
                          border: Border(
                            left: BorderSide(
                              color: roleColor,
                              width: 6,
                            ),
                            bottom: BorderSide(
                              color: appWhite.withOpacity(0.28),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _roleDescription(role),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite.withOpacity(0.80),
                            fontSize: compact ? 13 : 14,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _nextStep() {
    if (!revealed) {
      setState(() {
        revealed = true;
      });
      return;
    }

    if (currentIndex < widget.players.length - 1) {
      setState(() {
        currentIndex++;
        revealed = false;
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

  Widget _buildNextButton({
    required bool compact,
    required AsambleaRole? role,
  }) {
    final color = revealed ? _roleColor(role) : appWhite;
    final icon = !revealed
        ? Icons.visibility_rounded
        : currentIndex == widget.players.length - 1
        ? Icons.play_arrow_rounded
        : Icons.arrow_forward_rounded;
    final label = !revealed
        ? 'VER ROL'
        : currentIndex == widget.players.length - 1
        ? 'EMPEZAR PARTIDA'
        : 'SIGUIENTE JUGADOR';

    return SizedBox(
      width: double.infinity,
      height: compact ? 70 : 82,
      child: Material(
        color: color,
        child: InkWell(
          onTap: _nextStep,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: appWhite.withOpacity(0.30),
                width: 2.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 17,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: role == AsambleaRole.derecha ? appWhite : appBlue,
                  size: compact ? 31 : 37,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: role == AsambleaRole.derecha ? appWhite : appBlue,
                      fontSize: compact ? 13.5 : 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.players[currentIndex];
    final role = player.role;

    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 740;
            final horizontalPadding = compact ? 13.0 : 18.0;
            final verticalPadding = compact ? 11.0 : 18.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                compact ? 11 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(compact: compact),

                  SizedBox(height: compact ? 10 : 16),
                  Expanded(
                    child: buildMainCard(
                      player,
                      role,
                      compact: compact,
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 14),
                  _buildNextButton(
                    compact: compact,
                    role: role,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
