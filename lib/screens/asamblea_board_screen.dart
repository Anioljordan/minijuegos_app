import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_roles_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';

enum LeyType {
  izquierda,
  derecha,
}

enum PoderDerecha {
  none,
  investigarJugador,
  verTresLeyes,
  eliminarJugador,
  elegirSiguientePresidente,
}

class AsambleaBoardScreen extends StatefulWidget {
  final List<AsambleaPlayer> players;

  const AsambleaBoardScreen({
    super.key,
    required this.players,
  });

  @override
  State<AsambleaBoardScreen> createState() => _AsambleaBoardScreenState();
}

class _AsambleaBoardScreenState extends State<AsambleaBoardScreen> {
  static const String saveKey = 'asamblea_partida_guardada';

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color leftBlue = Color(0xFF60A5FA);
  static const Color rightRed = Color(0xFFE63946);
  static const Color leaderGold = Color(0xFFFFD166);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF22C55E);

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
    await showDialog(
      context: context,
      barrierDismissible: false,
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
                      Icons.account_balance_rounded,
                      color: appWhite,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'salir',
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
              Container(height: 3, color: appWhite.withOpacity(0.58)),
              const SizedBox(height: 18),
              Text(
                'La partida está guardada automáticamente. ¿Qué quieres hacer?',
                style: TextStyle(
                  color: appWhite.withOpacity(0.76),
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
        return AsambleaPlayer(
          name: p.name,
          role: p.role,
          isAlive: p.isAlive,
        );
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
    return [
      mazo.removeAt(0),
      mazo.removeAt(0),
      mazo.removeAt(0),
    ];
  }

  Future<void> _sacarLeyAleatoria() async {
    if (partidaTerminada) return;

    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.78),
              width: 2.2,
            ),
          ),
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
                      color: rightRed.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(color: rightRed, width: 2.2),
                    ),
                    child: const Icon(
                      Icons.casino_rounded,
                      color: appWhite,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'sacar ley',
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 34,
                        height: 0.95,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(height: 3, color: appWhite.withOpacity(0.58)),
              const SizedBox(height: 18),
              Text(
                '¿Seguro que quieres sacar una ley aleatoria? Una vez confirmada se añadirá directamente al tablero.',
                style: TextStyle(
                  color: appWhite.withOpacity(0.78),
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
                        backgroundColor: rightRed,
                        foregroundColor: appWhite,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
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

    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.78),
              width: 2.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _colorLey(ley),
                  shape: BoxShape.circle,
                  border: Border.all(color: appWhite, width: 2.4),
                ),
                child: Icon(
                  ley == LeyType.izquierda
                      ? Icons.shield_outlined
                      : Icons.gavel_rounded,
                  color: appWhite,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ley aprobada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize: 32,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 14),
              Container(height: 3, color: appWhite.withOpacity(0.58)),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: _colorLey(ley),
                  border: Border.all(color: appWhite, width: 2),
                ),
                child: Text(
                  tr(_textoLey(ley)).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
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
    return ley == LeyType.izquierda
        ? const Color(0xFF2563EB)
        : const Color(0xFFDC2626);
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

  Future<void> _seleccionarPortavoz() async {
    final opciones = <int>[];
    for (int i = 0; i < players.length; i++) {
      if (i == presidenteIndex) continue;
      if (!players[i].isAlive) continue;
      opciones.add(i);
    }

    final seleccionado = await showDialog<int>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF15112B),
          title: const Text(
            'Elegir jugador',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: opciones.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (_, index) {
                final i = opciones[index];
                return ListTile(
                  title: Text(
                    players[i].name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () => Navigator.pop(context, i),
                );
              },
            ),
          ),
        );
      },
    );

    if (seleccionado == null) return;

    setState(() {
      portavozIndex = seleccionado;
    });

    await _guardarPartida();
    await _comprobarVictoriaLiderOcultoAlSerPortavoz();
  }

  Future<void> _comprobarVictoriaLiderOcultoAlSerPortavoz() async {
    if (portavozIndex == null) return;
    if (leyesDerecha < 3) return;

    final portavoz = players[portavozIndex!];
    if (portavoz.role == AsambleaRole.liderOculto) {
      partidaTerminada = true;
      await _guardarPartida();
      await _mostrarGanador(
        '¡Gana la Derecha!',
        'El Dictador ha llegado al poder.',
      );
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

  Future<List<LeyType>?> _modalPresidente(List<LeyType> cartas) async {
    bool cartasVisibles = true;

    // Guardamos índices y no tipos de ley,
    // porque pueden salir varias cartas iguales.
    final Set<int> cartasSeleccionadas = <int>{};

    return showDialog<List<LeyType>>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF15112B),

              titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 8),

              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Primera elección: selecciona 2 cartas',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        cartasVisibles = !cartasVisibles;
                      });
                    },
                    icon: Icon(
                      cartasVisibles
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                    tooltip: tr(cartasVisibles
                        ? 'Ocultar cartas'
                        : 'Mostrar cartas'),
                  ),
                ],
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),
                    child: Text(
                      cartasVisibles
                          ? cartasSeleccionadas.length == 2
                          ? '2 de 2 seleccionadas · pulsa CONFIRMAR'
                          : 'Selecciona las 2 cartas que pasarán a la siguiente elección'
                          : 'Cartas ocultas para pasar el móvil',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  ...List.generate(cartas.length, (index) {
                    final ley = cartas[index];
                    final seleccionada =
                    cartasSeleccionadas.contains(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cartasVisibles
                              ? _colorLey(ley)
                              : const Color(0xFF2A2540),
                          disabledBackgroundColor:
                          const Color(0xFF2A2540),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          side: BorderSide(
                            color: seleccionada
                                ? Colors.white
                                : Colors.white.withOpacity(0.18),
                            width: seleccionada ? 4 : 1.4,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),

                        onPressed: cartasVisibles
                            ? () {
                          setModalState(() {
                            if (seleccionada) {
                              cartasSeleccionadas.remove(index);
                            } else if (
                            cartasSeleccionadas.length < 2) {
                              cartasSeleccionadas.add(index);
                            }
                          });
                        }
                            : null,

                        child: Row(
                          children: [
                            Icon(
                              cartasVisibles
                                  ? ley == LeyType.izquierda
                                  ? Icons.gavel_outlined
                                  : Icons.policy_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                cartasVisibles
                                    ? _textoLey(ley)
                                    : 'Carta oculta',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),

                            if (cartasVisibles && seleccionada)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      cartasVisibles &&
                          cartasSeleccionadas.length == 2
                          ? () {
                        // La única carta no seleccionada
                        // se descarta.
                        final indiceDescartado =
                        List.generate(
                          cartas.length,
                              (index) => index,
                        ).firstWhere(
                              (index) =>
                          !cartasSeleccionadas
                              .contains(index),
                        );

                        descarte.add(
                          cartas[indiceDescartado],
                        );

                        // Las dos seleccionadas pasan al portavoz.
                        final indicesSeleccionados =
                        cartasSeleccionadas.toList()
                          ..sort();

                        final cartasParaPortavoz =
                        indicesSeleccionados
                            .map(
                              (index) => cartas[index],
                        )
                            .toList();

                        Navigator.pop(
                          context,
                          cartasParaPortavoz,
                        );
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        disabledBackgroundColor:
                        appWhite.withOpacity(0.18),
                        disabledForegroundColor:
                        appWhite.withOpacity(0.40),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'CONFIRMAR CARTAS',
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
            );
          },
        );
      },
    );
  }

  Future<LeyType?> _modalPortavoz(List<LeyType> cartas) async {
    bool cartasVisibles = true;

    return showDialog<LeyType>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF15112B),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Segunda elección: elige la ley a aprobar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        cartasVisibles = !cartasVisibles;
                      });
                    },
                    icon: Icon(
                      cartasVisibles
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                    tooltip: tr(cartasVisibles ? 'Ocultar cartas' : 'Mostrar cartas'),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      cartasVisibles
                          ? 'Pulsa una carta para aprobarla'
                          : 'Cartas ocultas para pasar el móvil',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...cartas.map((ley) {
                    final visible = cartasVisibles;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: visible
                              ? _colorLey(ley)
                              : const Color(0xFF2A2540),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: const Color(0xFF2A2540),
                        ),
                        onPressed: visible
                            ? () {
                          final restante = cartas.firstWhere(
                                (c) => c != ley,
                            orElse: () => ley,
                          );

                          if (restante != ley ||
                              cartas.where((c) => c == ley).length > 1) {
                            descarte.add(restante);
                          }

                          Navigator.pop(context, ley);
                        }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              visible
                                  ? (ley == LeyType.izquierda
                                  ? Icons.gavel_outlined
                                  : Icons.policy_outlined)
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              visible ? _textoLey(ley) : 'Carta oculta',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
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
    final opciones = <int>[];
    for (int i = 0; i < players.length; i++) {
      if (i == presidenteIndex) continue;
      if (!players[i].isAlive) continue;
      opciones.add(i);
    }

    final elegido = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Investigar jugador',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: opciones.length,
            itemBuilder: (_, index) {
              final i = opciones[index];
              return ListTile(
                title: Text(
                  players[i].name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, i),
              );
            },
          ),
        ),
      ),
    );

    if (elegido == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Resultado',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${players[elegido].name} es ${_textoRol(players[elegido].role)}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _verTresCartasDelMazo() async {
    _rellenarMazoSiHaceFalta();
    final preview = mazo.take(3).toList();

    bool cartasVisibles = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF15112B),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Próximas 3 leyes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setModalState(() {
                        cartasVisibles = !cartasVisibles;
                      });
                    },
                    icon: Icon(
                      cartasVisibles
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white70,
                    ),
                    tooltip: tr(cartasVisibles ? 'Ocultar cartas' : 'Mostrar cartas'),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      cartasVisibles
                          ? 'Memoriza las leyes y vuelve a ocultarlas si vas a pasar el móvil'
                          : 'Cartas ocultas para pasar el móvil',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...preview.map((ley) {
                    final visible = cartasVisibles;

                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: visible
                            ? _colorLey(ley)
                            : const Color(0xFF2A2540),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: visible ? Colors.white24 : Colors.white10,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            visible
                                ? (ley == LeyType.izquierda
                                ? Icons.gavel_outlined
                                : Icons.policy_outlined)
                                : Icons.visibility_off_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            visible ? _textoLey(ley) : 'Carta oculta',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _eliminarJugador() async {
    final opciones = <int>[];
    for (int i = 0; i < players.length; i++) {
      if (i == presidenteIndex) continue;
      if (!players[i].isAlive) continue;
      opciones.add(i);
    }

    final elegido = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Eliminar jugador',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: opciones.length,
            itemBuilder: (_, index) {
              final i = opciones[index];
              return ListTile(
                title: Text(
                  players[i].name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, i),
              );
            },
          ),
        ),
      ),
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
    final opciones = <int>[];
    for (int i = 0; i < players.length; i++) {
      if (!players[i].isAlive) continue;
      opciones.add(i);
    }

    final elegido = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Elegir jugador',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: opciones.length,
            itemBuilder: (_, index) {
              final i = opciones[index];
              return ListTile(
                title: Text(
                  players[i].name,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context, i),
              );
            },
          ),
        ),
      ),
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

    final nuevosJugadores = players
        .map(
          (player) => AsambleaPlayer(
        name: player.name,
        isAlive: true,
      ),
    )
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

  Future<void> _mostrarGanador(
      String titulo,
      String mensaje,
      ) async {
    final bool ganaIzquierda =
    titulo.toLowerCase().contains('izquierda');

    final Color winnerColor =
    ganaIzquierda ? leftBlue : rightRed;

    final String winnerName =
    ganaIzquierda ? 'IZQUIERDA' : 'DERECHA';

    final IconData winnerIcon = ganaIzquierda
        ? Icons.shield_outlined
        : Icons.gavel_rounded;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.70),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: appBlue,
              border: Border.all(
                color: appWhite,
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CABECERA GANADORA

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      22,
                    ),
                    decoration: BoxDecoration(
                      color: winnerColor,
                      border: const Border(
                        bottom: BorderSide(
                          color: appWhite,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: appWhite,
                            border: Border.all(
                              color: appWhite,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: winnerColor,
                            size: 50,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'FIN DE LA PARTIDA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          '¡GANA!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite,
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
                            color: appWhite,
                            fontSize: 43,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENIDO

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      18,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        // MOTIVO DE LA VICTORIA

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: appWhite.withOpacity(0.08),
                            border: Border(
                              left: BorderSide(
                                color: winnerColor,
                                width: 6,
                              ),
                              bottom: BorderSide(
                                color: appWhite.withOpacity(0.30),
                                width: 2,
                              ),
                              top: BorderSide(
                                color: appWhite.withOpacity(0.20),
                                width: 1,
                              ),
                              right: BorderSide(
                                color: appWhite.withOpacity(0.20),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Icon(
                                winnerIcon,
                                color: appWhite,
                                size: 27,
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MOTIVO DE LA VICTORIA',
                                      style: TextStyle(
                                        color: appWhite,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      mensaje,
                                      style: TextStyle(
                                        color: appWhite.withOpacity(
                                          0.82,
                                        ),
                                        fontSize: 14,
                                        height: 1.3,
                                        fontWeight:
                                        FontWeight.w700,
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
                            color: appWhite,
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
                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  leftBlue.withOpacity(0.22),
                                  border: Border.all(
                                    color: leftBlue,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      color: appWhite,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 7),

                                    const Text(
                                      'IZQUIERDA',
                                      style: TextStyle(
                                        color: appWhite,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '$leyesIzquierda',
                                      style: const TextStyle(
                                        color: appWhite,
                                        fontSize: 32,
                                        height: 0.9,
                                        fontWeight:
                                        FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Container(
                                padding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                  rightRed.withOpacity(0.22),
                                  border: Border.all(
                                    color: rightRed,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.gavel_rounded,
                                      color: appWhite,
                                      size: 25,
                                    ),

                                    const SizedBox(height: 7),

                                    const Text(
                                      'DERECHA',
                                      style: TextStyle(
                                        color: appWhite,
                                        fontSize: 10,
                                        fontWeight:
                                        FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      '$leyesDerecha',
                                      style: const TextStyle(
                                        color: appWhite,
                                        fontSize: 32,
                                        height: 0.9,
                                        fontWeight:
                                        FontWeight.w900,
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
                                  builder: (_) =>
                                      AsambleaRolesScreen(
                                        players: nuevosJugadores,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appWhite,
                              foregroundColor: appBlue,
                              elevation: 0,
                              shape:
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 13,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.replay_rounded,
                                    size: 22,
                                  ),
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

                              Navigator.of(context)
                                  .pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AsambleaSetupScreen(),
                                ),
                                    (route) => route.isFirst,
                              );
                            },
                            style: secondaryButtonStyle(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_add_outlined,
                                    size: 21,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'CAMBIAR JUGADORES',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight:
                                      FontWeight.w900,
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

                              Navigator.of(context).popUntil(
                                    (route) => route.isFirst,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                              appWhite.withOpacity(0.78),
                              side: BorderSide(
                                color:
                                appWhite.withOpacity(0.38),
                                width: 1.4,
                              ),
                              shape:
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 13,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home_outlined,
                                    size: 20,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'MENÚ PRINCIPAL',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                      FontWeight.w900,
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
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Reiniciar partida',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Se perderá el progreso actual.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reiniciar'),
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
          backgroundColor: appBlue,
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
        return {
          'name': p.name,
          'role': p.role?.name,
          'isAlive': p.isAlive,
        };
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
          border: Border.all(
            color: appWhite.withOpacity(0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;

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
                    color: appWhite,
                    size: compact ? 23 : 27,
                  ),
                ),

                SizedBox(width: compact ? 9 : 12),

                circleButton(
                  compact: compact,
                  onTap: _mostrarNormas,
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: appWhite,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: compact ? 14 : 24),

        Padding(
          padding: EdgeInsets.only(
            right: compact ? 18 : 28,
          ),
          child: SizedBox(
            width: double.infinity,
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  bottom: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topRight,
                      child: Text(
                        'tablero asamblea',
                        maxLines: 1,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: appWhite,
                          fontSize: titleSize,
                          height: 1.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: lineTop,
                  left: compact ? -13 : -18,
                  right: 0,
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



  Widget buildPanel({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      tr(text).toLowerCase(),
      style: const TextStyle(
        color: appWhite,
        fontSize: 28,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  Widget _buildLeyTrack({
    required String title,
    required int total,
    required int active,
    required Color color,
    required bool compact,
    bool mostrarAcciones = false,
  }) {
    final cellHeight = mostrarAcciones
        ? (compact ? 86.0 : 104.0)
        : (compact ? 72.0 : 88.0);

    return buildPanel(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        compact ? 13 : 17,
        compact ? 12 : 16,
        compact ? 14 : 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 42 : 50,
                height: compact ? 42 : 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  title == 'Izquierda'
                      ? Icons.shield_outlined
                      : Icons.gavel_rounded,
                  color: color,
                  size: compact ? 23 : 28,
                ),
              ),
              SizedBox(width: compact ? 10 : 13),
              Expanded(
                child: Text(
                  tr(title).toLowerCase(),
                  style: TextStyle(
                    color: appWhite,
                    fontSize: compact ? 29 : 34,
                    height: 0.92,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 11 : 14,
                  vertical: compact ? 7 : 9,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.22),
                  border: Border.all(
                    color: color,
                    width: 1.8,
                  ),
                ),
                child: Text(
                  '$active / $total',
                  style: TextStyle(
                    color: appWhite,
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 13 : 17),
          Row(
            children: List.generate(total, (index) {
              final filled = index < active;
              final casilla = index + 1;
              final poder = mostrarAcciones
                  ? _getPoderDerechaPorCasilla(casilla)
                  : PoderDerecha.none;
              final tienePoder = poder != PoderDerecha.none;

              return Expanded(
                child: Container(
                  height: cellHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: compact ? 2 : 3,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 3 : 5,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: filled ? color : appWhite.withOpacity(0.07),
                    border: Border.all(
                      color: filled ? appWhite : appWhite.withOpacity(0.28),
                      width: filled ? 2.2 : 1.4,
                    ),
                    boxShadow: filled
                        ? [
                      BoxShadow(
                        color: color.withOpacity(0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                        : null,
                  ),
                  child: mostrarAcciones && tienePoder
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _iconoPoder(poder),
                        color: appWhite,
                        size: compact ? 22 : 27,
                      ),
                      SizedBox(height: compact ? 5 : 7),
                      Text(
                        _textoPoder(poder),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: appWhite.withOpacity(
                            filled ? 1 : 0.80,
                          ),
                          fontSize: compact ? 8.2 : 9.5,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$casilla',
                        style: TextStyle(
                          color: filled
                              ? appWhite
                              : appWhite.withOpacity(0.42),
                          fontSize: compact ? 22 : 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (filled) ...[
                        SizedBox(height: compact ? 3 : 5),
                        Icon(
                          Icons.check_rounded,
                          color: appWhite,
                          size: compact ? 16 : 19,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: buildPanel(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: appWhite, size: 28),
            const SizedBox(height: 8),
            Text(
              tr(title).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite.withOpacity(0.62),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: appWhite,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJugadoresList() {
    return buildPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('Jugadores'),
          const SizedBox(height: 12),
          ...players.asMap().entries.map((entry) {
            final i = entry.key;
            final player = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 9),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: player.isAlive
                    ? appWhite.withOpacity(0.07)
                    : appWhite.withOpacity(0.035),
                border: Border(
                  left: BorderSide(
                    color: player.isAlive
                        ? appWhite.withOpacity(0.55)
                        : rightRed.withOpacity(0.65),
                    width: 5,
                  ),
                  bottom: BorderSide(
                    color: appWhite.withOpacity(0.24),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appWhite.withOpacity(0.85),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.isAlive
                          ? player.name
                          : '${player.name} (eliminado)',
                      style: TextStyle(
                        color: player.isAlive
                            ? appWhite
                            : appWhite.withOpacity(0.45),
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
              : backgroundColor.withOpacity(0.30),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 9 : 12,
                vertical: compact ? 7 : 9,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: appWhite.withOpacity(enabled ? 0.30 : 0.12),
                  width: 2,
                ),
                boxShadow: enabled
                    ? [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.22),
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
                    color: foregroundColor.withOpacity(enabled ? 1 : 0.40),
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
                        color: foregroundColor.withOpacity(
                          enabled ? 1 : 0.40,
                        ),
                        fontSize: compact ? 10.5 : 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
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
        backgroundColor: appBlue,
        body: Center(
          child: CircularProgressIndicator(color: appWhite),
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
        backgroundColor: appBlue,
        body: SafeArea(
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
                              color: leftBlue,
                              compact: compact,
                            ),
                            SizedBox(height: compact ? 9 : 12),
                            _buildLeyTrack(
                              title: 'Derecha',
                              total: 6,
                              active: leyesDerecha,
                              color: rightRed,
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
                          backgroundColor: rightRed,
                          foregroundColor: appWhite,
                          onTap: partidaTerminada ? null : _sacarLeyAleatoria,
                          compact: compact,
                        ),
                        const SizedBox(width: 10),
                        _buildBoardActionButton(
                          icon: Icons.play_arrow_rounded,
                          label: 'JUGAR TURNO',
                          backgroundColor: leaderGold,
                          foregroundColor: appBlue,
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
    );
  }
}
