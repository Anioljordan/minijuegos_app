import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

/// Piezas de las pantallas de partida: tipografía Inter, carta protagonista
/// con mazo detrás, barra de progreso, botonera inferior y tarjetas de modo.
/// Se exportan desde cubo_game_widgets.dart.

/// Aplica Inter a todo lo que cuelga de él. Se usa en las pantallas de juego
/// (y en sus diálogos, que viven en otra ruta) para no tocar los menús.
class CuboGameScope extends StatelessWidget {
  final Widget child;

  const CuboGameScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: CuboText.fontFamily),
        primaryTextTheme: theme.primaryTextTheme.apply(
          fontFamily: CuboText.fontFamily,
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: CuboText.fontFamily),
        child: child,
      ),
    );
  }
}

/// Fondo de partida: [CuboBackground] con halo de acento e Inter para todo
/// lo que cuelga de él. Sustituye a CuboBackground en las pantallas de juego.
class CuboGameBackground extends StatelessWidget {
  final Widget child;
  final CuboHalo halo;
  final Color accent;

  const CuboGameBackground({
    super.key,
    required this.child,
    this.halo = CuboHalo.topRight,
    this.accent = CuboColors.fiesta,
  });

  @override
  Widget build(BuildContext context) {
    return CuboGameScope(
      child: CuboBackground(halo: halo, accent: accent, child: child),
    );
  }
}

/// [showDialog] con Inter: los diálogos viven en otra ruta y no heredan el
/// [CuboGameScope] de la pantalla.
Future<T?> showCuboDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    builder: (dialogContext) => CuboGameScope(child: builder(dialogContext)),
  );
}

/// [showModalBottomSheet] con Inter.
Future<T?> showCuboSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color? backgroundColor,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  ShapeBorder? shape,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    shape: shape,
    builder: (sheetContext) => CuboGameScope(child: builder(sheetContext)),
  );
}

/// Carta protagonista: blanca, radio 32, sombra en dos capas, chip opcional
/// arriba y barrita de acento abajo. El texto se reduce solo si no cabe, para
/// aguantar las frases largas en catalán e inglés.
class CuboPlayCard extends StatelessWidget {
  final String text;
  final String? chip;
  final IconData? chipIcon;
  final Color accent;
  final double maxFontSize;

  /// Texto pequeño bajo la frase (p. ej. cómo añadir frases).
  final String? hint;

  /// Elemento opcional encima de la frase (icono del juego, contador...).
  final Widget? leading;

  const CuboPlayCard({
    super.key,
    required this.text,
    this.hint,
    this.leading,
    this.chip,
    this.chipIcon,
    this.accent = CuboColors.fiesta,
    this.maxFontSize = 31,
  });

  /// Tamaño de partida según la longitud; FittedBox remata si aún no cabe.
  static double fontSizeFor(String text, double maxSize) {
    final length = text.length;
    if (length > 140) return maxSize * 0.72;
    if (length > 90) return maxSize * 0.82;
    if (length > 55) return maxSize * 0.92;
    return maxSize;
  }

  @override
  Widget build(BuildContext context) {
    final translated = tr(text);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
      decoration: CuboDecorations.playCard,
      child: Column(
        children: [
          if (chip != null)
            Align(
              alignment: Alignment.centerLeft,
              child: CuboStatusChip(chip!, icon: chipIcon, light: true),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) => Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: box.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leading != null) ...[
                          leading!,
                          const SizedBox(height: 18),
                        ],
                        Text(
                          translated,
                          textAlign: TextAlign.center,
                          style: CuboText.cardPhrase(
                            size: fontSizeFor(translated, maxFontSize),
                          ),
                        ),
                        if (hint != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            hint!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CuboColors.blueInk.withValues(alpha: 0.62),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          CuboPillBar(width: 40, height: 5, color: accent),
        ],
      ),
    );
  }
}

