import 'package:flutter/material.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';

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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
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

  Widget buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              onTap: () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            circleButton(
              onTap: () => showAsambleaRulesDialog(context),
              child: const Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 86,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'reparto\nde roles',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 42,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: 74,
                  left: 0,
                  right: -18,
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

  Widget buildInfoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: const BorderSide(
            color: leaderGold,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        'Jugador ${currentIndex + 1} de ${widget.players.length} · mira tu rol en secreto',
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  Widget buildMainCard(AsambleaPlayer player, AsambleaRole? role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: !revealed
            ? Column(
          key: const ValueKey('hidden'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'pasa el móvil a',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite.withOpacity(0.68),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              player.name.toLowerCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontSize: 42,
                height: 0.92,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: appWhite.withOpacity(0.85),
                  width: 2.2,
                ),
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: appWhite,
                size: 40,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Cuando esté listo, pulsa para ver su rol',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite.withOpacity(0.72),
                fontSize: 14,
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
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _roleColor(role).withOpacity(0.18),
                border: Border.all(
                  color: _roleColor(role).withOpacity(0.90),
                  width: 2.4,
                ),
              ),
              child: Icon(
                _roleIcon(role),
                color: appWhite,
                size: 42,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              _roleTitle(role).toLowerCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontSize: 42,
                height: 0.92,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: appWhite.withOpacity(0.08),
                border: Border(
                  left: BorderSide(
                    color: _roleColor(role),
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
                  color: appWhite.withOpacity(0.78),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final player = widget.players[currentIndex];
    final role = player.role;

    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              buildTopBar(),

              const SizedBox(height: 14),

              buildInfoBar(),

              const SizedBox(height: 18),

              Expanded(
                child: Center(
                  child: buildMainCard(player, role),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: mainButtonStyle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      !revealed
                          ? 'VER ROL'
                          : currentIndex == widget.players.length - 1
                          ? 'TERMINAR REPARTO'
                          : 'SIGUIENTE JUGADOR',
                      style: const TextStyle(
                        color: appBlue,
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
    );
  }
}