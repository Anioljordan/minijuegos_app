import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_settings.dart';

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

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);

  static const Color boardBlue = Color(0xFF24458E);
  static const Color boardBlueDark = Color(0xFF1D3979);
  static const Color boardBlueLight = Color(0xFF7E96D6);
  static const Color emptyHoleColor = Color(0xFF2F4F9C);

  static const Color redDisc = Color(0xFFE63946);
  static const Color yellowDisc = Color(0xFFFFD166);

  @override
  void initState() {
    super.initState();

    AppSettings.instance.load();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  Widget _rulesItem({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> reproducirSonido(String asset) async {
    final settings = AppSettings.instance;

    if (!settings.soundEnabled) return;

    try {
      await _audioPlayer.setVolume(settings.volume);
      await _audioPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  void vibrarMedium() {
    if (!AppSettings.instance.vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void vibrarHeavy() {
    if (!AppSettings.instance.vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void vibrarClick() {
    if (!AppSettings.instance.vibrationEnabled) return;
    HapticFeedback.selectionClick();
  }

  Color colorFicha(int valor) {
    if (valor == 1) return redDisc;
    if (valor == 2) return yellowDisc;
    return emptyHoleColor;
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
  Widget _buildDisc({
    required int valor,
    required bool mostrarFichaAnimada,
    required bool ganadora,
  }) {
    final int valorVisual = mostrarFichaAnimada ? (animJugador ?? 0) : valor;
    final bool vacio = valorVisual == 0;
    final Color discColor = colorFicha(valorVisual);

    return LayoutBuilder(
      builder: (context, constraints) {
        final rawSize = math.min(constraints.maxWidth, constraints.maxHeight);
        final outerSize = rawSize * 0.86;
        final innerSize = outerSize * 0.82;

        return AnimatedScale(
          duration: const Duration(milliseconds: 220),
          scale: ganadora ? 1.08 : 1.0,
          child: SizedBox(
            width: outerSize,
            height: outerSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: outerSize,
                  height: outerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: boardBlueLight.withOpacity(0.85),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: innerSize,
                  height: innerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: vacio ? emptyHoleColor : discColor,
                    border: Border.all(
                      color: vacio
                          ? boardBlueDark
                          : appWhite.withOpacity(ganadora ? 0.95 : 0.45),
                      width: ganadora ? 3 : 1.8,
                    ),
                    boxShadow: [
                      if (!vacio)
                        BoxShadow(
                          color: discColor.withOpacity(0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      if (ganadora)
                        BoxShadow(
                          color: appWhite.withOpacity(0.75),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                ),

                if (!vacio)
                  Positioned(
                    top: innerSize * 0.18,
                    left: innerSize * 0.28,
                    right: innerSize * 0.28,
                    child: Container(
                      height: innerSize * 0.16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          colors: [
                            appWhite.withOpacity(0.42),
                            appWhite.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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

    vibrarMedium();
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

      vibrarHeavy();
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

      vibrarClick();
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


  Widget glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.30),
          width: 1.4,
        ),
      ),
      child: child,
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
                    '4 EN RAYA',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _rulesItem(
                    icon: Icons.touch_app_rounded,
                    title: 'Coloca ficha',
                    text:
                    'Pulsa una columna. La ficha caerá hasta el hueco más bajo.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Turnos',
                    text:
                    'Los jugadores se alternan entre rojo y amarillo.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.blur_linear_rounded,
                    title: 'Objetivo',
                    text:
                    'Gana quien conecte 4 fichas en horizontal, vertical o diagonal.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.undo_rounded,
                    title: 'Deshacer',
                    text:
                    'Puedes deshacer la última jugada antes de que termine la partida.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Marcador',
                    text:
                    'Cada victoria suma un punto. Los empates también se cuentan.',
                    color: appWhite,
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(appWhite),
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

  void mostrarResultado(String mensaje) {
    final bool empate = mensaje == 'Empate';
    final bool ganaRojo = mensaje == 'Ha ganado el rojo';

    final Color accentColor = empate
        ? appWhite
        : ganaRojo
        ? redDisc
        : yellowDisc;

    final String titulo = empate ? 'empate' : 'victoria';

    final String subtitulo = empate
        ? 'La partida termina sin ganador'
        : ganaRojo
        ? 'Gana el jugador rojo'
        : 'Gana el jugador amarillo';

    final IconData icon = empate
        ? Icons.handshake_rounded
        : Icons.emoji_events_rounded;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Resultado',
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: appBlue,
              border: Border.all(
                color: appWhite.withOpacity(0.75),
                width: 2.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appWhite.withOpacity(0.85),
                            width: 2.2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: accentColor,
                          size: 31,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          titulo,
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 40,
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

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: appWhite.withOpacity(0.08),
                      border: Border.all(
                        color: appWhite.withOpacity(0.26),
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                            border: Border.all(
                              color: appWhite.withOpacity(0.75),
                              width: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          subtitulo.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          empate
                              ? 'Nadie ha conseguido conectar 4 fichas.'
                              : 'Se ha conectado una línea de 4 fichas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite.withOpacity(0.72),
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            reiniciarJuego();
                          },
                          style: mainButtonStyle(appWhite),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'REVANCHA',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
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
                          style: secondaryButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'RESET',
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
          scale: 0.92 + (curved.value * 0.08),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    );
  }

  Widget buildTopBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '8',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: mostrarNormas,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.question_mark_rounded,
                  color: appWhite,
                  size: 28,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 72),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 82,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    '4 en raya',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 58,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                Positioned(
                  top: 62,
                  left: 0,
                  right: -30,
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

  Widget scorePill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: appWhite,
          border: Border.all(
            color: appWhite.withOpacity(0.75),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: appBlue,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appBlue.withOpacity(0.70),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.07),
        border: Border(
          left: BorderSide(
            color: colorTurno,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.40),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: juegoTerminado ? appWhite.withOpacity(0.55) : colorTurno,
              shape: BoxShape.circle,
              border: Border.all(
                color: appWhite.withOpacity(0.75),
                width: 1.6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textoTurno(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  animando
                      ? 'La ficha está cayendo...'
                      : 'Pulsa una columna para jugar',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.68),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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
                height: 22,
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    scale: mostrarPreview ? 1 : 0.65,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: mostrarPreview ? 1 : 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorJugadorActual().withOpacity(0.85),
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
          child: SizedBox.expand(
            child: Center(
              child: _buildDisc(
                valor: valorCelda,
                mostrarFichaAnimada: mostrarFichaAnimada,
                ganadora: ganadora,
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
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: boardBlue,
        border: Border.all(
          color: appWhite.withOpacity(0.75),
          width: 2.5,
        ),
      ),
      child: AspectRatio(
        aspectRatio: columnas / filas,
        child: buildTablero(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: appBlue,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                children: [
                  buildTopBar(),

                  const SizedBox(height: 14),

                  buildMarcador(),

                  const SizedBox(height: 8),

                  buildTurnCard(),

                  const SizedBox(height: 4),

                  buildPreviewRow(),

                  const SizedBox(height: 4),

                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: buildBoardCard(),
                    ),
                  ),

                  const SizedBox(height: 12),

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
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Text(
                              'DESHACER',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: reiniciarJuego,
                          style: mainButtonStyle(appWhite),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 13),
                            child: Text(
                              'REINICIAR',
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
                ],
              ),
            ),
          ),
        );
      },
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