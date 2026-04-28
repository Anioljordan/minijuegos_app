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

  String preguntaActual = 'Pulsa siguiente para empezar';
  List<String> preguntasRestantes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarEstado();
  }

  List<String> obtenerListaPreguntas() {
    if (widget.modo == 'chill') return List<String>.from(yoNuncaChill);
    if (widget.modo == 'erotico') return List<String>.from(yoNuncaErotico);
    return [...yoNuncaChill, ...yoNuncaErotico];
  }

  String get storageKeyPreguntas => 'yo_nunca_${widget.modo}_restantes';
  String get storageKeyActual => 'yo_nunca_${widget.modo}_actual';

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();

    final listaBase = obtenerListaPreguntas();
    final guardadas = prefs.getStringList(storageKeyPreguntas);
    final actualGuardada = prefs.getString(storageKeyActual);

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

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF151122),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cómo se juega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lee la frase en voz alta.\n\n'
                    'Si alguna vez lo has hecho, bebes.\n\n'
                    'Si alguien quiere saber la historia, puede pedirla.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Cerrar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String tituloModo() {
    if (widget.modo == 'chill') return 'Yo Nunca Chill';
    if (widget.modo == 'erotico') return 'Yo Nunca Erótico';
    return 'Yo Nunca Mix';
  }

  List<Color> modeColors() {
    if (widget.modo == 'chill') {
      return const [Color(0xFF14B8A6), Color(0xFF0F766E)];
    }

    if (widget.modo == 'erotico') {
      return const [Color(0xFFFF005C), Color(0xFF7C2D12)];
    }

    return const [Color(0xFFF97316), Color(0xFFDB2777)];
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: modeColors().first,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withOpacity(0.18)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget buildTopBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tituloModo(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: mostrarNormas,
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.10),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: modeColors().first.withOpacity(0.20),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            widget.modo == 'chill'
                ? Icons.spa_rounded
                : widget.modo == 'erotico'
                ? Icons.local_fire_department_rounded
                : Icons.shuffle_rounded,
            color: modeColors().first,
            size: 42,
          ),
          const SizedBox(height: 20),
          Text(
            preguntaActual,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: Color(0xFF08051A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colors = modeColors();

    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.first.withOpacity(0.28),
                const Color(0xFF10091F),
                const Color(0xFF070411),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -50,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.first.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -70,
                right: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.last.withOpacity(0.10),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      buildTopBar(),
                      const SizedBox(height: 30),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: buildQuestionCard(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Preguntas restantes: ${preguntasRestantes.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: siguientePregunta,
                          style: mainButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Siguiente',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
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
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Reiniciar preguntas',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    ],
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