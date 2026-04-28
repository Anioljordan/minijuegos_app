import 'package:flutter/material.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_board_screen.dart';

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
        return const Color(0xFF2563EB);
      case AsambleaRole.derecha:
        return const Color(0xFFDC2626);
      case AsambleaRole.liderOculto:
        return const Color(0xFFF59E0B);
      default:
        return Colors.white;
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
      backgroundColor: const Color(0xFF08051A),
      appBar: AppBar(
        title: const Text('Reparto de roles'),
        backgroundColor: const Color(0xFF08051A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF15112B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Pasa el móvil a:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    player.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (!revealed) ...[
                    const Icon(
                      Icons.phone_android,
                      color: Colors.white70,
                      size: 46,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Cuando esté listo, pulsa para ver su rol',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      _roleIcon(role),
                      color: _roleColor(role),
                      size: 58,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _roleTitle(role),
                      style: TextStyle(
                        color: _roleColor(role),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _roleDescription(role),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: revealed
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  !revealed
                      ? 'Ver rol'
                      : currentIndex == widget.players.length - 1
                      ? 'Terminar reparto'
                      : 'Siguiente jugador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}