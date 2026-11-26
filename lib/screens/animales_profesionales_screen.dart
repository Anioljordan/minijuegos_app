import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/animales_profesionales_data.dart';
import '../widgets/cubo_game_widgets.dart';
import '../core/app_settings.dart';
import '../core/animal_profession_i18n.dart';

class AnimalesProfesionalesScreen extends StatefulWidget {
  const AnimalesProfesionalesScreen({super.key});

  @override
  State<AnimalesProfesionalesScreen> createState() =>
      _AnimalesProfesionalesScreenState();
}

class _AnimalesProfesionalesScreenState
    extends State<AnimalesProfesionalesScreen> {
  final Random _random = Random();

  AnimalProfesionalItem? _itemActual;
  bool _oculto = false;

  void _generarNuevo() {
    final animal = AnimalesProfesionalesData
        .animales[_random.nextInt(AnimalesProfesionalesData.animales.length)];

    final profesion =
        AnimalesProfesionalesData.profesiones[_random.nextInt(
          AnimalesProfesionalesData.profesiones.length,
        )];

    setState(() {
      _itemActual = AnimalProfesionalItem(
        animal: animal["nombre"]!,
        profesion: profesion["nombre"]!,
        animalEmoji: animal["emoji"]!,
        profesionEmoji: profesion["emoji"]!,
      );
      _oculto = false;
    });
  }

  void _toggleOcultar() {
    if (_itemActual == null) return;

    setState(() {
      _oculto = !_oculto;
    });
  }

  void mostrarNormas() {
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),
                  const SizedBox(height: 18),
                  const Text(
                    'ANIMALES PROFESIONALES',
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const CuboRulesItem(
                    icon: Icons.casino_rounded,
                    title: 'Saca una carta',
                    text:
                        'Pulsa la flecha para sacar un animal y una profesión al azar.',
                  ),
                  const CuboRulesItem(
                    icon: Icons.theater_comedy_rounded,
                    title: 'Haz la mímica',
                    text: 'Representa el animal mientras haces esa profesión.',
                  ),
                  const CuboRulesItem(
                    icon: Icons.visibility_off_rounded,
                    title: 'Oculta la carta',
                    text:
                        'Con el ojo ocultas la carta para pasar el móvil sin enseñar la respuesta.',
                  ),
                  const CuboRulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Adivinad',
                    text:
                        'Los demás tienen que adivinar el animal y la profesión.',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: CuboButtons.primary(),
                      child: const Text(
                        'ENTENDIDO',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuboGameHeader(onRules: mostrarNormas),
        SizedBox(height: compact ? 6 : 12),
        CuboGameTitle(
          'animales profesionales',
          side: CuboTitleSide.chill,
          illustration: 'animales',
          compact: compact,
        ),
      ],
    );
  }

  Widget buildCard() {
    final item = _itemActual;
    final key = item == null
        ? 'empty'
        : _oculto
        ? 'hidden-${item.animal}-${item.profesion}'
        : '${item.animal}-${item.profesion}';

    return CuboCardStack(
      maxHeight: 440,
      child: Container(
        key: ValueKey(key),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        decoration: CuboDecorations.playCard,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: CuboStatusChip(
                'animales profesionales',
                icon: Icons.pets_rounded,
                light: true,
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(width: 300, child: _buildContenido()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const CuboPillBar(width: 40, height: 5, color: CuboColors.chill),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuboColors.blue,
      body: CuboGameBackground(
        accent: CuboColors.chill,
        halo: CuboHalo.topLeft,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 740;
              final gap = compact ? 12.0 : 18.0;

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 13 : 18,
                  compact ? 11 : 18,
                  compact ? 13 : 18,
                  compact ? 11 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),
                    SizedBox(height: gap),
                    Expanded(child: buildCard()),
                    SizedBox(height: gap),
                    CuboActionBar(
                      height: compact ? 60 : 68,
                      secondaryIcon: _oculto
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      onSecondary: _toggleOcultar,
                      onPrimary: _generarNuevo,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  TextStyle get _bigWord => CuboText.cardPhrase(size: 40);

  Widget _buildContenido() {
    final item = _itemActual;
    if (item == null) {
      return Text(
        'Pulsa la flecha para sacar la primera carta',
        textAlign: TextAlign.center,
        style: CuboText.cardPhrase(size: 30),
      );
    }

    if (_oculto) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CuboCardBadge(
            icon: Icons.visibility_off_rounded,
            accent: CuboColors.chill,
          ),
          const SizedBox(height: 18),
          Text(
            'Carta oculta',
            textAlign: TextAlign.center,
            style: CuboText.cardPhrase(size: 34),
          ),
          const SizedBox(height: 10),
          Text(
            'Pasa el móvil sin enseñar la combinación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: CuboColors.blueInk.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    final language = AppSettings.instance.language;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${item.animalEmoji}  ${item.profesionEmoji}',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 18),
        Text(
          localizedAnimalName(item.animal, language),
          textAlign: TextAlign.center,
          style: _bigWord,
        ),
        const SizedBox(height: 6),
        Text(
          'haciendo de',
          style: TextStyle(
            color: CuboColors.blueInk.withValues(alpha: 0.6),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          localizedProfessionName(item.profesion, language),
          textAlign: TextAlign.center,
          style: _bigWord,
        ),
      ],
    );
  }
}
