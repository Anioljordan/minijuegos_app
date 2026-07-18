import 'dart:math';
import 'package:flutter/material.dart';
import '../data/animales_profesionales_data.dart';
import '../widgets/app_logo_button.dart';

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
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: appWhite,
      side: BorderSide(
        color: appWhite.withOpacity(0.70),
        width: 2,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
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
                          height: 1.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: lineTop,
                  left: compact ? -13 : -18,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.26),
          width: 1.4,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: appWhite,
            size: 22,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.72),
                    fontSize: 12.5,
                    height: 1.25,
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

  void mostrarNormas() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.75),
              width: 2.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appWhite.withOpacity(0.85),
                            width: 2.1,
                          ),
                        ),
                        child: const Icon(
                          Icons.question_mark_rounded,
                          color: appWhite,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'normas',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 38,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.30),
          width: 1.4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
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
      body: SafeArea(
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
    );
  }
  Widget _buildContenido() {
    if (_itemActual == null) {
      return const Column(
        key: ValueKey('empty'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🐾',
            style: TextStyle(fontSize: 82),
          ),
          SizedBox(height: 18),
          Text(
            'pulsa generar\npara empezar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 31,
              height: 0.95,
              color: appWhite,
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appWhite.withOpacity(0.85),
                width: 2.2,
              ),
            ),
            child: Icon(
              Icons.visibility_off_rounded,
              size: 39,
              color: appWhite.withOpacity(0.9),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'contenido\noculto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 34,
              height: 0.92,
              color: appWhite,
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
              color: appWhite.withOpacity(0.68),
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
          _itemActual!.animal.toLowerCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: appWhite,
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
            color: appWhite.withOpacity(0.66),
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _itemActual!.profesion.toLowerCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: appWhite,
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