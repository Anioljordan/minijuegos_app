import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/cubo_ui.dart';
import 'i18n_text.dart';

export '../core/cubo_ui.dart';

/// Dónde cae el halo de luz principal del fondo.
enum CuboHalo { topRight, topLeft }

/// Fondo de la app: degradado vertical azul → azul profundo con halos
/// radiales muy suaves. En Fiesta el halo va arriba a la derecha y en Chill
/// arriba a la izquierda.
class CuboBackground extends StatelessWidget {
  final Widget child;
  final CuboHalo halo;

  const CuboBackground({
    super.key,
    required this.child,
    this.halo = CuboHalo.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final right = halo == CuboHalo.topRight;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuboColors.blue, CuboColors.blueDeep],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150,
            right: right ? -130 : null,
            left: right ? null : -130,
            child: const _Halo(size: 420, alpha: 0.55),
          ),
          Positioned(
            bottom: -170,
            left: right ? -150 : null,
            right: right ? null : -150,
            child: const _Halo(size: 360, alpha: 0.28),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Halo extends StatelessWidget {
  final double size;
  final double alpha;

  const _Halo({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              CuboColors.blueLight.withValues(alpha: alpha),
              CuboColors.blueLight.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barrita corta en píldora que sustituye a la línea fina bajo los títulos.
class CuboPillBar extends StatelessWidget {
  final double width;
  final double height;
  final double alpha;

  const CuboPillBar({
    super.key,
    this.width = 56,
    this.height = 6,
    this.alpha = 0.92,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CuboColors.whiteA(alpha),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

/// Título grande en minúscula con la barrita en píldora debajo.
class CuboSectionTitle extends StatelessWidget {
  final String text;
  final bool alignEnd;
  final double size;
  final double gap;

  const CuboSectionTitle(
    this.text, {
    super.key,
    this.alignEnd = false,
    this.size = 66,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd ? Alignment.centerRight : Alignment.centerLeft;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            style: CuboText.title(size: size),
          ),
        ),
        SizedBox(height: gap),
        const CuboPillBar(),
      ],
    );
  }
}

/// Envoltorio que encoge ligeramente al pulsar y da un toque háptico.
class CuboPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const CuboPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedScale = 0.96,
  });

  @override
  State<CuboPressable> createState() => _CuboPressableState();
}

class _CuboPressableState extends State<CuboPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _setPressed(true) : null,
      onTapUp: enabled ? (_) => _setPressed(false) : null,
      onTapCancel: enabled ? () => _setPressed(false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Botón circular contorneado (normas, volver...). Mismo aspecto que los
/// botones circulares de logo y ajustes.
class CuboCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final String? tooltip;

  const CuboCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 50,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = CuboPressable(
      onTap: onTap,
      pressedScale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CuboColors.whiteA(0.08),
          border: Border.all(color: CuboColors.whiteA(0.85), width: 2.2),
        ),
        child: Icon(icon, color: CuboColors.white, size: size * 0.54),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tr(tooltip!), child: button);
  }
}

/// Entrada escalonada: fade y desplazamiento de 24 px hacia arriba.
class CuboEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration step;
  final Duration duration;
  final double offset;

  const CuboEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.step = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 420),
    this.offset = 24,
  });

  @override
  State<CuboEntrance> createState() => _CuboEntranceState();
}

class _CuboEntranceState extends State<CuboEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    final delay = widget.step * widget.index;
    final total = delay + widget.duration;
    _controller = AnimationController(vsync: this, duration: total)..forward();
    final start = total.inMicroseconds == 0
        ? 0.0
        : delay.inMicroseconds / total.inMicroseconds;
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final t = _progress.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Ilustraciones de los juegos (assets/images/juegos). Son bicolor: no se
/// les aplica colorFilter.
class CuboIllustration extends StatelessWidget {
  final String name;
  final bool onBlue;
  final double size;
  final double opacity;

  /// Escala sutil al aparecer (pantallas de resultado).
  final bool popIn;

  const CuboIllustration(
    this.name, {
    super.key,
    this.onBlue = true,
    this.size = 108,
    this.opacity = 1,
    this.popIn = false,
  });

  static String assetPath(String name, {required bool onBlue}) {
    final folder = onBlue ? 'on_blue' : 'on_light';
    return 'assets/images/juegos/$folder/$name.svg';
  }

  @override
  Widget build(BuildContext context) {
    Widget image = SvgPicture.asset(
      assetPath(name, onBlue: onBlue),
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
    if (opacity < 1) image = Opacity(opacity: opacity, child: image);
    if (!popIn) return image;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      child: image,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.82 + 0.18 * t, child: child),
        );
      },
    );
  }
}
