import 'dart:math';
import 'package:flutter/material.dart';
import '../data/piccolo_data.dart';

class PiccoloScreen extends StatefulWidget {
  const PiccoloScreen({super.key});

  @override
  State<PiccoloScreen> createState() => _PiccoloScreenState();
}

class _PiccoloScreenState extends State<PiccoloScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPink = Color(0xFFFF4D6D);

  String fraseActual = 'Pulsa siguiente para empezar';

  List<String> frasesDisponibles = [];
  List<String> frasesUsadas = [];

  @override
  void initState() {
    super.initState();
    reiniciarBaraja();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

    });
  }

  int get totalFrases => piccoloFrases.length;

  double get progresoRestante {
    if (totalFrases == 0) return 0;
    return (frasesDisponibles.length / totalFrases).clamp(0.0, 1.0);
  }

  void reiniciarBaraja() {
    frasesDisponibles = List<String>.from(piccoloFrases)..shuffle(random);
    frasesUsadas = [];
  }

  void siguienteFrase() {
    if (frasesDisponibles.isEmpty) {
      frasesDisponibles = List<String>.from(frasesUsadas)..shuffle(random);
      frasesUsadas.clear();
    }

    if (frasesDisponibles.isEmpty) return;

    final fraseBase = frasesDisponibles.removeLast();
    final castigo = generarCastigo();
    final fraseConCastigo = '$fraseBase\n\n$castigo';

    setState(() {
      fraseActual = fraseConCastigo;
      frasesUsadas.add(fraseBase);
    });
  }

  String generarCastigo() {
    final tragos = random.nextInt(3) + 1;
    final reparte = random.nextBool();

    if (reparte) {
      return 'Reparte $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
    }

    return 'Bebe $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
  }

  void reiniciarJuego() {
    setState(() {
      fraseActual = 'Pulsa siguiente para empezar';
      reiniciarBaraja();
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

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
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

  Widget buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              onTap: () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            circleButton(
              onTap: mostrarNormas,
              child: const Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'señala y bebe',
                      maxLines: 1,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 42,
                        height: 2.20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 82,
                  left: 0,
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

  Widget rulesItem({
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
                    'SEÑALA Y BEBE',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  rulesItem(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Lee la frase',
                    text: 'Un jugador lee la frase en voz alta para todo el grupo.',
                  ),
                  rulesItem(
                    icon: Icons.touch_app_rounded,
                    title: 'Todos señalan',
                    text: 'Todos señalan a la persona que encaja mejor con la frase.',
                  ),
                  rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'El más señalado',
                    text: 'La persona con más votos cumple el castigo de la carta.',
                  ),
                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Castigo aleatorio',
                    text: 'Cada carta indica beber o repartir entre 1 y 3 tragos.',
                  ),
                  rulesItem(
                    icon: Icons.restart_alt_rounded,
                    title: 'Reiniciar',
                    text: 'Puedes reiniciar la baraja completa cuando quieras.',
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

  Widget buildPhraseCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appWhite.withOpacity(0.15),
                  border: Border.all(
                    color: appWhite,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.ads_click_rounded,
                  color: appWhite,
                  size: 50,
                ),
              ),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation);

                  return SlideTransition(
                    position: slide,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  fraseActual,
                  key: ValueKey(fraseActual),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 32,
                    height: 1.14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgressInfo() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'FRASES RESTANTES',
              style: TextStyle(
                color: appWhite.withOpacity(0.76),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            const Spacer(),
            Text(
              '${frasesDisponibles.length} / $totalFrases',
              style: const TextStyle(
                color: appWhite,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: progresoRestante),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Container(
              height: 14,
              decoration: BoxDecoration(
                color: appWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: appWhite.withOpacity(0.34),
                  width: 1.2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(appWhite),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.35,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appWhite.withOpacity(0.28),
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: foregroundColor,
                  size: 54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactHeight = constraints.maxHeight < 700;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                compactHeight ? 12 : 18,
                18,
                compactHeight ? 10 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(),
                  SizedBox(height: compactHeight ? 8 : 14),
                  Expanded(
                    child: buildPhraseCard(),
                  ),
                  SizedBox(height: compactHeight ? 9 : 14),
                  buildProgressInfo(),
                  SizedBox(height: compactHeight ? 9 : 14),
                  Row(
                    children: [
                      buildActionButton(
                        icon: Icons.restart_alt_rounded,
                        backgroundColor: appBlue,
                        foregroundColor: appWhite,
                        onTap: reiniciarJuego,
                      ),
                      const SizedBox(width: 12),
                      buildActionButton(
                        icon: Icons.arrow_forward_rounded,
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        onTap: siguienteFrase,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
