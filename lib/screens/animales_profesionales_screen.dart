import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/animales_profesionales_data.dart';
import '../widgets/app_logo_button.dart';
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

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentGreen = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  void _generarNuevo() {
    final animal = AnimalesProfesionalesData
        .animales[_random.nextInt(AnimalesProfesionalesData.animales.length)];

    final profesion = AnimalesProfesionalesData.profesiones[
    _random.nextInt(AnimalesProfesionalesData.profesiones.length)];

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

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: EdgeInsets.zero);
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(padding: EdgeInsets.zero);
  }

  Widget _circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
            ),

            _circleButton(
              compact: compact,
              onTap: mostrarNormas,
              child: Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 14 : 24),

        Padding(
          padding: EdgeInsets.only(
            right: compact ? 18 : 28,
          ),
          child: SizedBox(
            width: double.infinity,
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: Text(
                        'animales profesionales',
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 2.6,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: lineTop,
                  right: 0,
                  child: const CuboPillBar(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void mostrarNormas() {
    showDialog(
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
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _rulesItem(
                    icon: Icons.casino_rounded,
                    title: 'Genera combinación',
                    text:
                    'Pulsa generar para sacar un animal y una profesión aleatorios.',
                  ),

                  _rulesItem(
                    icon: Icons.theater_comedy_rounded,
                    title: 'Haz la mímica',
                    text:
                    'Representa el animal mientras haces esa profesión.',
                  ),

                  _rulesItem(
                    icon: Icons.visibility_off_rounded,
                    title: 'Oculta la carta',
                    text:
                    'Puedes ocultar el contenido para pasar el móvil sin enseñar la respuesta.',
                  ),

                  _rulesItem(
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
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'ENTENDIDO',
                          style: TextStyle(
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
        ),
      ),
    );
  }

  Widget buildMainCard() {
    final contentKey = _itemActual == null
        ? 'empty'
        : _oculto
        ? 'hidden'
        : '${_itemActual!.animal}-${_itemActual!.profesion}';

    return CuboCardSwitcher(
      child: CuboHeroCard(
        key: ValueKey(contentKey),
        chip: 'animales profesionales',
        chipIcon: Icons.pets_rounded,
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: _buildContenido(),
      ),
    );
  }

  Widget buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _generarNuevo,
            style: mainButtonStyle(),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'GENERAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 11),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _itemActual == null ? null : _toggleOcultar,
            style: secondaryButtonStyle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Text(
                _oculto ? 'MOSTRAR' : 'OCULTAR',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: CuboBackground(
        halo: CuboHalo.topLeft,
        child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 740;
            final horizontalPadding = compact ? 13.0 : 18.0;
            final verticalPadding = compact ? 11.0 : 18.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                compact ? 11 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(compact: compact),

                  SizedBox(height: compact ? 10 : 14),

                  Expanded(
                    child: Center(
                      child: buildMainCard(),
                    ),
                  ),

                  SizedBox(height: compact ? 10 : 14),

                  buildButtons(),
                ],
              ),
            );
          },
        ),
        ),
      ),
    );
  }

  Widget _buildContenido() {
    if (_itemActual == null) {
      return const Column(
        key: ValueKey('empty'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CuboIllustration('animales', onBlue: false, size: 104),
          SizedBox(height: 18),
          Text(
            'pulsa generar\npara empezar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              height: 0.95,
              color: CuboColors.blueInk,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
        ],
      );
    }

    if (_oculto) {
      return Column(
        key: const ValueKey('hidden'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CuboColors.blueTint,
            ),
            child: const Icon(
              Icons.visibility_off_rounded,
              size: 39,
              color: CuboColors.blueInk,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'contenido\noculto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              height: 0.92,
              color: CuboColors.blueInk,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Pasa el móvil sin enseñar la combinación',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: CuboColors.blueInk.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return Column(
      key: ValueKey('${_itemActual!.animal}-${_itemActual!.profesion}'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${_itemActual!.animalEmoji}  +  ${_itemActual!.profesionEmoji}',
            style: const TextStyle(fontSize: 70),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          localizedAnimalName(
            _itemActual!.animal,
            AppSettings.instance.language,
          ).toLowerCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CuboColors.blueInk,
            fontSize: 41,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'haciendo de',
          style: TextStyle(
            color: CuboColors.blueInk.withValues(alpha: 0.66),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          localizedProfessionName(
            _itemActual!.profesion,
            AppSettings.instance.language,
          ).toLowerCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: CuboColors.blueInk,
            fontSize: 41,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}