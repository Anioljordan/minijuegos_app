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

  String accionActual = "Pulsa siguiente para empezar";

  List<String> accionesDisponibles = [];
  List<String> accionesUsadas = [];

  @override
  void initState() {
    super.initState();
    reiniciarBaraja();
  }

  void reiniciarBaraja() {
    accionesDisponibles =
    List<String>.from(unoDosAcciones)..shuffle(random);

    accionesUsadas.clear();
  }

  void reiniciarJuego() {
    setState(() {
      accionActual = "Pulsa siguiente para empezar";
      reiniciarBaraja();
    });
  }

  // LIMPIAR TEXTOS ANTIGUOS

  String limpiarAccion(String texto) {
    return texto
        .replaceAll(" bebe.", "")
        .replaceAll(" bebe", "")
        .replaceAll(" Reparte 2 tragos.", "")
        .replaceAll(" Reparte 2 tragos", "")
        .trim();
  }

  // GENERAR CASTIGO

  String generarCastigo() {

    int tragos = random.nextInt(5) + 1;

    bool repartir = random.nextBool();

    if (repartir) {
      return "Reparte $tragos ${tragos == 1 ? "trago" : "tragos"}.";
    }

    return "Bebe $tragos ${tragos == 1 ? "trago" : "tragos"}.";
  }

  // SIGUIENTE ACCIÓN

  void siguienteAccion() {

    if (accionesDisponibles.isEmpty) {

      accionesDisponibles =
      List<String>.from(accionesUsadas)
        ..shuffle(random);

      accionesUsadas.clear();
    }

    final base =
    accionesDisponibles.removeLast();

    final limpia =
    limpiarAccion(base);

    final castigo =
    generarCastigo();

    final finalTexto =
        "$limpia\n\n$castigo";

    setState(() {

      accionActual = finalTexto;

      accionesUsadas.add(base);

    });
  }

  double get progreso {

    final total =
        accionesDisponibles.length +
            accionesUsadas.length;

    if (total == 0) return 0;

    return accionesUsadas.length / total;
  }

  void mostrarNormas() {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Se eligen dos jugadores:\n'
              'Jugador 1 y Jugador 2.\n\n'
              'Lee la acción.\n'
              'Si alguien no quiere hacerlo,\n'
              'debe beber.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFF2E1065),

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(
            colors: [
              Color(0xFF9333EA),
              Color(0xFF6D28D9),
              Color(0xFF3B0764),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),

        ),

        child: SafeArea(

          child: Padding(

            padding: const EdgeInsets.all(18),

            child: Column(

              children: [

                // TOP BAR

                Row(

                  children: [

                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                    ),

                    const Expanded(
                      child: Text(
                        "1 y 2",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: mostrarNormas,
                      icon: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                      ),
                    ),

                  ],

                ),

                const SizedBox(height: 16),

                // PROGRESS

                LinearProgressIndicator(
                  value: progreso,
                  backgroundColor:
                  Colors.white.withOpacity(0.2),
                  valueColor:
                  const AlwaysStoppedAnimation(
                      Colors.white),
                ),

                const SizedBox(height: 8),

                Text(
                  "Restantes: ${accionesDisponibles.length}",
                  style: TextStyle(
                    color:
                    Colors.white.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // CARD

                Expanded(

                  child: Center(

                    child: Container(

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(

                        color:
                        Colors.white.withOpacity(0.1),

                        borderRadius:
                        BorderRadius.circular(28),

                        border: Border.all(
                          color: Colors.white
                              .withOpacity(0.15),
                        ),

                      ),

                      child: AnimatedSwitcher(

                        duration:
                        const Duration(milliseconds: 300),

                        transitionBuilder:
                            (child, animation) {

                          return SlideTransition(

                            position: Tween<Offset>(

                              begin:
                              const Offset(0, 0.2),

                              end: Offset.zero,

                            ).animate(animation),

                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),

                          );

                        },

                        child: Text(

                          accionActual,

                          key:
                          ValueKey(accionActual),

                          textAlign:
                          TextAlign.center,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                            FontWeight.bold,
                          ),

                        ),

                      ),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                // BOTÓN SIGUIENTE

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: siguienteAccion,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                      const Color(0xFF6D28D9),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),

                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(
                          vertical: 16),
                      child: Text(
                        "SIGUIENTE",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ),

                  ),

                ),

                const SizedBox(height: 10),

                // REINICIAR

                SizedBox(

                  width: double.infinity,

                  child: OutlinedButton(

                    onPressed: reiniciarJuego,

                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color:
                        Colors.white.withOpacity(0.3),
                      ),
                    ),

                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(
                          vertical: 14),
                      child: Text(
                        "Reiniciar",
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
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

    );

  }

}