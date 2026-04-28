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
    final total = usadas + verdadesDisponibles.length + pruebasDisponibles.length;
    if (total == 0) return 0;
    return usadas / total;
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF171027),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cómo se juega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Un jugador elige Verdad o Prueba.\n\n'
                    'Si elige Verdad, debe responder sinceramente.\n\n'
                    'Si elige Prueba, debe hacer el reto.\n\n'
                    'Si se niega, bebe los tragos que indique la carta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFDB2777),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  ButtonStyle verdadButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF22C55E),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  ButtonStyle pruebaButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF97316),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withOpacity(0.25)),
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
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Prueba o Verdad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: mostrarNormas,
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildProgressInfo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.18),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Verdades: ${verdadesDisponibles.length} · Pruebas: ${pruebasDisponibles.length}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget buildCard() {
    final bool isVerdad = tipoActual == 'VERDAD';
    final bool isPrueba = tipoActual == 'PRUEBA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isVerdad
                  ? Colors.green.withOpacity(0.22)
                  : isPrueba
                  ? Colors.orange.withOpacity(0.22)
                  : Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              tipoActual.isEmpty ? 'ELIGE' : tipoActual,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 330),
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.18),
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
                color: Colors.white,
                fontSize: 28,
                height: 1.16,
                fontWeight: FontWeight.w900,
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
      backgroundColor: const Color(0xFF500724),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFDB2777),
                Color(0xFF9333EA),
                Color(0xFF3B0764),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                left: -60,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent.withOpacity(0.10),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      buildTopBar(),
                      const SizedBox(height: 22),
                      buildProgressInfo(),
                      const SizedBox(height: 22),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: buildCard(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: sacarVerdad,
                              style: verdadButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'VERDAD',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: sacarPrueba,
                              style: pruebaButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'PRUEBA',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: reiniciarJuego,
                          style: secondaryButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Reiniciar',
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