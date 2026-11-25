import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_roles_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_dialog.dart';
import '../widgets/cubo_game_widgets.dart';

enum LeyType { izquierda, derecha }

enum PoderDerecha {
  none,
  investigarJugador,
  verTresLeyes,
  eliminarJugador,
  elegirSiguientePresidente,
}

class AsambleaBoardScreen extends StatefulWidget {
  final List<AsambleaPlayer> players;

  const AsambleaBoardScreen({super.key, required this.players});

  @override
  State<AsambleaBoardScreen> createState() => _AsambleaBoardScreenState();
}

class _AsambleaBoardScreenState extends State<AsambleaBoardScreen> {
  static const String saveKey = 'asamblea_partida_guardada';

  late List<AsambleaPlayer> players;

  List<LeyType> mazo = [];
  List<LeyType> descarte = [];

  int leyesIzquierda = 0;
  int leyesDerecha = 0;

  int presidenteIndex = 0;
  int? portavozIndex;
  int? siguientePresidenteForzado;

  bool partidaTerminada = false;
  Future<void> _mostrarDialogoSalirTablero() async {
    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CuboDialogHeader(
                title: 'salir',
                icon: Icons.account_balance_rounded,
              ),
              const SizedBox(height: 18),
              Text(
                'La partida está guardada automáticamente. ¿Qué quieres hacer?',
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.76),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: mainButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'CONTINUAR JUGANDO',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: secondaryButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'SALIR AL MENÚ',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () async {
                  await _borrarPartidaGuardada();
                  if (!mounted) return;
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: secondaryButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'REINICIAR PARTIDA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
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

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    final cargado = await _cargarPartida();
    if (!cargado) {
      players = widget.players.map((p) {
        return AsambleaPlayer(name: p.name, role: p.role, isAlive: p.isAlive);
      }).toList();

      _crearMazo();
      presidenteIndex = _primerJugadorVivo();
      await _guardarPartida();
      if (mounted) setState(() {});
    }
  }

  int _primerJugadorVivo() {
    for (int i = 0; i < players.length; i++) {
      if (players[i].isAlive) return i;
    }
    return 0;
  }

  void _crearMazo() {
    mazo = [
      ...List.generate(6, (_) => LeyType.izquierda),
      ...List.generate(11, (_) => LeyType.derecha),
    ]..shuffle(Random());
  }

  void _rellenarMazoSiHaceFalta() {
    if (mazo.length < 3) {
      mazo.addAll(descarte);
      descarte.clear();
      mazo.shuffle(Random());
    }
  }

  List<LeyType> _robarTresCartas() {
    _rellenarMazoSiHaceFalta();
    return [mazo.removeAt(0), mazo.removeAt(0), mazo.removeAt(0)];
  }

  Future<void> _sacarLeyAleatoria() async {
    if (partidaTerminada) return;

    final confirmado = await showCuboDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CuboDialogHeader(
                title: 'sacar ley',
                icon: Icons.casino_rounded,
              ),
              const SizedBox(height: 18),
              Text(
                '¿Seguro que quieres sacar una ley aleatoria? Una vez confirmada se añadirá directamente al tablero.',
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.78),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
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
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CuboColors.alert,
                        foregroundColor: CuboColors.white,
                        elevation: 0,
                        shape: const StadiumBorder(),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'CONFIRMAR',
                          style: TextStyle(
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

    if (confirmado != true || !mounted) return;

    _rellenarMazoSiHaceFalta();
    if (mazo.isEmpty) return;

    final ley = mazo.removeAt(0);

    setState(() {
      if (ley == LeyType.izquierda) {
        leyesIzquierda++;
      } else {
        leyesDerecha++;
      }
    });

    await _guardarPartida();

    if (!mounted) return;

    await showCuboDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _colorLey(ley),
                  shape: BoxShape.circle,
                  border: Border.all(color: CuboColors.white, width: 2.4),
                ),
                child: Icon(
                  ley == LeyType.izquierda
                      ? Icons.shield_outlined
                      : Icons.gavel_rounded,
                  color: CuboColors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ley aprobada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: 32,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              const CuboPillBar(),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: _colorLey(ley),
                  borderRadius: CuboRadii.lgAll,
                  border: Border.all(color: CuboColors.white, width: 2),
                ),
                child: Text(
                  tr(_textoLey(ley)).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CuboColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'CONTINUAR',
                      style: TextStyle(
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

    await _comprobarVictoriaPorLeyes();
    if (partidaTerminada) return;

    if (ley == LeyType.derecha) {
      await _resolverPoderDerecha();
      if (partidaTerminada) return;
    }

    await _guardarPartida();
  }

  Color _colorLey(LeyType ley) {
    // Mismos colores que los marcadores del tablero.
    return ley == LeyType.izquierda ? CuboColors.chill : CuboColors.alert;
  }

  String _textoLey(LeyType ley) {
    return ley == LeyType.izquierda ? 'Ley de Izquierda' : 'Ley de Derecha';
  }

  String _textoRol(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Izquierda';
      case AsambleaRole.derecha:
        return 'Derecha';
      case AsambleaRole.liderOculto:
        return 'Dictador';
      default:
        return '';
    }
  }

  PoderDerecha _getPoderDerechaActual() {
    final total = players.length;

    if (total >= 5 && total <= 6) {
      switch (leyesDerecha) {
        case 1:
        case 2:
          return PoderDerecha.none;
        case 3:
          return PoderDerecha.verTresLeyes;
        case 4:
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    if (total >= 7 && total <= 8) {
      switch (leyesDerecha) {
        case 1:
        case 2:
          return PoderDerecha.none;
        case 3:
          return PoderDerecha.investigarJugador;
        case 4:
          return PoderDerecha.none;
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    if (total >= 9 && total <= 10) {
      switch (leyesDerecha) {
        case 1:
          return PoderDerecha.none;
        case 2:
          return PoderDerecha.investigarJugador;
        case 3:
          return PoderDerecha.none;
        case 4:
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    return PoderDerecha.none;
  }

  String _textoPoder(PoderDerecha poder) {
    switch (poder) {
      case PoderDerecha.none:
        return 'Sin poder';
      case PoderDerecha.investigarJugador:
        return 'Investigar jugador';
      case PoderDerecha.verTresLeyes:
        return 'Ver 3 leyes';
      case PoderDerecha.eliminarJugador:
        return 'Eliminar jugador';
      case PoderDerecha.elegirSiguientePresidente:
        return 'Sin poder';
    }
  }

  PoderDerecha _getPoderDerechaPorCasilla(int casillaDerecha) {
    final total = players.length;

    if (total >= 5 && total <= 6) {
      switch (casillaDerecha) {
        case 3:
          return PoderDerecha.verTresLeyes;
        case 4:
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    if (total >= 7 && total <= 8) {
      switch (casillaDerecha) {
        case 3:
          return PoderDerecha.investigarJugador;
        case 4:
          return PoderDerecha.none;
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    if (total >= 9 && total <= 10) {
      switch (casillaDerecha) {
        case 2:
          return PoderDerecha.investigarJugador;
        case 3:
          return PoderDerecha.none;
        case 4:
        case 5:
          return PoderDerecha.eliminarJugador;
        default:
          return PoderDerecha.none;
      }
    }

    return PoderDerecha.none;
  }

  IconData _iconoPoder(PoderDerecha poder) {
    switch (poder) {
      case PoderDerecha.none:
        return Icons.remove_rounded;
      case PoderDerecha.investigarJugador:
        return Icons.search_rounded;
      case PoderDerecha.verTresLeyes:
        return Icons.visibility_outlined;
      case PoderDerecha.eliminarJugador:
        return Icons.close_rounded;
      case PoderDerecha.elegirSiguientePresidente:
        return Icons.how_to_vote_outlined;
    }
  }

  Future<void> _jugarTurno() async {
    if (partidaTerminada) return;

    final cartas = _robarTresCartas();
    final cartasTrasPresidente = await _modalPresidente(cartas);

    if (cartasTrasPresidente == null || cartasTrasPresidente.length != 2) {
      return;
    }

    final leyFinal = await _modalPortavoz(cartasTrasPresidente);
    if (leyFinal == null) return;

    setState(() {
      if (leyFinal == LeyType.izquierda) {
        leyesIzquierda++;
      } else {
        leyesDerecha++;
      }
    });

    await _guardarPartida();
    await _comprobarVictoriaPorLeyes();
    if (partidaTerminada) return;

    if (leyFinal == LeyType.derecha) {
      await _resolverPoderDerecha();
      if (partidaTerminada) return;
    }

    _pasarSiguienteTurno();
    await _guardarPartida();
  }

  /// Carta de ley dentro de un popup; oculta, solo muestra el reverso.
  Widget _dialogLeyCard({
    required LeyType ley,
    required bool visible,
    required VoidCallback? onTap,
    bool selected = false,
  }) {
    return CuboDialogOption(
      label: visible ? _textoLey(ley) : 'Carta oculta',
      icon: visible
          ? (ley == LeyType.izquierda
                ? Icons.shield_rounded
                : Icons.gavel_rounded)
          : Icons.visibility_off_rounded,
      color: visible ? _colorLey(ley) : null,
      selected: selected,
      onTap: onTap,
    );
  }

  /// Opciones (índice, nombre) de los jugadores vivos.
  List<(int, String)> _opcionesJugadores({bool sinPresidente = true}) => [
    for (var i = 0; i < players.length; i++)
      if (players[i].isAlive && !(sinPresidente && i == presidenteIndex))
        (i, players[i].name),
  ];

  Future<List<LeyType>?> _modalPresidente(List<LeyType> cartas) async {
    bool cartasVisibles = true;

    // Guardamos índices y no tipos de ley,
    // porque pueden salir varias cartas iguales.
    final Set<int> cartasSeleccionadas = <int>{};

    return showCuboDialog<List<LeyType>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final listas = cartasSeleccionadas.length == 2;
          return CuboDialogFrame(
            icon: Icons.account_balance_rounded,
            title: 'presidente',
            trailing: CuboDialogEyeToggle(
              visible: cartasVisibles,
              onTap: () =>
                  setModalState(() => cartasVisibles = !cartasVisibles),
            ),
            children: [
              CuboDialogNote(
                cartasVisibles
                    ? listas
                          ? '2 de 2 seleccionadas · pulsa CONFIRMAR'
                          : 'Selecciona las 2 cartas que pasarán a la siguiente elección'
                    : 'Cartas ocultas para pasar el móvil',
              ),
              for (var index = 0; index < cartas.length; index++)
                _dialogLeyCard(
                  ley: cartas[index],
                  visible: cartasVisibles,
                  selected:
                      cartasVisibles && cartasSeleccionadas.contains(index),
                  onTap: cartasVisibles
                      ? () => setModalState(() {
                          if (!cartasSeleccionadas.remove(index) &&
                              cartasSeleccionadas.length < 2) {
                            cartasSeleccionadas.add(index);
                          }
                        })
                      : null,
                ),
              CuboDialogButton(
                label: 'CONFIRMAR CARTAS',
                onTap: cartasVisibles && listas
                    ? () {
                        // La carta no seleccionada se descarta y las otras
                        // dos pasan al portavoz.
                        for (var i = 0; i < cartas.length; i++) {
                          if (!cartasSeleccionadas.contains(i)) {
                            descarte.add(cartas[i]);
                          }
                        }
                        final elegidas = cartasSeleccionadas.toList()..sort();
                        Navigator.pop(dialogContext, [
                          for (final i in elegidas) cartas[i],
                        ]);
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  Future<LeyType?> _modalPortavoz(List<LeyType> cartas) async {
    bool cartasVisibles = true;

    return showCuboDialog<LeyType>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => CuboDialogFrame(
          icon: Icons.record_voice_over_rounded,
          title: 'portavoz',
          trailing: CuboDialogEyeToggle(
            visible: cartasVisibles,
            onTap: () => setModalState(() => cartasVisibles = !cartasVisibles),
          ),
          children: [
            CuboDialogNote(
              cartasVisibles
                  ? 'Pulsa una carta para aprobarla'
                  : 'Cartas ocultas para pasar el móvil',
            ),
            for (var index = 0; index < cartas.length; index++)
              _dialogLeyCard(
                ley: cartas[index],
                visible: cartasVisibles,
                onTap: cartasVisibles
                    ? () {
                        // La otra carta se descarta.
                        descarte.add(cartas[1 - index]);
                        Navigator.pop(dialogContext, cartas[index]);
                      }
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _comprobarVictoriaPorLeyes() async {
    if (leyesIzquierda >= 5) {
      partidaTerminada = true;
      await _guardarPartida();
      await _mostrarGanador(
        '¡Gana la Izquierda!',
        'Se han aprobado 5 leyes de izquierda.',
      );
      return;
    }

    if (leyesDerecha >= 6) {
      partidaTerminada = true;
      await _guardarPartida();
      await _mostrarGanador(
        '¡Gana la Derecha!',
        'Se han aprobado 6 leyes de derecha.',
      );
    }
  }

  Future<void> _resolverPoderDerecha() async {
    final poder = _getPoderDerechaActual();

    switch (poder) {
      case PoderDerecha.none:
        return;
      case PoderDerecha.investigarJugador:
        await _investigarJugador();
        return;
      case PoderDerecha.verTresLeyes:
        await _verTresCartasDelMazo();
        return;
      case PoderDerecha.eliminarJugador:
        await _eliminarJugador();
        return;
      case PoderDerecha.elegirSiguientePresidente:
        await _elegirSiguientePresidente();
        return;
    }
  }

  Future<void> _investigarJugador() async {
    final elegido = await showCuboPlayerPicker(
      context,
      title: 'investigar',
      icon: Icons.search_rounded,
      note: 'Investigar jugador',
      options: _opcionesJugadores(),
    );

    if (elegido == null || !mounted) return;

    await showCuboDialog(
      context: context,
      builder: (dialogContext) => CuboDialogFrame(
        icon: Icons.search_rounded,
        title: 'resultado',
        children: [
          CuboDialogNote(
            '${players[elegido].name} es ${_textoRol(players[elegido].role)}',
          ),
          CuboDialogButton(
            label: 'CERRAR',
            onTap: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  Future<void> _verTresCartasDelMazo() async {
    _rellenarMazoSiHaceFalta();
    final preview = mazo.take(3).toList();

    bool cartasVisibles = false;

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => CuboDialogFrame(
          icon: Icons.visibility_rounded,
          title: 'próximas leyes',
          trailing: CuboDialogEyeToggle(
            visible: cartasVisibles,
            onTap: () => setModalState(() => cartasVisibles = !cartasVisibles),
          ),
          children: [
            CuboDialogNote(
              cartasVisibles
                  ? 'Memoriza las leyes y vuelve a ocultarlas si vas a pasar el móvil'
                  : 'Cartas ocultas para pasar el móvil',
            ),
            for (final ley in preview)
              _dialogLeyCard(ley: ley, visible: cartasVisibles, onTap: null),
            CuboDialogButton(
              label: 'CERRAR',
              onTap: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eliminarJugador() async {
    final elegido = await showCuboPlayerPicker(
      context,
      title: 'eliminar',
      icon: Icons.close_rounded,
      note: 'Eliminar jugador',
      options: _opcionesJugadores(),
    );

    if (elegido == null) return;

    setState(() {
      players[elegido].isAlive = false;
    });

    await _guardarPartida();

    if (players[elegido].role == AsambleaRole.liderOculto) {
      partidaTerminada = true;
      await _guardarPartida();
      await _mostrarGanador(
        '¡Gana la Izquierda!',
        'El Dictador ha sido eliminado.',
      );
    }
  }

  Future<void> _elegirSiguientePresidente() async {
    final elegido = await showCuboPlayerPicker(
      context,
      title: 'presidente',
      icon: Icons.account_balance_rounded,
      note: 'Elegir jugador',
      options: _opcionesJugadores(sinPresidente: false),
    );

    if (elegido == null) return;

    siguientePresidenteForzado = elegido;
    await _guardarPartida();
    _snack('${players[elegido].name} ha sido seleccionado.');
  }

  void _pasarSiguienteTurno() {
    setState(() {
      portavozIndex = null;

      if (siguientePresidenteForzado != null) {
        presidenteIndex = siguientePresidenteForzado!;
        siguientePresidenteForzado = null;
      } else {
        presidenteIndex = _siguienteJugadorVivo(presidenteIndex);
      }
    });
  }

  int _siguienteJugadorVivo(int actual) {
    int next = actual;
    do {
      next = (next + 1) % players.length;
    } while (!players[next].isAlive);
    return next;
  }

  Future<void> _mostrarNormas() async {
    await showAsambleaRulesDialog(context);
  }

  List<AsambleaPlayer> _crearNuevaPartidaMismosJugadores() {
    final random = Random();

    final nuevosJugadores =
        players
            .map((player) => AsambleaPlayer(name: player.name, isAlive: true))
            .toList()
          ..shuffle(random);

    final total = nuevosJugadores.length;

    int numDerecha;

    if (total <= 6) {
      numDerecha = 1;
    } else if (total <= 8) {
      numDerecha = 2;
    } else {
      numDerecha = 3;
    }

    nuevosJugadores[0].role = AsambleaRole.liderOculto;

    for (int i = 1; i <= numDerecha; i++) {
      nuevosJugadores[i].role = AsambleaRole.derecha;
    }

    for (int i = numDerecha + 1; i < nuevosJugadores.length; i++) {
      nuevosJugadores[i].role = AsambleaRole.izquierda;
    }

    return nuevosJugadores;
  }

  Future<void> _mostrarGanador(String titulo, String mensaje) async {
    final bool ganaIzquierda = titulo.toLowerCase().contains('izquierda');

    final Color winnerColor = ganaIzquierda
        ? CuboColors.chill
        : CuboColors.alert;

    final String winnerName = ganaIzquierda ? 'IZQUIERDA' : 'DERECHA';

    final IconData winnerIcon = ganaIzquierda
        ? Icons.shield_outlined
        : Icons.gavel_rounded;

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: CuboDecorations.dialog(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CABECERA GANADORA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                    child: Column(
                      children: [
                        const CuboIllustration(
                          'asamblea',
                          size: 104,
                          popIn: true,
                        ),

                        const SizedBox(height: 12),

                        const CuboStatusChip(
                          'FIN DE LA PARTIDA',
                          icon: Icons.emoji_events_rounded,
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          '¡GANA!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white,
                            fontSize: 28,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          winnerName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CuboColors.white,
                            fontSize: 43,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.3,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          width: 56,
                          height: 6,
                          decoration: BoxDecoration(
                            color: winnerColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENIDO
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // MOTIVO DE LA VICTORIA
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: CuboDecorations.glass(
                            selected: true,
                            radius: CuboRadii.md,
                            accent: winnerColor,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CuboIconCircle(
                                icon: winnerIcon,
                                size: 36,
                                color: winnerColor,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MOTIVO DE LA VICTORIA',
                                      style: TextStyle(
                                        color: CuboColors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      mensaje,
                                      style: TextStyle(
                                        color: CuboColors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                        fontSize: 14,
                                        height: 1.3,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // MARCADOR FINAL
                        const Text(
                          'MARCADOR FINAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: CuboColors.chill.withValues(
                                    alpha: 0.22,
                                  ),
                                  borderRadius: CuboRadii.mdAll,
                                  border: Border.all(
                                    color: CuboColors.chill,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      color: CuboColors.white,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 7),

                                    const Text(
                                      'IZQUIERDA',
                                      style: TextStyle(
                                        color: CuboColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '$leyesIzquierda',
                                      style: const TextStyle(
                                        color: CuboColors.white,
                                        fontSize: 32,
                                        height: 0.9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: CuboColors.alert.withValues(
                                    alpha: 0.22,
                                  ),
                                  borderRadius: CuboRadii.mdAll,
                                  border: Border.all(
                                    color: CuboColors.alert,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.gavel_rounded,
                                      color: CuboColors.white,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 7),

                                    const Text(
                                      'DERECHA',
                                      style: TextStyle(
                                        color: CuboColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '$leyesDerecha',
                                      style: const TextStyle(
                                        color: CuboColors.white,
                                        fontSize: 32,
                                        height: 0.9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // MISMOS JUGADORES
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final nuevosJugadores =
                                  _crearNuevaPartidaMismosJugadores();

                              await _borrarPartidaGuardada();

                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => AsambleaRolesScreen(
                                    players: nuevosJugadores,
                                  ),
                                ),
                              );
                            },
                            style: CuboButtons.primary(padding: null),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.replay_rounded, size: 22),
                                  SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'REPETIR · MISMOS JUGADORES',
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.05,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 31),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // CAMBIAR JUGADORES
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await _borrarPartidaGuardada();

                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const AsambleaSetupScreen(),
                                ),
                                (route) => route.isFirst,
                              );
                            },
                            style: secondaryButtonStyle(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group_add_outlined, size: 21),
                                  SizedBox(width: 9),
                                  Text(
                                    'CAMBIAR JUGADORES',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // MENÚ PRINCIPAL
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await _borrarPartidaGuardada();

                              if (!mounted) return;

                              Navigator.of(dialogContext).pop();

                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: CuboColors.whiteA(0.78),
                              side: BorderSide(
                                color: CuboColors.whiteA(0.38),
                                width: 1.4,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 13),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home_outlined, size: 20),
                                  SizedBox(width: 9),
                                  Text(
                                    'MENÚ PRINCIPAL',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _reiniciarPartida() async {
    final confirmado = await showCuboDialog<bool>(
      context: context,
      builder: (dialogContext) => CuboDialogFrame(
        icon: Icons.restart_alt_rounded,
        title: 'reiniciar',
        children: [
          const CuboDialogNote('Se perderá el progreso actual.'),
          CuboDialogButton(
            label: 'REINICIAR',
            onTap: () => Navigator.pop(dialogContext, true),
          ),
          CuboDialogButton(
            label: 'CANCELAR',
            primary: false,
            onTap: () => Navigator.pop(dialogContext, false),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    await _borrarPartidaGuardada();
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CuboColors.blue,
        ),
      );
  }

  Map<String, dynamic> _toJson() {
    return {
      'leyesIzquierda': leyesIzquierda,
      'leyesDerecha': leyesDerecha,
      'presidenteIndex': presidenteIndex,
      'portavozIndex': portavozIndex,
      'siguientePresidenteForzado': siguientePresidenteForzado,
      'partidaTerminada': partidaTerminada,
      'mazo': mazo.map((e) => e.name).toList(),
      'descarte': descarte.map((e) => e.name).toList(),
      'players': players.map((p) {
        return {'name': p.name, 'role': p.role?.name, 'isAlive': p.isAlive};
      }).toList(),
    };
  }

  Future<void> _guardarPartida() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(saveKey, jsonEncode(_toJson()));
  }

  Future<bool> _cargarPartida() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(saveKey);
    if (raw == null) return false;

    final data = jsonDecode(raw);

    setState(() {
      leyesIzquierda = data['leyesIzquierda'] ?? 0;
      leyesDerecha = data['leyesDerecha'] ?? 0;
      presidenteIndex = data['presidenteIndex'] ?? 0;
      portavozIndex = data['portavozIndex'];
      siguientePresidenteForzado = data['siguientePresidenteForzado'];
      partidaTerminada = data['partidaTerminada'] ?? false;

      mazo = (data['mazo'] as List)
          .map((e) => LeyType.values.firstWhere((v) => v.name == e))
          .toList();

      descarte = (data['descarte'] as List)
          .map((e) => LeyType.values.firstWhere((v) => v.name == e))
          .toList();

      players = (data['players'] as List).map((p) {
        return AsambleaPlayer(
          name: p['name'],
          role: p['role'] == null
              ? null
              : AsambleaRole.values.firstWhere((r) => r.name == p['role']),
          isAlive: p['isAlive'] ?? true,
        );
      }).toList();
    });

    return true;
  }

  Future<void> _borrarPartidaGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(saveKey);
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: null);
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(padding: null);
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
          color: CuboColors.whiteA(0.08),
          border: Border.all(color: CuboColors.whiteA(0.85), width: 2.2),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 30.0 : 36.0;

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

            Row(
              children: [
                circleButton(
                  compact: compact,
                  onTap: _reiniciarPartida,
                  child: Icon(
                    Icons.restart_alt_rounded,
                    color: CuboColors.white,
                    size: compact ? 23 : 27,
                  ),
                ),

                SizedBox(width: compact ? 9 : 12),

                circleButton(
                  compact: compact,
                  onTap: _mostrarNormas,
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: CuboColors.white,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 20),

        Padding(
          padding: EdgeInsets.only(right: compact ? 4 : 8),
          child: CuboSectionTitle(
            barColor: CuboColors.chill,
            'tablero asamblea',
            alignEnd: true,
            size: titleSize,
            gap: compact ? 8 : 10,
          ),
        ),
      ],
    );
  }

  Widget buildPanel({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: CuboDecorations.glass(),
      child: child,
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      tr(text).toLowerCase(),
      style: const TextStyle(
        color: CuboColors.white,
        fontSize: 28,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  /// Marcador de leyes de un bando: cabecera compacta, casillas y, si el
  /// bando tiene poderes, una leyenda que los explica (en la casilla solo
  /// va el icono, así nunca se corta el texto).
  Widget _buildLeyTrack({
    required String title,
    required int total,
    required int active,
    required Color color,
    required bool compact,
    bool mostrarAcciones = false,
  }) {
    final cellHeight = compact ? 54.0 : 64.0;
    final poderes = <PoderDerecha>[
      if (mostrarAcciones)
        for (var c = 1; c <= total; c++)
          if (_getPoderDerechaPorCasilla(c) != PoderDerecha.none)
            _getPoderDerechaPorCasilla(c),
    ].toSet().toList();

    return buildPanel(
      padding: EdgeInsets.fromLTRB(
        14,
        compact ? 12 : 14,
        14,
        compact ? 12 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 34 : 38,
                height: compact ? 34 : 38,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  title == 'Izquierda'
                      ? Icons.shield_rounded
                      : Icons.gavel_rounded,
                  color: CuboColors.blueInk,
                  size: compact ? 19 : 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(title).toUpperCase(),
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                '$active/$total',
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 20 : 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Row(
            children: List.generate(total, (index) {
              final filled = index < active;
              final casilla = index + 1;
              final poder = mostrarAcciones
                  ? _getPoderDerechaPorCasilla(casilla)
                  : PoderDerecha.none;
              final tienePoder = poder != PoderDerecha.none;
              final fg = filled ? CuboColors.blueInk : CuboColors.whiteA(0.6);

              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: cellHeight,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: filled ? color : CuboColors.whiteA(0.08),
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    border: Border.all(
                      color: filled ? color : CuboColors.whiteA(0.22),
                      width: 1.4,
                    ),
                  ),
                  child: Center(
                    child: filled
                        ? Icon(Icons.check_rounded, color: fg, size: 26)
                        : tienePoder
                        ? Icon(_iconoPoder(poder), color: fg, size: 22)
                        : Text(
                            '$casilla',
                            style: TextStyle(
                              color: fg,
                              fontSize: compact ? 18 : 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
          if (poderes.isNotEmpty) ...[
            SizedBox(height: compact ? 10 : 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final poder in poderes)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconoPoder(poder),
                        color: CuboColors.whiteA(0.75),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _textoPoder(poder),
                        style: TextStyle(
                          color: CuboColors.whiteA(0.75),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Jugadores como fichas; los eliminados, tachados y apagados.
  Widget _buildJugadoresList() {
    return buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Jugadores').toUpperCase(),
            style: const TextStyle(
              color: CuboColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < players.length; i++)
                _buildPlayerChip(i + 1, players[i].name, players[i].isAlive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip(int number, String name, bool alive) {
    return Opacity(
      opacity: alive ? 1 : 0.45,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
        decoration: BoxDecoration(
          color: CuboColors.whiteA(0.12),
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: alive ? CuboColors.white : CuboColors.alert,
                shape: BoxShape.circle,
              ),
              child: alive
                  ? Text(
                      '$number',
                      style: const TextStyle(
                        color: CuboColors.blueInk,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : const Icon(
                      Icons.close_rounded,
                      color: CuboColors.white,
                      size: 18,
                    ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  decoration: alive ? null : TextDecoration.lineThrough,
                  decorationColor: CuboColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final enabled = onTap != null;

    return Expanded(
      child: SizedBox(
        height: compact ? 54 : 62,
        child: Material(
          color: enabled
              ? backgroundColor
              : backgroundColor.withValues(alpha: 0.30),
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 12,
                vertical: compact ? 7 : 9,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: CuboColors.white.withValues(
                    alpha: enabled ? 0.30 : 0.12,
                  ),
                  width: 2,
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: backgroundColor.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor.withValues(
                      alpha: enabled ? 1 : 0.40,
                    ),
                    size: compact ? 22 : 25,
                  ),
                  SizedBox(width: compact ? 7 : 9),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor.withValues(
                          alpha: enabled ? 1 : 0.40,
                        ),
                        fontSize: compact ? 13 : 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
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

  @override
  Widget build(BuildContext context) {
    if (!mounted || (players.isEmpty && mazo.isEmpty && descarte.isEmpty)) {
      return const Scaffold(
        backgroundColor: CuboColors.blue,
        body: CuboGameBackground(
          accent: CuboColors.chill,
          halo: CuboHalo.topLeft,
          child: Center(
            child: CircularProgressIndicator(color: CuboColors.white),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _mostrarDialogoSalirTablero();
      },
      child: Scaffold(
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
                      SizedBox(height: compact ? 9 : 13),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildLeyTrack(
                                title: 'Izquierda',
                                total: 5,
                                active: leyesIzquierda,
                                color: CuboColors.chill,
                                compact: compact,
                              ),
                              SizedBox(height: compact ? 9 : 12),
                              _buildLeyTrack(
                                title: 'Derecha',
                                total: 6,
                                active: leyesDerecha,
                                color: CuboColors.alert,
                                compact: compact,
                                mostrarAcciones: true,
                              ),

                              SizedBox(height: compact ? 9 : 12),
                              _buildJugadoresList(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 9),
                      Row(
                        children: [
                          _buildBoardActionButton(
                            icon: Icons.casino_rounded,
                            label: 'LEY ALEATORIA',
                            backgroundColor: CuboColors.whiteA(0.14),
                            foregroundColor: CuboColors.white,
                            onTap: partidaTerminada ? null : _sacarLeyAleatoria,
                            compact: compact,
                          ),
                          const SizedBox(width: 10),
                          _buildBoardActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'JUGAR TURNO',
                            backgroundColor: CuboColors.fiesta,
                            foregroundColor: CuboColors.blueInk,
                            onTap: partidaTerminada ? null : _jugarTurno,
                            compact: compact,
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
      ),
    );
  }
}
