import 'package:flutter/material.dart' hide Text;

import 'app_logo_button.dart';
import 'cubo_widgets.dart';
import 'i18n_text.dart';

export 'cubo_widgets.dart';

/// Fila de juego de los menús Fiesta y Chill: tarjeta blanca con icono en un
/// cuadrado blueTint y flecha en un círculo azul. [mirrored] invierte el
/// orden (Chill).
class CuboGameTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final String? illustration;
  final IconData fallbackIcon;
  final bool mirrored;
  final double height;

  const CuboGameTile({
    super.key,
    required this.title,
    required this.onTap,
    this.illustration,
    this.fallbackIcon = Icons.casino_rounded,
    this.mirrored = false,
    this.height = 68,
  });

  @override
  Widget build(BuildContext context) {
    final iconBox = Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: CuboColors.blueTint,
        borderRadius: CuboRadii.smAll,
      ),
      alignment: Alignment.center,
      child: illustration == null
          ? Icon(fallbackIcon, color: CuboColors.blue, size: 28)
          : CuboIllustration(illustration!, onBlue: false, size: 42),
    );

    final arrow = Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: CuboColors.blue,
        shape: BoxShape.circle,
      ),
      child: Icon(
        mirrored ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
        color: CuboColors.white,
        size: 20,
      ),
    );

    final label = Expanded(
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: mirrored ? TextAlign.right : TextAlign.left,
        style: CuboText.label(size: 19),
      ),
    );

    final children = <Widget>[
      iconBox,
      const SizedBox(width: 14),
      label,
      const SizedBox(width: 10),
      arrow,
    ];

    return Semantics(
      button: true,
      label: tr(title),
      excludeSemantics: true,
      child: CuboPressable(
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: CuboDecorations.whiteCard(),
          child: Row(
            children: mirrored ? children.reversed.toList() : children,
          ),
        ),
      ),
    );
  }
}

/// Chip en píldora para estado (ronda, turno, jugador, modo...).
/// [light] es la variante para usar dentro de tarjetas blancas.
class CuboStatusChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool light;
  final bool uppercase;

  const CuboStatusChip(
    this.text, {
    super.key,
    this.icon,
    this.light = false,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final fg = light ? CuboColors.blueInk : CuboColors.white;
    final label = uppercase ? tr(text).toUpperCase() : tr(text);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: light ? CuboColors.blueTint : CuboColors.whiteA(0.14),
        borderRadius: BorderRadius.circular(999),
        border: light ? null : Border.all(color: CuboColors.whiteA(0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: fg),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CuboText.chip(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabecera común de juego: logo/volver a la izquierda, chip de estado en el
/// centro y botón de normas a la derecha.
class CuboGameHeader extends StatelessWidget {
  final VoidCallback? onRules;
  final Widget? status;
  final Widget? leading;
  final Widget? trailing;

  const CuboGameHeader({
    super.key,
    this.onRules,
    this.status,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 740;
    final size = compact ? 44.0 : 50.0;
    return Row(
      children: [
        leading ??
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.maybePop(context),
            ),
        const SizedBox(width: 10),
        Expanded(child: Center(child: status ?? const SizedBox.shrink())),
        const SizedBox(width: 10),
        trailing ??
            (onRules == null
                ? SizedBox(width: size)
                : CuboCircleButton(
                    icon: Icons.question_mark_rounded,
                    size: size,
                    onTap: onRules!,
                  )),
      ],
    );
  }
}

/// Progreso como puntos en píldora; si hay demasiados pasos, una barra
/// redondeada.
class CuboProgressDots extends StatelessWidget {
  final int total;
  final int current;
  final int maxDots;

  const CuboProgressDots({
    super.key,
    required this.total,
    required this.current,
    this.maxDots = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    if (total > maxDots) {
      final value = ((current + 1) / total).clamp(0.0, 1.0);
      return ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: CuboColors.whiteA(0.18),
          valueColor: const AlwaysStoppedAnimation(CuboColors.white),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: CuboColors.whiteA(
                i == current ? 1 : (i < current ? 0.7 : 0.28),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Check en círculo para marcar selección en tarjetas translúcidas.
class CuboCheckBadge extends StatelessWidget {
  final bool selected;
  final double size;
  final Color? color;

  const CuboCheckBadge({
    super.key,
    required this.selected,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? CuboColors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? accent : Colors.transparent,
        border: Border.all(
          color: selected ? accent : CuboColors.whiteA(0.45),
          width: 1.6,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: size * 0.7, color: CuboColors.blue)
          : null,
    );
  }
}

/// Tarjeta central de juego: blanca, radio 28, texto blueInk y chip arriba.
class CuboHeroCard extends StatelessWidget {
  final Widget child;
  final String? chip;
  final IconData? chipIcon;
  final EdgeInsetsGeometry padding;

  const CuboHeroCard({
    super.key,
    required this.child,
    this.chip,
    this.chipIcon,
    this.padding = const EdgeInsets.fromLTRB(22, 18, 22, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: CuboDecorations.whiteCard(radius: CuboRadii.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chip != null) ...[
            CuboStatusChip(chip!, icon: chipIcon, light: true),
            const SizedBox(height: 14),
          ],
          DefaultTextStyle.merge(
            style: const TextStyle(color: CuboColors.blueInk),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Transición al cambiar de carta: deslizamiento lateral con fade.
/// El hijo debe llevar una [Key] distinta por carta.
class CuboCardSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const CuboCardSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 320),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == this.child.key;
        final begin = Offset(incoming ? 0.18 : -0.18, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween(begin: begin, end: Offset.zero).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Cabecera de los modales de normas: icono en círculo translúcido, título
/// grande en minúscula y barrita en píldora.
class CuboDialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const CuboDialogHeader({
    super.key,
    this.title = 'normas',
    this.icon = Icons.question_mark_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CuboIconCircle(icon: icon, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CuboText.title(size: 38),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const CuboPillBar(),
      ],
    );
  }
}

/// Icono dentro de un círculo translúcido.
class CuboIconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const CuboIconCircle({
    super.key,
    required this.icon,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? CuboColors.white;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fg.withValues(alpha: 0.14),
        border: Border.all(color: fg.withValues(alpha: 0.30)),
      ),
      child: Icon(icon, color: fg, size: size * 0.52),
    );
  }
}

/// Elemento de la lista de normas: tarjeta translúcida redondeada con el
/// icono en un círculo.
class CuboRulesItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color? color;

  const CuboRulesItem({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CuboIconCircle(icon: icon, size: 36, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CuboText.label(size: 15, color: CuboColors.white)),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: CuboColors.whiteA(0.78),
                    fontSize: 12.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
