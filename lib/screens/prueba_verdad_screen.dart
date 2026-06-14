import 'dart:math';
import 'package:flutter/material.dart';
import '../data/prueba_verdad_data.dart';

class PruebaVerdadScreen extends StatefulWidget {
  const PruebaVerdadScreen({super.key});

  @override
  State<PruebaVerdadScreen> createState() => _PruebaVerdadScreenState();
}

class _PruebaVerdadScreenState extends State<PruebaVerdadScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentYellow = Color(0xFFFFD166);

  String textoActual = 'Elige Verdad o Prueba';
  String tipoActual = '';

  List<String> verdadesDisponibles = [];
  List<String> verdadesUsadas = [];

  List<String> pruebasDisponibles = [];
  List<String> pruebasUsadas = [];

  @override
  void initState() {
    super.initState();
    reiniciarBarajas();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      mostrarNormas();
    });
  }

  void reiniciarBarajas() {
    verdadesDisponibles = List<String>.from(preguntasVerdad)..shuffle(random);
    verdadesUsadas.clear();

    pruebasDisponibles = List<String>.from(pruebas)..shuffle(random);
    pruebasUsadas.clear();
  }

  String generarCastigo() {
    final tragos = random.nextInt(5) + 1;
    return 'Si no lo haces, bebe $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
  }

  void sacarVerdad() {
    if (verdadesDisponibles.isEmpty) {
      verdadesDisponibles = List<String>.from(verdadesUsadas)..shuffle(random);
      verdadesUsadas.clear();
    }

    final verdad = verdadesDisponibles.removeLast();

    setState(() {
      tipoActual = 'VERDAD';
      textoActual = '$verdad\n\n${generarCastigo()}';
      verdadesUsadas.add(verdad);
    });
  }

  void sacarPrueba() {
    if (pruebasDisponibles.isEmpty) {
      pruebasDisponibles = List<String>.from(pruebasUsadas)..shuffle(random);
      pruebasUsadas.clear();
    }

    final prueba = pruebasDisponibles.removeLast();

    setState(() {
      tipoActual = 'PRUEBA';
      textoActual = '$prueba\n\n${generarCastigo()}';
      pruebasUsadas.add(prueba);
    });
  }

  void reiniciarJuego() {
    setState(() {
      tipoActual = '';
      textoActual = 'Elige Verdad o Prueba';
      reiniciarBarajas();
    });
  }

  double get progreso {
    final usadas = verdadesUsadas.length + pruebasUsadas.length;
    final total =
        usadas + verdadesDisponibles.length + pruebasDisponibles.length;

    if (total == 0) return 0;

    return usadas / total;
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

  ButtonStyle verdadButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentGreen,
      foregroundColor: appWhite,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle pruebaButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentOrange,
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
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'prueba\no verdad',
                    style: TextStyle(
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
          left: const BorderSide(
            color: accentPink,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        'Elige si quieres responder una verdad o cumplir una prueba',
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

                  const Text(
                    'PRUEBA O VERDAD',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.question_answer_rounded,
                    title: 'Verdad',
                    text:
                    'Si eliges Verdad, tienes que responder sinceramente a la pregunta.',
                  ),

                  rulesItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Prueba',
                    text:
                    'Si eliges Prueba, tienes que hacer el reto que aparezca.',
                  ),

                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Si te niegas',
                    text:
                    'Cada carta añade un castigo. Si no quieres responder o hacer la prueba, bebes.',
                  ),

                  rulesItem(
                    icon: Icons.shuffle_rounded,
                    title: 'Sin repetir',
                    text:
                    'Las verdades y pruebas no se repiten hasta que se acaba su baraja.',
                  ),

                  rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Turnos',
                    text:
                    'Cada ronda juega una persona distinta. El jugador decide si quiere Verdad o Prueba.',
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

  Widget buildProgressInfo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.zero,
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: appWhite.withOpacity(0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(accentYellow),
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Verdades: ${verdadesDisponibles.length} · Pruebas: ${pruebasDisponibles.length}',
          style: TextStyle(
            color: appWhite.withOpacity(0.68),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget buildCard() {
    final bool isVerdad = tipoActual == 'VERDAD';
    final bool isPrueba = tipoActual == 'PRUEBA';

    Color tagColor = appWhite.withOpacity(0.18);

    if (isVerdad) {
      tagColor = accentGreen;
    } else if (isPrueba) {
      tagColor = accentOrange;
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: tagColor,
              border: Border.all(
                color: appWhite.withOpacity(0.26),
                width: 1.2,
              ),
            ),
            child: Text(
              tipoActual.isEmpty ? 'ELIGE' : tipoActual,
              style: TextStyle(
                color: isPrueba ? appBlue : appWhite,
                fontSize: 13,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 24),

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
              textoActual,
              key: ValueKey(textoActual),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontSize: 29,
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

  @override
  Widget build(BuildContext context) {
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

              buildProgressInfo(),

              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: buildCard(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sacarVerdad,
                      style: verdadButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'VERDAD',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sacarPrueba,
                      style: pruebaButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'PRUEBA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: reiniciarJuego,
                  style: secondaryButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'REINICIAR',
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