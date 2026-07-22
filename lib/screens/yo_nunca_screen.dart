import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/yo_nunca_data.dart';
import '../widgets/app_logo_button.dart';

class YoNuncaScreen extends StatefulWidget {
  final String modo;

  const YoNuncaScreen({
    super.key,
    required this.modo,
  });

  @override
  State<YoNuncaScreen> createState() => _YoNuncaScreenState();
}

class _YoNuncaScreenState extends State<YoNuncaScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPink = Color(0xFFFF4D6D);

  String preguntaActual = 'Pulsa siguiente para empezar';
  List<String> preguntasRestantes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarEstado();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

    });
  }

  List<String> obtenerListaPreguntas() {
    if (widget.modo == 'chill') return List<String>.from(yoNuncaChill);
    if (widget.modo == 'picante') return List<String>.from(yoNuncaPicante);
    return [...yoNuncaChill, ...yoNuncaPicante];
  }

  String get storageKeyPreguntas => 'yo_nunca_${widget.modo}_restantes';
  String get storageKeyActual => 'yo_nunca_${widget.modo}_actual';

  Color get accentColor {
    if (widget.modo == 'chill') return accentGreen;
    if (widget.modo == 'picante') return accentPink;
    return accentOrange;
  }

  IconData get modeIcon {
    if (widget.modo == 'chill') return Icons.spa_rounded;
    if (widget.modo == 'picante') return Icons.local_fire_department_rounded;
    return Icons.shuffle_rounded;
  }

  String tituloModo() {
    if (widget.modo == 'chill') return 'yo nunca chill';
    if (widget.modo == 'picante') return 'yo nunca picante';
    return 'yo nunca mix';
  }

  int get totalPreguntasModo => obtenerListaPreguntas().length;

  double get progresoRestante {
    if (totalPreguntasModo == 0) return 0;

    return (preguntasRestantes.length / totalPreguntasModo).clamp(0.0, 1.0);
  }

  Color get nextButtonForeground {
    return widget.modo == 'picante' ? appWhite : appBlue;
  }

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();

    final listaBase = obtenerListaPreguntas();
    final guardadas = prefs.getStringList(storageKeyPreguntas);
    final actualGuardada = prefs.getString(storageKeyActual);

    if (!mounted) return;

    setState(() {
      preguntasRestantes = guardadas != null && guardadas.isNotEmpty
          ? List<String>.from(guardadas)
          : List<String>.from(listaBase);

      preguntaActual = actualGuardada ?? 'Pulsa siguiente para empezar';
      cargando = false;
    });
  }

  Future<void> guardarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKeyPreguntas, preguntasRestantes);
    await prefs.setString(storageKeyActual, preguntaActual);
  }

  Future<void> siguientePregunta() async {
    if (preguntasRestantes.isEmpty) {
      preguntasRestantes = obtenerListaPreguntas();
    }

    final index = random.nextInt(preguntasRestantes.length);
    final nuevaPregunta = preguntasRestantes[index];

    setState(() {
      preguntaActual = nuevaPregunta;
      preguntasRestantes.removeAt(index);
    });

    await guardarEstado();
  }

  Future<void> reiniciar() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      preguntaActual = 'Pulsa siguiente para empezar';
      preguntasRestantes = obtenerListaPreguntas();
    });

    await prefs.setStringList(storageKeyPreguntas, preguntasRestantes);
    await prefs.setString(storageKeyActual, preguntaActual);
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
    final compact = MediaQuery.of(context).size.height < 740;
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tituloModo(),
                      maxLines: 1,
                      style: const TextStyle(
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
                  Text(
                    tituloModo().replaceAll('\n', ' ').toUpperCase(),
                    style: const TextStyle(
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
                    text: 'Lee la carta en voz alta para todo el grupo.',
                  ),
                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Bebe',
                    text: 'Si alguna vez lo has hecho, bebes.',
                  ),
                  rulesItem(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Historia',
                    text: 'Para saber la historia deberá beber los tragos que decida el jugador.',
                  ),
                  rulesItem(
                    icon: Icons.refresh_rounded,
                    title: 'Siguiente',
                    text: 'Pulsa siguiente para sacar una nueva pregunta.',
                  ),
                  rulesItem(
                    icon: Icons.restart_alt_rounded,
                    title: 'Reiniciar',
                    text: 'Puedes reiniciar el mazo de preguntas cuando quieras.',
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

  Widget buildQuestionCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(


      ),
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
                  color: accentColor.withOpacity(0.15),
                  border: Border.all(
                    color: accentColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  modeIcon,
                  color: accentColor,
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
                  preguntaActual,
                  key: ValueKey(preguntaActual),
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
              'PREGUNTAS RESTANTES',
              style: TextStyle(
                color: appWhite.withOpacity(0.76),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            const Spacer(),
            Text(
              '${preguntasRestantes.length} / $totalPreguntasModo',
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
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
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
    if (cargando) {
      return const Scaffold(
        backgroundColor: appBlue,
        body: Center(
          child: CircularProgressIndicator(
            color: appWhite,
          ),
        ),
      );
    }

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
                    child: buildQuestionCard(),
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
                        onTap: reiniciar,
                      ),
                      const SizedBox(width: 12),
                      buildActionButton(
                        icon: Icons.arrow_forward_rounded,
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        onTap: siguientePregunta,
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