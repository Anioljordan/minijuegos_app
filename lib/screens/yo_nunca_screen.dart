import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/yo_nunca_data.dart';

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
      mostrarNormas();
    });
  }

  List<String> obtenerListaPreguntas() {
    if (widget.modo == 'chill') return List<String>.from(yoNuncaChill);
    if (widget.modo == 'erotico') return List<String>.from(yoNuncaErotico);
    return [...yoNuncaChill, ...yoNuncaErotico];
  }

  String get storageKeyPreguntas => 'yo_nunca_${widget.modo}_restantes';
  String get storageKeyActual => 'yo_nunca_${widget.modo}_actual';

  Color get accentColor {
    if (widget.modo == 'chill') return accentGreen;
    if (widget.modo == 'erotico') return accentPink;
    return accentOrange;
  }

  IconData get modeIcon {
    if (widget.modo == 'chill') return Icons.spa_rounded;
    if (widget.modo == 'erotico') return Icons.local_fire_department_rounded;
    return Icons.shuffle_rounded;
  }

  String tituloModo() {
    if (widget.modo == 'chill') return 'yo nunca\nchill';
    if (widget.modo == 'erotico') return 'yo nunca\nerótico';
    return 'yo nunca\nmix';
  }

  String subtituloModo() {
    if (widget.modo == 'chill') {
      return 'Preguntas suaves, graciosas y para todos';
    }

    if (widget.modo == 'erotico') {
      return 'Preguntas más atrevidas para jugar con confianza';
    }

    return 'Mezcla de preguntas chill y más picantes';
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
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    tituloModo(),
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 42,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: 82,
                  left: 0,
                  right: -18,
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

  Widget buildInfoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        subtituloModo(),
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
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
                    text: 'Si alguien quiere saber qué pasó, puede pedir la historia.',
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: Column(
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
              modeIcon,
              color: appWhite,
              size: 38,
            ),
          ),
          const SizedBox(height: 22),
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
                fontSize: 30,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressInfo() {
    final total = preguntasRestantes.length + 1;
    final progress = preguntasRestantes.isEmpty ? 0.0 : 1 / total;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: appWhite.withOpacity(0.18),
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Preguntas restantes: ${preguntasRestantes.length}',
          style: TextStyle(
            color: appWhite.withOpacity(0.68),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              buildTopBar(),
              const SizedBox(height: 14),
              buildInfoBar(),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: buildQuestionCard(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildProgressInfo(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: siguientePregunta,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'SIGUIENTE',
                      style: TextStyle(
                        color: appBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: reiniciar,
                  style: secondaryButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'REINICIAR PREGUNTAS',
                      style: TextStyle(
                        fontSize: 14,
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
    );
  }
}