/// Icono redondo con el color de acento, para [CuboPlayCard.leading].
class CuboCardBadge extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final double size;

  const CuboCardBadge({
    super.key,
    required this.icon,
    this.accent = CuboColors.fiesta,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.22),
        border: Border.all(color: accent, width: 2.4),
      ),
      child: Icon(icon, color: CuboColors.blueInk, size: size * 0.52),
    );
  }
}

/// Mazo: dos cartas translúcidas giradas detrás de la protagonista. Al
/// cambiar la [Key] del hijo, la carta actual sale hacia la izquierda girando
/// y la nueva sube del mazo con un pequeño rebote. Solo anima transform y
/// opacidad para ir fluido en móviles normales.
class CuboCardStack extends StatelessWidget {
  final Widget child;
  final double maxHeight;
  final Duration duration;

  /// Margen vertical de la carta de delante: deja asomar el mazo.
  static const double _frontInset = 22;

  const CuboCardStack({
    super.key,
    required this.child,
    this.maxHeight = 460,
    this.duration = const Duration(milliseconds: 340),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final height = math.min(box.maxHeight, maxHeight);
        return Center(
          child: SizedBox(
            height: height,
            width: box.maxWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const _GhostCard(
                  inset: 20,
                  vertical: 0,
                  angle: 0.06,
                  alpha: 0.22,
                ),
                const _GhostCard(
                  inset: 10,
                  vertical: 8,
                  angle: -0.035,
                  alpha: 0.45,
                ),
                Positioned.fill(
                  top: _frontInset,
                  bottom: _frontInset,
                  child: AnimatedSwitcher(
                    duration: duration,
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      children: [?current, ...previous],
                    ),
                    transitionBuilder: (card, animation) => CuboCardTransition(
                      animation: animation,
                      incoming: card.key == child.key,
                      child: card,
                    ),
                    child: child,
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

class _GhostCard extends StatelessWidget {
  final double inset;
  final double vertical;
  final double angle;
  final double alpha;

  const _GhostCard({
    required this.inset,
    required this.vertical,
    required this.angle,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      left: inset,
      right: inset,
      top: vertical,
      bottom: vertical,
      child: Transform.rotate(
        angle: angle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: CuboColors.whiteA(alpha),
            borderRadius: CuboRadii.cardAll,
            boxShadow: CuboShadows.ghost,
          ),
        ),
      ),
    );
  }
}

/// Transición de carta: la que entra sube del mazo con rebote y la que sale
/// se va hacia la izquierda girando. Usada por [CuboCardStack] y
/// [CuboCardSwitcher].
class CuboCardTransition extends StatelessWidget {
  final Animation<double> animation;
  final bool incoming;
  final Widget child;

  const CuboCardTransition({
    super.key,
    required this.animation,
    required this.incoming,
    required this.child,
  });

  static const double _exitDistance = 1.15;
  static const double _exitAngle = -0.14;
  static const double _enterScale = 0.9;
  static const double _enterLift = 26;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, card) {
        final t = animation.value;
        final opacity = t.clamp(0.0, 1.0);
        if (incoming) {
          final scale = _enterScale + (1 - _enterScale) * t;
          return Opacity(
            opacity: opacity,
            child: Transform.translate(
              offset: Offset(0, _enterLift * (1 - t)),
              child: Transform.scale(scale: scale, child: card),
            ),
          );
        }
        final out = 1 - t;
        return Opacity(
          opacity: opacity,
          child: FractionalTranslation(
            translation: Offset(-_exitDistance * out, 0.04 * out),
            child: Transform.rotate(angle: _exitAngle * out, child: card),
          ),
        );
      },
    );
  }
}

/// Progreso en píldora con brillo del color de acento.
class CuboProgressPill extends StatelessWidget {
  final String label;
  final String valueText;
  final double value;
  final Color accent;

  /// Elemento junto a la etiqueta (p. ej. botón discreto de editar).
  final Widget? labelTrailing;

  /// Línea pequeña bajo la etiqueta.
  final String? caption;

