import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CuatroEnRayaScreen extends StatefulWidget {
  const CuatroEnRayaScreen({super.key});

  @override
  State<CuatroEnRayaScreen> createState() => _CuatroEnRayaScreenState();
}

class _CuatroEnRayaScreenState extends State<CuatroEnRayaScreen> {
  static const int filas = 6;
  static const int columnas = 7;

  List<List<int>> tablero = List.generate(
    filas,
        (_) => List.filled(columnas, 0),
  );

  int jugadorActual = 1;
  int jugadorInicial = 1;
  bool juegoTerminado = false;

  int puntosRojo = 0;
  int puntosAmarillo = 0;
  int empates = 0;

  int? hoverColumna;
  bool animando = false;
  int? animColumna;
  int? animJugador;
  int animFilaVisual = 0;

  List<List<int>> fichasGanadoras = [];
  List<List<int>> historialJugadas = [];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> reproducirSonido(String asset) async {
    try {
      await _audioPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  Color colorFicha(int valor) {
    if (valor == 1) return const Color(0xFFFF4D6D);
    if (valor == 2) return const Color(0xFFFFD166);
    return const Color(0xFFEFF6FF);
  }

  Color colorJugadorActual() {
    return jugadorActual == 1
        ? const Color(0xFFFF4D6D)
        : const Color(0xFFFFD166);
  }

  String textoTurno() {
    if (juegoTerminado && fichasGanadoras.isNotEmpty) return 'Tenemos ganador';
    if (juegoTerminado) return 'Partida terminada';
    return jugadorActual == 1 ? 'Turno del rojo' : 'Turno del amarillo';
  }

  int? obtenerFilaDisponible(int columna) {
    for (int fila = filas - 1; fila >= 0; fila--) {
      if (tablero[fila][columna] == 0) return fila;
    }
    return null;
  }

  Future<void> colocarFicha(int columna) async {
    if (juegoTerminado || animando) return;

    final filaDisponible = obtenerFilaDisponible(columna);
    if (filaDisponible == null) return;

    setState(() {
      animando = true;
      animColumna = columna;
      animJugador = jugadorActual;
      animFilaVisual = 0;
      hoverColumna = null;
    });

    for (int fila = 0; fila <= filaDisponible; fila++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() => animFilaVisual = fila);
    }

    if (!mounted) return;

    HapticFeedback.mediumImpact();
    await reproducirSonido('sounds/drop.wav');

    setState(() {
      tablero[filaDisponible][columna] = jugadorActual;
      historialJugadas.add([filaDisponible, columna, jugadorActual]);
      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
    });

    final ganadoras = obtenerFichasGanadoras(jugadorActual);

    if (ganadoras.isNotEmpty) {
      setState(() {
        juegoTerminado = true;
        fichasGanadoras = ganadoras;
        if (jugadorActual == 1) {
          puntosRojo++;
        } else {
          puntosAmarillo++;
        }
      });

      HapticFeedback.heavyImpact();
      await reproducirSonido('sounds/win.wav');

      await Future.delayed(const Duration(milliseconds: 1100));
      if (!mounted) return;

      mostrarResultado(
        jugadorActual == 1 ? 'Ha ganado el rojo' : 'Ha ganado el amarillo',
      );
      return;
    }

    if (tableroLleno()) {
      setState(() {
        juegoTerminado = true;
        empates++;
      });

      HapticFeedback.selectionClick();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      mostrarResultado('Empate');
      return;
    }

    setState(() {
      jugadorActual = jugadorActual == 1 ? 2 : 1;
    });
  }

  bool tableroLleno() {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        if (tablero[fila][columna] == 0) return false;
      }
    }
    return true;
  }

  List<List<int>> obtenerFichasGanadoras(int jugador) {
    for (int fila = 0; fila < filas; fila++) {
      for (int columna = 0; columna < columnas; columna++) {
        if (tablero[fila][columna] == jugador) {
          final horizontal =
          comprobarDireccionConCoords(fila, columna, 0, 1, jugador);
          if (horizontal.isNotEmpty) return horizontal;

          final vertical =
          comprobarDireccionConCoords(fila, columna, 1, 0, jugador);
          if (vertical.isNotEmpty) return vertical;

          final diagonalDerecha =
          comprobarDireccionConCoords(fila, columna, 1, 1, jugador);
          if (diagonalDerecha.isNotEmpty) return diagonalDerecha;

          final diagonalIzquierda =
          comprobarDireccionConCoords(fila, columna, 1, -1, jugador);
          if (diagonalIzquierda.isNotEmpty) return diagonalIzquierda;
        }
      }
    }

    return [];
  }

  List<List<int>> comprobarDireccionConCoords(
      int fila,
      int columna,
      int deltaFila,
      int deltaColumna,
      int jugador,
      ) {
    final List<List<int>> coords = [];

    for (int i = 0; i < 4; i++) {
      final nuevaFila = fila + i * deltaFila;
      final nuevaColumna = columna + i * deltaColumna;

      if (nuevaFila < 0 ||
          nuevaFila >= filas ||
          nuevaColumna < 0 ||
          nuevaColumna >= columnas ||
          tablero[nuevaFila][nuevaColumna] != jugador) {
        return [];
      }

      coords.add([nuevaFila, nuevaColumna]);
    }

    return coords;
  }

  bool esFichaGanadora(int fila, int columna) {
    return fichasGanadoras.any(
          (coord) => coord[0] == fila && coord[1] == columna,
    );
  }

  void deshacerJugada() {
    if (historialJugadas.isEmpty || animando || juegoTerminado) return;

    final ultima = historialJugadas.removeLast();
    final fila = ultima[0];
    final columna = ultima[1];
    final jugadorDeLaJugada = ultima[2];

    setState(() {
      tablero[fila][columna] = 0;
      jugadorActual = jugadorDeLaJugada;
      fichasGanadoras = [];
      hoverColumna = null;
    });

    HapticFeedback.selectionClick();
  }

  void reiniciarJuego() {
    setState(() {
      tablero = List.generate(filas, (_) => List.filled(columnas, 0));
      jugadorInicial = jugadorInicial == 1 ? 2 : 1;
      jugadorActual = jugadorInicial;
      juegoTerminado = false;
      hoverColumna = null;
      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
      fichasGanadoras = [];
      historialJugadas = [];
    });
  }

  void reiniciarMarcadorYJuego() {
    setState(() {
      puntosRojo = 0;
      puntosAmarillo = 0;
      empates = 0;
      tablero = List.generate(filas, (_) => List.filled(columnas, 0));
      jugadorInicial = 1;
      jugadorActual = 1;
      juegoTerminado = false;
      hoverColumna = null;
      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
      fichasGanadoras = [];
      historialJugadas = [];
    });
  }

  ButtonStyle mainButtonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
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
      side: BorderSide(color: Colors.white.withOpacity(0.20)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
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
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Dos jugadores se turnan para colocar fichas.\n\n'
                    'Pulsa una columna y la ficha caerá al hueco más bajo.\n\n'
                    'Gana quien consiga conectar 4 fichas en línea.',
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
                  style: mainButtonStyle(const Color(0xFF2563EB)),
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

  void mostrarResultado(String mensaje) {
    final bool empate = mensaje == 'Empate';
    final bool ganaRojo = mensaje == 'Ha ganado el rojo';

    final List<Color> colors = empate
        ? const [Color(0xFF334155), Color(0xFF111827)]
        : ganaRojo
        ? const [Color(0xFFFF4D6D), Color(0xFFBE123C)]
        : const [Color(0xFFFFD166), Color(0xFFF59E0B)];

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Resultado',
      barrierColor: Colors.black.withOpacity(0.70),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    empate
                        ? Icons.handshake_rounded
                        : Icons.emoji_events_rounded,
                    size: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    empate ? 'EMPATE' : 'VICTORIA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mensaje,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            reiniciarJuego();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Revancha',
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
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            reiniciarMarcadorYJuego();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Reset total',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return Transform.scale(
          scale: curved.value,
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
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
            '4 en Raya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 31,
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

  Widget scorePill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMarcador() {
    return Row(
      children: [
        scorePill(
          label: 'Rojo',
          value: '$puntosRojo',
          color: const Color(0xFFFF4D6D),
          icon: Icons.circle,
        ),
        const SizedBox(width: 10),
        scorePill(
          label: 'Empates',
          value: '$empates',
          color: Colors.white70,
          icon: Icons.handshake_rounded,
        ),
        const SizedBox(width: 10),
        scorePill(
          label: 'Amarillo',
          value: '$puntosAmarillo',
          color: const Color(0xFFFFD166),
          icon: Icons.circle,
        ),
      ],
    );
  }

  Widget buildTurnCard() {
    final colorTurno = colorJugadorActual();

    return glassCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: juegoTerminado ? Colors.white54 : colorTurno,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorTurno.withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textoTurno(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  animando
                      ? 'La ficha está cayendo...'
                      : 'Pulsa una columna para jugar',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.66),
                    fontSize: 14,
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

  Widget buildPreviewRow() {
    return Row(
      children: List.generate(columnas, (columna) {
        final bool mostrarPreview = !juegoTerminado &&
            !animando &&
            hoverColumna == columna &&
            obtenerFilaDisponible(columna) != null;

        return Expanded(
          child: MouseRegion(
            onEnter: (_) {
              if (!animando && !juegoTerminado) {
                setState(() => hoverColumna = columna);
              }
            },
            onExit: (_) {
              if (!animando && !juegoTerminado && hoverColumna == columna) {
                setState(() => hoverColumna = null);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => colocarFicha(columna),
              child: SizedBox(
                height: 42,
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    scale: mostrarPreview ? 1 : 0.65,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: mostrarPreview ? 1 : 0,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorJugadorActual().withOpacity(0.80),
                          boxShadow: [
                            BoxShadow(
                              color: colorJugadorActual().withOpacity(0.45),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildCelda(int fila, int columna) {
    final bool mostrarFichaAnimada = animando &&
        animColumna == columna &&
        animFilaVisual == fila &&
        animJugador != null;

    final int valorCelda = tablero[fila][columna];
    final bool ganadora = esFichaGanadora(fila, columna);
    final bool hover = hoverColumna == columna && !animando && !juegoTerminado;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) {
          if (!animando && !juegoTerminado) {
            setState(() => hoverColumna = columna);
          }
        },
        onExit: (_) {
          if (!animando && !juegoTerminado && hoverColumna == columna) {
            setState(() => hoverColumna = null);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => colocarFicha(columna),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: hover
                  ? Colors.white.withOpacity(0.20)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: ganadora ? 1.08 : 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mostrarFichaAnimada
                        ? colorFicha(animJugador!)
                        : colorFicha(valorCelda),
                    border: Border.all(
                      color: ganadora
                          ? Colors.white
                          : Colors.black.withOpacity(0.08),
                      width: ganadora ? 4 : 1,
                    ),
                    boxShadow: [
                      if (valorCelda != 0 || mostrarFichaAnimada)
                        BoxShadow(
                          color: (mostrarFichaAnimada
                              ? colorFicha(animJugador!)
                              : colorFicha(valorCelda))
                              .withOpacity(0.45),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      if (ganadora)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.75),
                          blurRadius: 22,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTablero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardWidth = constraints.maxWidth;
        final boardHeight = constraints.maxHeight;
        final cellWidth = boardWidth / columnas;
        final cellHeight = boardHeight / filas;

        return Stack(
          children: [
            Column(
              children: List.generate(filas, (fila) {
                return Expanded(
                  child: Row(
                    children: List.generate(
                      columnas,
                          (columna) => buildCelda(fila, columna),
                    ),
                  ),
                );
              }),
            ),
            if (fichasGanadoras.length == 4)
              IgnorePointer(
                child: CustomPaint(
                  size: Size(boardWidth, boardHeight),
                  painter: WinningLinePainter(
                    fichasGanadoras: fichasGanadoras,
                    cellWidth: cellWidth,
                    cellHeight: cellHeight,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildBoardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB).withOpacity(0.95),
            const Color(0xFF1D4ED8).withOpacity(0.95),
            const Color(0xFF312E81).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: buildTablero(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2563EB),
                Color(0xFF1E1B4B),
                Color(0xFF08051A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
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
                bottom: -100,
                right: -70,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellowAccent.withOpacity(0.08),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      buildTopBar(),
                      const SizedBox(height: 18),
                      buildMarcador(),
                      const SizedBox(height: 14),
                      buildTurnCard(),
                      const SizedBox(height: 12),
                      buildPreviewRow(),
                      const SizedBox(height: 8),
                      Expanded(child: buildBoardCard()),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: historialJugadas.isEmpty ||
                                  animando ||
                                  juegoTerminado
                                  ? null
                                  : deshacerJugada,
                              style: secondaryButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'Deshacer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: reiniciarJuego,
                              style: mainButtonStyle(const Color(0xFF8B5CF6)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Text(
                                  'Reiniciar',
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

class WinningLinePainter extends CustomPainter {
  final List<List<int>> fichasGanadoras;
  final double cellWidth;
  final double cellHeight;

  WinningLinePainter({
    required this.fichasGanadoras,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fichasGanadoras.length != 4) return;

    final sorted = List<List<int>>.from(fichasGanadoras)
      ..sort((a, b) {
        if (a[0] != b[0]) return a[0].compareTo(b[0]);
        return a[1].compareTo(b[1]);
      });

    final first = sorted.first;
    final last = sorted.last;

    final start = Offset(
      first[1] * cellWidth + cellWidth / 2,
      first[0] * cellHeight + cellHeight / 2,
    );

    final end = Offset(
      last[1] * cellWidth + cellWidth / 2,
      last[0] * cellHeight + cellHeight / 2,
    );

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, glowPaint);
    canvas.drawLine(start, end, linePaint);
  }

  @override
  bool shouldRepaint(covariant WinningLinePainter oldDelegate) {
    return oldDelegate.fichasGanadoras != fichasGanadoras;
  }
}