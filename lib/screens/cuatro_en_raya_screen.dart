import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:flutter/services.dart';
import '../core/app_settings.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

enum CuatroEnRayaMode { twoPlayers, vsMachine }

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

  CuatroEnRayaMode modoJuego = CuatroEnRayaMode.twoPlayers;
  bool maquinaPensando = false;

  bool get esTurnoMaquina =>
      modoJuego == CuatroEnRayaMode.vsMachine && jugadorActual == 2;

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

  static const Color boardBlue = Color(0xFF24458E);
  static const Color boardBlueDark = Color(0xFF1D3979);
  static const Color boardBlueLight = Color(0xFF7E96D6);
  static const Color emptyHoleColor = Color(0xFF2F4F9C);

  static const Color redDisc = CuboColors.alert;
  static const Color yellowDisc = CuboColors.fiesta;

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
    return CuboRulesItem(icon: icon, title: title, text: text, color: color);
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
    if (juegoTerminado && fichasGanadoras.isNotEmpty) {
      return 'Tenemos ganador';
    }

    if (juegoTerminado) {
      return 'Partida terminada';
    }

    if (modoJuego == CuatroEnRayaMode.vsMachine) {
      return jugadorActual == 1 ? 'Tu turno' : 'Turno de la máquina';
    }

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
                    color: boardBlueLight.withValues(alpha: 0.85),
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
                          : CuboColors.white.withValues(
                              alpha: ganadora ? 0.95 : 0.45,
                            ),
                      width: ganadora ? 3 : 1.8,
                    ),
                    boxShadow: [
                      if (!vacio)
                        BoxShadow(
                          color: discColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      if (ganadora)
                        BoxShadow(
                          color: CuboColors.white.withValues(alpha: 0.75),
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
                            CuboColors.white.withValues(alpha: 0.42),
                            CuboColors.white.withValues(alpha: 0.0),
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

  List<int> _columnasDisponibles() {
    return List.generate(
      columnas,
      (index) => index,
    ).where((columna) => obtenerFilaDisponible(columna) != null).toList();
  }

  bool _esMovimientoGanador(int columna, int jugador) {
    final fila = obtenerFilaDisponible(columna);

    if (fila == null) return false;

    tablero[fila][columna] = jugador;

    final gana = obtenerFichasGanadoras(jugador).isNotEmpty;

    tablero[fila][columna] = 0;

    return gana;
  }

  bool _movimientoSeguroParaMaquina(int columna) {
    final fila = obtenerFilaDisponible(columna);

    if (fila == null) return false;

    // Simulamos la ficha de la máquina.
    tablero[fila][columna] = 2;

    final humanoPuedeGanar = _columnasDisponibles().any(
      (columnaHumano) => _esMovimientoGanador(columnaHumano, 1),
    );

    tablero[fila][columna] = 0;

    return !humanoPuedeGanar;
  }

  int _elegirColumnaMaquina() {
    final disponibles = _columnasDisponibles();

    if (disponibles.isEmpty) return 0;

    // 1. Ganar.
    for (final columna in disponibles) {
      if (_esMovimientoGanador(columna, 2)) {
        return columna;
      }
    }

    // 2. Bloquear al jugador.
    for (final columna in disponibles) {
      if (_esMovimientoGanador(columna, 1)) {
        return columna;
      }
    }

    // 3. Priorizar el centro y evitar regalar
    // una victoria inmediata.
    const prioridad = [3, 2, 4, 1, 5, 0, 6];

    final seguras = prioridad
        .where(
          (columna) =>
              disponibles.contains(columna) &&
              _movimientoSeguroParaMaquina(columna),
        )
        .toList();

    if (seguras.isNotEmpty) {
      return seguras.first;
    }

    // 4. Si no existe una jugada segura,
    // elegir la mejor columna disponible.
    return prioridad.firstWhere(
      disponibles.contains,
      orElse: () => disponibles[_randomIndex(disponibles.length)],
    );
  }

  int _randomIndex(int length) {
    return math.Random().nextInt(length);
  }

  Future<void> _jugarMaquina() async {
    if (!mounted ||
        modoJuego != CuatroEnRayaMode.vsMachine ||
        jugadorActual != 2 ||
        juegoTerminado ||
        animando ||
        maquinaPensando) {
      return;
    }

    setState(() {
      maquinaPensando = true;
      hoverColumna = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 650));

      if (!mounted || juegoTerminado || jugadorActual != 2) {
        return;
      }

      final columna = _elegirColumnaMaquina();

      await colocarFicha(columna, movimientoMaquina: true);
    } finally {
      if (mounted) {
        setState(() {
          maquinaPensando = false;
        });
      }
    }
  }

  Future<void> colocarFicha(
    int columna, {
    bool movimientoMaquina = false,
  }) async {
    if (juegoTerminado || animando) return;

    if (modoJuego == CuatroEnRayaMode.vsMachine) {
      if (jugadorActual == 2 && !movimientoMaquina) {
        return;
      }

      if (movimientoMaquina && jugadorActual != 2) {
        return;
      }
    }

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

      setState(() {
        animFilaVisual = fila;
      });
    }

    if (!mounted) return;

    vibrarMedium();
    await reproducirSonido('sounds/drop.wav');

    final jugadorQueHaJugado = jugadorActual;

    setState(() {
      tablero[filaDisponible][columna] = jugadorQueHaJugado;

      historialJugadas.add([filaDisponible, columna, jugadorQueHaJugado]);

      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
    });

    final ganadoras = obtenerFichasGanadoras(jugadorQueHaJugado);

    if (ganadoras.isNotEmpty) {
      setState(() {
        juegoTerminado = true;
        fichasGanadoras = ganadoras;

        if (jugadorQueHaJugado == 1) {
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
        jugadorQueHaJugado == 1 ? 'Ha ganado el rojo' : 'Ha ganado el amarillo',
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
      jugadorActual = jugadorQueHaJugado == 1 ? 2 : 1;
    });

    if (modoJuego == CuatroEnRayaMode.vsMachine && jugadorActual == 2) {
      await _jugarMaquina();
    }
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
          final horizontal = comprobarDireccionConCoords(
            fila,
            columna,
            0,
            1,
            jugador,
          );
          if (horizontal.isNotEmpty) return horizontal;

          final vertical = comprobarDireccionConCoords(
            fila,
            columna,
            1,
            0,
            jugador,
          );
          if (vertical.isNotEmpty) return vertical;

          final diagonalDerecha = comprobarDireccionConCoords(
            fila,
            columna,
            1,
            1,
            jugador,
          );
          if (diagonalDerecha.isNotEmpty) return diagonalDerecha;

          final diagonalIzquierda = comprobarDireccionConCoords(
            fila,
            columna,
            1,
            -1,
            jugador,
          );
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
    final movimientosAEliminar = modoJuego == CuatroEnRayaMode.vsMachine
        ? 2
        : 1;

    if (historialJugadas.length < movimientosAEliminar ||
        animando ||
        maquinaPensando ||
        juegoTerminado) {
      return;
    }

    int jugadorQueRepite = jugadorActual;

    setState(() {
      for (int i = 0; i < movimientosAEliminar; i++) {
        final ultima = historialJugadas.removeLast();

        tablero[ultima[0]][ultima[1]] = 0;
        jugadorQueRepite = ultima[2];
      }

      jugadorActual = modoJuego == CuatroEnRayaMode.vsMachine
          ? 1
          : jugadorQueRepite;

      fichasGanadoras = [];
      hoverColumna = null;
    });

    vibrarClick();
  }

  void reiniciarJuego() {
    final siguienteJugadorInicial = jugadorInicial == 1 ? 2 : 1;

    setState(() {
      tablero = List.generate(filas, (_) => List.filled(columnas, 0));

      jugadorInicial = siguienteJugadorInicial;
      jugadorActual = siguienteJugadorInicial;
      juegoTerminado = false;
      maquinaPensando = false;
      hoverColumna = null;
      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
      fichasGanadoras = [];
      historialJugadas = [];
    });

    if (modoJuego == CuatroEnRayaMode.vsMachine && jugadorActual == 2) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _jugarMaquina();
        }
      });
    }
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
    return CuboButtons.primary(padding: null);
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(padding: null);
  }

  Widget glassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: CuboDecorations.glass(),
      child: child,
    );
  }

  void mostrarNormas() {
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),

                  const SizedBox(height: 18),

                  const Text(
                    '4 EN RAYA',
                    style: TextStyle(
                      color: CuboColors.white,
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
                    color: CuboColors.white,
                  ),

                  _rulesItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Turnos',
                    text: 'Los jugadores se alternan entre rojo y amarillo.',
                    color: CuboColors.white,
                  ),

                  _rulesItem(
                    icon: Icons.blur_linear_rounded,
                    title: 'Objetivo',
                    text:
                        'Gana quien conecte 4 fichas en horizontal, vertical o diagonal.',
                    color: CuboColors.white,
                  ),

                  _rulesItem(
                    icon: Icons.undo_rounded,
                    title: 'Deshacer',
                    text:
                        'Puedes deshacer la última jugada antes de que termine la partida.',
                    color: CuboColors.white,
                  ),

                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Marcador',
                    text:
                        'Cada victoria suma un punto. Los empates también se cuentan.',
                    color: CuboColors.white,
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(CuboColors.white),
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
        ? CuboColors.white
        : ganaRojo
        ? redDisc
        : yellowDisc;

    final String titulo = empate ? 'empate' : 'victoria';

    final String subtitulo;

    if (empate) {
      subtitulo = 'La partida termina sin ganador';
    } else if (modoJuego == CuatroEnRayaMode.vsMachine) {
      subtitulo = ganaRojo ? 'Has ganado a la máquina' : 'Ha ganado la máquina';
    } else {
      subtitulo = ganaRojo
          ? 'Gana el jugador rojo'
          : 'Gana el jugador amarillo';
    }
    final IconData icon = empate
        ? Icons.handshake_rounded
        : Icons.emoji_events_rounded;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: tr('Resultado'),
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 22),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: CuboDecorations.dialog(),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CuboIllustration(
                      'cuatro_raya',
                      size: MediaQuery.sizeOf(context).height < 740 ? 72 : 100,
                      popIn: true,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      CuboIconCircle(icon: icon, size: 52, color: accentColor),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(titulo, style: CuboText.title(size: 40)),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const CuboPillBar(width: 44, color: CuboColors.chill),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: CuboDecorations.glass(),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                            border: Border.all(
                              color: CuboColors.whiteA(0.75),
                              width: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          tr(subtitulo).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CuboColors.white,
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
                            color: CuboColors.white.withValues(alpha: 0.72),
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
                          style: mainButtonStyle(CuboColors.white),
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
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }

  Widget circleButton({
    required Widget child,
    required VoidCallback onTap,
    required bool compact,
  }) {
    final size = compact ? 44.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CuboColors.whiteA(0.12),
          border: Border.all(color: CuboColors.whiteA(0.55), width: 1.6),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;

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
              compact: compact,
              onTap: mostrarNormas,
              child: Icon(
                Icons.question_mark_rounded,
                color: CuboColors.white,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 8 : 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CuboIllustration('cuatro_raya', size: compact ? 64 : 96),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '4 en raya',
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: CuboText.title(size: titleSize),
                    ),
                  ),
                  SizedBox(height: compact ? 9 : 12),
                  const CuboPillBar(width: 44, color: CuboColors.chill),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
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
        decoration: CuboDecorations.whiteCard(radius: CuboRadii.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: CuboColors.blueInk,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                tr(label).toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CuboColors.blueInk.withValues(alpha: 0.70),
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

  Widget _buildModeOption({
    required String label,
    required IconData icon,
    required CuatroEnRayaMode mode,
    required bool compact,
  }) {
    final selected = modoJuego == mode;

    return Expanded(
      child: Material(
        color: selected ? CuboColors.white : CuboColors.whiteA(0.08),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? CuboColors.white : CuboColors.whiteA(0.45),
            width: 1.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _cambiarModo(mode),
          child: Container(
            height: compact ? 40 : 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: compact ? 18 : 20,
                  color: selected ? CuboColors.blue : CuboColors.white,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? CuboColors.blue : CuboColors.white,
                      fontSize: compact ? 10.5 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.25,
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

  Widget buildGameModeSelector({required bool compact}) {
    return Row(
      children: [
        _buildModeOption(
          label: '2 JUGADORES',
          icon: Icons.people_alt_rounded,
          mode: CuatroEnRayaMode.twoPlayers,
          compact: compact,
        ),
        const SizedBox(width: 8),
        _buildModeOption(
          label: 'VS MÁQUINA',
          icon: Icons.smart_toy_rounded,
          mode: CuatroEnRayaMode.vsMachine,
          compact: compact,
        ),
      ],
    );
  }

  void _cambiarModo(CuatroEnRayaMode nuevoModo) {
    if (modoJuego == nuevoModo) return;

    setState(() {
      modoJuego = nuevoModo;
      maquinaPensando = false;

      puntosRojo = 0;
      puntosAmarillo = 0;
      empates = 0;

      tablero = List.generate(filas, (_) => List.filled(columnas, 0));

      jugadorInicial = 1;
      jugadorActual = 1;
      juegoTerminado = false;
      animando = false;
      animColumna = null;
      animJugador = null;
      animFilaVisual = 0;
      hoverColumna = null;
      fichasGanadoras = [];
      historialJugadas = [];
    });
  }

  Widget buildTurnCard() {
    final colorTurno = colorJugadorActual();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: juegoTerminado
                  ? CuboColors.white.withValues(alpha: 0.55)
                  : colorTurno,
              shape: BoxShape.circle,
              border: Border.all(
                color: CuboColors.white.withValues(alpha: 0.75),
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
                    color: CuboColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  maquinaPensando
                      ? 'La máquina está pensando...'
                      : animando
                      ? 'La ficha está cayendo...'
                      : esTurnoMaquina
                      ? 'Espera la jugada de la máquina'
                      : 'Pulsa una columna para jugar',
                  style: TextStyle(
                    color: CuboColors.white.withValues(alpha: 0.68),
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
        final bool mostrarPreview =
            !juegoTerminado &&
            !animando &&
            !maquinaPensando &&
            !esTurnoMaquina &&
            hoverColumna == columna &&
            obtenerFilaDisponible(columna) != null;

        return Expanded(
          child: MouseRegion(
            onEnter: (_) {
              if (!animando &&
                  !juegoTerminado &&
                  !maquinaPensando &&
                  !esTurnoMaquina) {
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
                          color: colorJugadorActual().withValues(alpha: 0.85),
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
    final bool mostrarFichaAnimada =
        animando &&
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [boardBlue, boardBlueDark],
        ),
        borderRadius: CuboRadii.lgAll,
        border: Border.all(color: CuboColors.whiteA(0.35), width: 1.4),
        boxShadow: CuboShadows.soft,
      ),
      child: AspectRatio(aspectRatio: columnas / filas, child: buildTablero()),
    );
  }

  Widget buildMarcador() {
    return Row(
      children: [
        scorePill(
          label: modoJuego == CuatroEnRayaMode.vsMachine ? 'Tú' : 'Rojo',
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
          label: modoJuego == CuatroEnRayaMode.vsMachine
              ? 'Máquina'
              : 'Amarillo',
          value: '$puntosAmarillo',
          color: const Color(0xFFFFD166),
          icon: modoJuego == CuatroEnRayaMode.vsMachine
              ? Icons.smart_toy_rounded
              : Icons.circle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CuboColors.blue,
          body: CuboGameBackground(
            accent: CuboColors.chill,
            halo: CuboHalo.topLeft,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 740;
                  final horizontalPadding = compact ? 13.0 : 18.0;
                  final verticalPadding = compact ? 11.0 : 18.0;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      verticalPadding,
                      horizontalPadding,
                      compact ? 11 : 16,
                    ),
                    child: Column(
                      children: [
                        buildTopBar(compact: compact),

                        SizedBox(height: compact ? 10 : 14),
                        buildGameModeSelector(compact: compact),

                        const SizedBox(height: 8),

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
                                onPressed:
                                    animando ||
                                        maquinaPensando ||
                                        juegoTerminado ||
                                        historialJugadas.length <
                                            (modoJuego ==
                                                    CuatroEnRayaMode.vsMachine
                                                ? 2
                                                : 1)
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
                                style: mainButtonStyle(CuboColors.white),
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
                  );
                },
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
      ..color = Colors.white.withValues(alpha: 0.55)
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