  const CuboProgressPill({
    super.key,
    required this.label,
    required this.valueText,
    required this.value,
    this.accent = CuboColors.fiesta,
    this.labelTrailing,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = Color.lerp(accent, CuboColors.paper, 0.45)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: CuboText.chip(
                          color: CuboColors.whiteA(0.76),
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                  if (labelTrailing != null) ...[
                    const SizedBox(width: 8),
                    labelTrailing!,
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              valueText,
              maxLines: 1,
              style: const TextStyle(
                color: CuboColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CuboColors.whiteA(0.62),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 9),
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: CuboColors.whiteA(0.15),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: value.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            builder: (context, factor, _) => FractionallySizedBox(
              widthFactor: factor,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accent, highlight]),
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.55),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botonera inferior: acción secundaria en círculo de cristal y acción
/// principal en píldora blanca grande.
class CuboActionBar extends StatelessWidget {
  final IconData secondaryIcon;
  final VoidCallback onSecondary;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final double height;

  const CuboActionBar({
    super.key,
    required this.secondaryIcon,
    required this.onSecondary,
    required this.onPrimary,
    this.primaryIcon = Icons.arrow_forward_rounded,
    this.height = 68,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CuboPressable(
          onTap: onSecondary,
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CuboColors.whiteA(0.10),
              border: Border.all(color: CuboColors.whiteA(0.45), width: 1.4),
            ),
            child: Icon(
              secondaryIcon,
              color: CuboColors.white,
              size: height * 0.38,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CuboPressable(
            onTap: onPrimary,
            child: Container(
              height: height,
              decoration: const BoxDecoration(
                color: CuboColors.white,
                borderRadius: BorderRadius.all(Radius.circular(999)),
                boxShadow: CuboShadows.float,
              ),
              child: Icon(
                primaryIcon,
                color: CuboColors.blue,
                size: height * 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón grande de elección (Prueba / Verdad, Cara / Cruz...). [primary]
/// es la píldora blanca con sombra; si no, cristal translúcido. [accent]
/// pinta el icono para distinguir cada opción.
class CuboChoiceButton extends StatelessWidget {
  final String label;
  final IconData icon;

  /// Nulo = desactivado (más tenue y sin pulsación).
  final VoidCallback? onTap;
  final bool primary;
  final Color? accent;
  final double height;

  const CuboChoiceButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.primary = false,
    this.accent,
    this.height = 92,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final solid = primary && enabled;
    final fg = solid ? CuboColors.blue : CuboColors.whiteA(enabled ? 1 : 0.4);
    return CuboPressable(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: solid
            ? const BoxDecoration(
                color: CuboColors.white,
                borderRadius: CuboRadii.xlAll,
                boxShadow: CuboShadows.float,
              )
            : BoxDecoration(
                color: CuboColors.whiteA(enabled ? 0.10 : 0.06),
                borderRadius: CuboRadii.xlAll,
                border: Border.all(
                  color: CuboColors.whiteA(enabled ? 0.45 : 0.14),
                  width: 1.4,
                ),
              ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: height * 0.44,
              height: height * 0.44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled && accent != null
                    ? accent
                    : (solid ? CuboColors.blueTint : CuboColors.whiteA(0.14)),
              ),
              child: Icon(
                icon,
                color: enabled && accent != null ? CuboColors.blueInk : fg,
                size: height * 0.26,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta para escoger modo dentro de un juego: cristal con profundidad,
/// icono en un cuadrado de color y nombre del modo.
class CuboModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final VoidCallback onTap;
  final bool compact;

  const CuboModeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconBackground = CuboColors.fiesta,
    this.iconColor = CuboColors.blueInk,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = compact ? 52.0 : 60.0;
    return CuboPressable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: CuboDecorations.glassRaised(),
        child: Row(
          children: [
            Container(
              width: tile,
              height: tile,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(tile / 3),
                boxShadow: [
                  BoxShadow(
                    color: iconBackground.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: tile / 2),
            ),
            SizedBox(width: compact ? 14 : 16),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 17 : 19,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
