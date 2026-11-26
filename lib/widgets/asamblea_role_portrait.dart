import 'package:flutter/material.dart' hide Text;

import '../screens/asamblea_setup_screen.dart';
import 'cubo_widgets.dart';
import 'i18n_text.dart';

/// Datos visuales de cada rol de La Asamblea: nombre, color y personaje.
class AsambleaRoleStyle {
  final String title;
  final Color color;
  final String illustration;

  const AsambleaRoleStyle._(this.title, this.color, this.illustration);

  static AsambleaRoleStyle of(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.derecha:
        return const AsambleaRoleStyle._(
          'Derecha',
          CuboColors.alert,
          'asamblea_derecha',
        );
      case AsambleaRole.liderOculto:
        return const AsambleaRoleStyle._(
          'Dictador',
          CuboColors.fiesta,
          'asamblea_dictador',
        );
      case AsambleaRole.izquierda:
      case null:
        return const AsambleaRoleStyle._(
          'Izquierda',
          CuboColors.chill,
          'asamblea_izquierda',
        );
    }
  }
}

/// Personaje del rol sobre un halo de su color. Solo es decoración: el
/// texto del rol lo pone quien lo usa.
class AsambleaRolePortrait extends StatelessWidget {
  final AsambleaRole? role;
  final double size;

  const AsambleaRolePortrait({super.key, required this.role, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final style = AsambleaRoleStyle.of(role);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    style.color.withValues(alpha: 0.55),
                    style.color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          CuboIllustration(style.illustration, size: size * 0.94),
        ],
      ),
    );
  }
}

/// Cara de la carta secreta: solo "TU ROL", el nombre del rol y su
/// personaje grande.
class AsambleaRoleFace extends StatelessWidget {
  final AsambleaRole? role;

  const AsambleaRoleFace({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final style = AsambleaRoleStyle.of(role);
    final portrait = (MediaQuery.sizeOf(context).height * 0.3).clamp(
      150.0,
      280.0,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tr('TU ROL'),
          style: TextStyle(
            color: CuboColors.whiteA(0.66),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr(style.title),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: style.color,
            fontSize: 42,
            height: 1.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 12),
        AsambleaRolePortrait(role: role, size: portrait),
      ],
    );
  }
}
