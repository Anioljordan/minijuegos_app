import 'package:flutter/material.dart' hide Text;

import 'cubo_game_widgets.dart';
import 'i18n_text.dart';

/// Popup con el estilo de la app: cristal azul, cabecera con icono y
/// título grande, y el contenido debajo. [trailing] va a la derecha del
/// título (p. ej. el botón de ocultar cartas).
class CuboDialogFrame extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  const CuboDialogFrame({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: CuboDecorations.dialog(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CuboIconCircle(icon: icon, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(title, style: CuboText.title(size: 32)),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: CuboPillBar(),
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Texto explicativo dentro de un popup.
class CuboDialogNote extends StatelessWidget {
  final String text;

  const CuboDialogNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: TextStyle(
          color: CuboColors.whiteA(0.78),
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Opción pulsable de un popup (un jugador, una carta...). Con [color] se
/// pinta sólida; si no, va en cristal.
class CuboDialogOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool selected;

  const CuboDialogOption({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final solid = color != null;
    final fg = solid ? CuboColors.blueInk : CuboColors.white;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuboPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: color ?? CuboColors.whiteA(0.12),
            borderRadius: CuboRadii.mdAll,
            border: Border.all(
              color: selected ? CuboColors.white : CuboColors.whiteA(0.18),
              width: selected ? 3 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: fg, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón de píldora de un popup: principal en blanco, secundario en cristal.
class CuboDialogButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const CuboDialogButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = true,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final fg = primary ? CuboColors.blueInk : CuboColors.white;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: CuboPressable(
        onTap: onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary ? CuboColors.white : CuboColors.whiteA(0.12),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: primary
                  ? null
                  : Border.all(color: CuboColors.whiteA(0.28), width: 1.2),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón redondo para ocultar o mostrar las cartas de un popup.
class CuboDialogEyeToggle extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const CuboDialogEyeToggle({
    super.key,
    required this.visible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CuboPressable(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: CuboColors.whiteA(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: CuboColors.whiteA(0.28)),
        ),
        child: Icon(
          visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: CuboColors.white,
          size: 22,
        ),
      ),
    );
  }
}

/// Popup para elegir un jugador de [options] (índice, nombre).
Future<int?> showCuboPlayerPicker(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<(int, String)> options,
  String? note,
}) {
  return showCuboDialog<int>(
    context: context,
    builder: (dialogContext) => CuboDialogFrame(
      icon: icon,
      title: title,
      children: [
        if (note != null) CuboDialogNote(note),
        for (final (index, name) in options)
          CuboDialogOption(
            label: name,
            icon: Icons.person_rounded,
            onTap: () => Navigator.pop(dialogContext, index),
          ),
      ],
    ),
  );
}
