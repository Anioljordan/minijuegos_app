import 'dart:math';
import 'package:flutter/material.dart';
import '../data/uno_dos_data.dart';

class UnoDosScreen extends StatefulWidget {
  const UnoDosScreen({super.key});

  @override
  State<UnoDosScreen> createState() => _UnoDosScreenState();
}

class _UnoDosScreenState extends State<UnoDosScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentGreen = Color(0xFF22C55E);

  String accionActual = 'Pulsa siguiente para empezar';

  List<String> accionesDisponibles = [];
  List<String> accionesUsadas = [];

  @override
  void initState() {
    super.initState();
    reiniciarBaraja();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      mostrarNormas();
    });
  }

  void reiniciarBaraja() {
    accionesDisponibles = List<String>.from(unoDosAcciones)..shuffle(random);
    accionesUsadas.clear();
  }

  void reiniciarJuego() {
    setState(() {
      accionActual = 'Pulsa siguiente para empezar';
      reiniciarBaraja();
    });
  }

  String limpiarAccion(String texto) {
    return texto
        .replaceAll(' bebe.', '')
        .replaceAll(' bebe', '')
        .replaceAll(' Reparte 2 tragos.', '')
        .replaceAll(' Reparte 2 tragos', '')
        .trim();
  }

  String generarCastigo() {
    final tragos = random.nextInt(5) + 1;
    final repartir = random.nextBool();

    if (repartir) {
      return 'Reparte $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
    }

    return 'Bebe $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
  }

  void siguienteAccion() {
    if (accionesDisponibles.isEmpty) {
      accionesDisponibles = List<String>.from(accionesUsadas)..shuffle(random);
      accionesUsadas.clear();
    }

    final base = accionesDisponibles.removeLast();
    final limpia = limpiarAccion(base);
    final castigo = generarCastigo();

    setState(() {
      accionActual = '$limpia\n\n$castigo';
      accionesUsadas.add(base);
    });
  }

  double get progreso {
    final total = accionesDisponibles.length + accionesUsadas.length;
    if (total == 0) return 0;
    return accionesUsadas.length / total;
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
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    '1 y 2',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 48,
                      height: 1.90,
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
            color: accentYellow,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        'Lee la acción para jugador 1 y jugador 2',
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
                    '1 Y 2',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.looks_one_rounded,
                    title: 'Jugador 1',
                    text: 'La acción suele empezar con una persona como jugador 1.',
                  ),

                  rulesItem(
                    icon: Icons.looks_two_rounded,
                    title: 'Jugador 2',
                    text: 'Después se elige o se menciona otra persona como jugador 2.',
                  ),

                  rulesItem(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Lee la acción',
                    text: 'Lee la carta en voz alta y haced lo que diga.',
                  ),

                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Castigo',
                    text: 'Cada carta añade beber o repartir de 1 a 5 tragos.',
                  ),

                  rulesItem(
                    icon: Icons.shuffle_rounded,
                    title: 'Sin repetir',
                    text: 'Las acciones no se repiten hasta que se acabe la baraja.',
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

  Widget buildActionCard() {
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
            child: const Icon(
              Icons.visibility_rounded,
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
              accionActual,
              key: ValueKey(accionActual),
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
          'Acciones restantes: ${accionesDisponibles.length}',
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
                    child: buildActionCard(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: siguienteAccion,
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