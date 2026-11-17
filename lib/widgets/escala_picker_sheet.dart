import 'dart:math' as math;

import 'package:flutter/material.dart' hide Text;

import '../data/escala_data.dart';
import 'cubo_widgets.dart';
import 'i18n_text.dart';

/// Icono de cada categoría de escalas.
const Map<String, IconData> iconosCategoriaEscala = {
  'Comida': Icons.restaurant_rounded,
  'Planes': Icons.celebration_rounded,
  'Amor': Icons.favorite_rounded,
  'Estilo': Icons.diamond_rounded,
  'Cultura': Icons.movie_rounded,
  'Vida': Icons.lightbulb_rounded,
};

/// Abre el selector y devuelve la escala elegida (o null si se cierra).
Future<Map<String, String>?> mostrarSelectorEscalas(
  BuildContext context, {
  String? categoriaInicial,
  ValueChanged<String?>? onCategoriaCambiada,
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EscalaPickerSheet(
      categoriaInicial: categoriaInicial,
      onCategoriaCambiada: onCategoriaCambiada,
    ),
  );
}

class EscalaPickerSheet extends StatefulWidget {
  const EscalaPickerSheet({
    super.key,
    this.categoriaInicial,
    this.onCategoriaCambiada,
  });

  /// null = todas las categorías.
  final String? categoriaInicial;
  final ValueChanged<String?>? onCategoriaCambiada;

  @override
  State<EscalaPickerSheet> createState() => _EscalaPickerSheetState();
}

class _EscalaPickerSheetState extends State<EscalaPickerSheet> {
  final math.Random _random = math.Random();
  late String? _categoria = widget.categoriaInicial;

  List<Map<String, String>> get _filtradas => _categoria == null
      ? escalasJuego
      : escalasJuego.where((e) => e['categoria'] == _categoria).toList();

  void _cambiarCategoria(String? categoria) {
    setState(() => _categoria = categoria);
    widget.onCategoriaCambiada?.call(categoria);
  }

  void _elegirAleatoria() {
    final lista = _filtradas;
    if (lista.isEmpty) return;
    Navigator.pop(context, lista[_random.nextInt(lista.length)]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 740;
    final escalas = _filtradas;

    return Container(
      height: size.height * (compact ? 0.88 : 0.8),
      decoration: const BoxDecoration(
        borderRadius: CuboRadii.sheetTop,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuboColors.blueLight, CuboColors.blue],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: CuboColors.whiteA(0.4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 18, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'elige escala',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CuboText.title(size: compact ? 30 : 36),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CuboCircleButton(
                    icon: Icons.casino_rounded,
                    size: compact ? 44 : 48,
                    onTap: _elegirAleatoria,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _CategoriaChip(
                    label: 'Todas',
                    icon: Icons.apps_rounded,
                    selected: _categoria == null,
                    onTap: () => _cambiarCategoria(null),
                  ),
                  for (final c in categoriasEscala)
                    _CategoriaChip(
                      label: c,
                      icon: iconosCategoriaEscala[c] ?? Icons.label_rounded,
                      selected: _categoria == c,
                      onTap: () => _cambiarCategoria(c),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                key: ValueKey(_categoria),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: escalas.length,
                itemBuilder: (context, i) => CuboEntrance(
                  index: math.min(i, 8),
                  child: _EscalaTile(
                    escala: escalas[i],
                    mostrarCategoria: _categoria == null,
                    onTap: () => Navigator.pop(context, escalas[i]),
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

class _CategoriaChip extends StatelessWidget {
  const _CategoriaChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? CuboColors.blueInk : CuboColors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: CuboPressable(
        onTap: () {
          onTap();
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? CuboColors.white : CuboColors.whiteA(0.12),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? CuboColors.white : CuboColors.whiteA(0.22),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscalaTile extends StatelessWidget {
  const _EscalaTile({
    required this.escala,
    required this.mostrarCategoria,
    required this.onTap,
  });

  final Map<String, String> escala;
  final bool mostrarCategoria;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: CuboColors.white,
      fontSize: 13.5,
      height: 1.15,
      fontWeight: FontWeight.w800,
    );
    final icono = iconosCategoriaEscala[escala['categoria']];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CuboPressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: CuboDecorations.glass(radius: CuboRadii.md),
          child: Row(
            children: [
              if (mostrarCategoria && icono != null) ...[
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: CuboColors.whiteA(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, size: 16, color: CuboColors.white),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  escala['izquierda']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: CuboColors.whiteA(0.6),
                  size: 20,
                ),
              ),
              Expanded(
                child: Text(
                  escala['derecha']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: style,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: CuboColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: CuboColors.blue,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
