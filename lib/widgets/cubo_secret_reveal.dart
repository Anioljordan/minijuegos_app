import 'package:flutter/material.dart' hide Text;

import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

/// Carta secreta que se pasa de mano en mano (Impostor, La Asamblea).
///
/// Una tapa con el nombre del jugador cubre el secreto ([face]). Se arrastra
/// hacia arriba para verlo y hacia abajo para ocultarlo. Al subir deja una
/// franja con un asa dentro de la carta para poder bajarla otra vez.
/// [revealKey] identifica al jugador: al cambiar, la tapa vuelve a bajar.
class CuboSecretReveal extends StatefulWidget {
  final Object revealKey;
  final String playerName;
  final Color accent;
  final Widget face;

  /// Se llama cada vez que la tapa queda subida del todo.
  final VoidCallback? onRevealed;

  const CuboSecretReveal({
    super.key,
    required this.revealKey,
    required this.playerName,
    required this.face,
    this.accent = CuboColors.chill,
    this.onRevealed,
  });

  @override
  State<CuboSecretReveal> createState() => _CuboSecretRevealState();
}

class _CuboSecretRevealState extends State<CuboSecretReveal>
    with SingleTickerProviderStateMixin {
  /// Alto de la franja de tapa que queda visible al subirla.
  static const double _handleHeight = 58;

  /// Fracción de subida a partir de la cual el secreto cuenta como visto:
  /// basta con levantar la tapa hasta la mitad.
  static const double _revealAt = 0.45;

  /// Velocidad (px/s) a partir de la cual un gesto abre o cierra del todo.
  static const double _flingVelocity = 500;

  late final AnimationController _lift = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  double _travel = 1;

  @override
  void didUpdateWidget(covariant CuboSecretReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealKey != widget.revealKey) _lift.value = 0;
  }

  @override
  void dispose() {
    _lift.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _lift.value = (_lift.value - details.delta.dy / _travel).clamp(0.0, 1.0);
    if (_lift.value >= _revealAt) widget.onRevealed?.call();
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final open = velocity < -_flingVelocity
        ? true
        : velocity > _flingVelocity
        ? false
        : _lift.value >= 0.5;
    _settle(open);
  }

  Future<void> _settle(bool open) async {
    await _lift.animateTo(open ? 1 : 0, curve: Curves.easeOutCubic);
    if (open && mounted) widget.onRevealed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        _travel = (height - _handleHeight).clamp(1.0, double.infinity);
        return ClipRRect(
          borderRadius: CuboRadii.xlAll,
          child: Container(
            decoration: CuboDecorations.glassRaised(radius: CuboRadii.xl),
            child: Stack(
              children: [
                Positioned.fill(
                  top: _handleHeight,
                  child: AnimatedBuilder(
                    animation: _lift,
                    builder: (context, child) => Opacity(
                      opacity: const Interval(0.1, _revealAt).transform(_lift.value),
                      child: child,
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: height - _handleHeight - 32,
                        ),
                        child: Center(child: widget.face),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _lift,
                  builder: (context, child) => Positioned(
                    left: 0,
                    right: 0,
                    top: -_lift.value * _travel,
                    height: height,
                    child: child!,
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: _SecretCover(
                      playerName: widget.playerName,
                      accent: widget.accent,
                      handleHeight: _handleHeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SecretCover extends StatelessWidget {
  final String playerName;
  final Color accent;
  final double handleHeight;

  const _SecretCover({
    required this.playerName,
    required this.accent,
    required this.handleHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuboColors.blueLight, CuboColors.blue],
        ),
        borderRadius: CuboRadii.xlAll,
        border: Border.all(color: accent, width: 2.4),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              // En pantallas bajas el contenido se encoge en vez de desbordar.
              child: LayoutBuilder(
                builder: (context, c) => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: c.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: CuboColors.blueInk,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const CuboStatusChip(
                          'TARJETA SECRETA',
                          icon: Icons.visibility_off_rounded,
                        ),
                        const SizedBox(height: 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            playerName.toLowerCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: CuboColors.white,
                              fontSize: 48,
                              height: 0.95,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          color: accent,
                          size: 34,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ARRASTRA DESDE AQUÍ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'sube para revelar · baja para ocultar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.whiteA(0.66),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: handleHeight,
            child: Center(
              child: Container(
                width: 56,
                height: 6,
                decoration: BoxDecoration(
                  color: CuboColors.whiteA(0.7),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contenido del secreto: icono, etiqueta, título grande y, si hay,
/// descripción y un elemento extra (p. ej. la pista del impostor).
class CuboSecretFace extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String title;
  final String? description;
  final Widget? extra;

  const CuboSecretFace({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.title,
    this.description,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: CuboColors.blueInk, size: 42),
        ),
        const SizedBox(height: 16),
        Text(
          tr(label).toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CuboColors.whiteA(0.66),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CuboColors.white,
            fontSize: 38,
            height: 1.0,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CuboColors.whiteA(0.12),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CuboColors.whiteA(0.86),
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        if (extra != null) ...[const SizedBox(height: 14), extra!],
        const SizedBox(height: 16),
        Text(
          'Baja la tarjeta para ocultarlo antes de pasar el móvil.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: CuboColors.whiteA(0.55),
            fontSize: 12.5,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// "JUGADOR X DE Y" con barra de progreso.
class CuboRevealProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color accent;

  const CuboRevealProgress({
    super.key,
    required this.current,
    required this.total,
    this.accent = CuboColors.chill,
  });

  @override
  Widget build(BuildContext context) {
    final value = total == 0 ? 0.0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'JUGADOR $current DE $total',
          style: TextStyle(
            color: CuboColors.whiteA(0.72),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: CuboColors.whiteA(0.14),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      ],
    );
  }
}

/// Botón para pasar al siguiente jugador. Hasta que se ha visto el secreto
/// ([enabled] falso) pide arrastrar la tarjeta.
class CuboRevealNextButton extends StatelessWidget {
  final bool enabled;
  final bool isLast;
  final String lastLabel;
  final IconData lastIcon;
  final VoidCallback onTap;
  final Color accent;

  const CuboRevealNextButton({
    super.key,
    required this.enabled,
    required this.isLast,
    required this.lastLabel,
    required this.lastIcon,
    required this.onTap,
    this.accent = CuboColors.chill,
  });

  @override
  Widget build(BuildContext context) {
    final label = !enabled
        ? 'ARRASTRA LA TARJETA'
        : isLast
        ? lastLabel
        : 'SIGUIENTE JUGADOR';
    final icon = !enabled
        ? Icons.keyboard_double_arrow_up_rounded
        : isLast
        ? lastIcon
        : Icons.arrow_forward_rounded;
    final fg = enabled ? CuboColors.blueInk : CuboColors.whiteA(0.55);

    return CuboPressable(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 64,
        decoration: BoxDecoration(
          color: enabled ? accent : CuboColors.whiteA(0.12),
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(
            color: enabled ? accent : CuboColors.whiteA(0.28),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 28),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
