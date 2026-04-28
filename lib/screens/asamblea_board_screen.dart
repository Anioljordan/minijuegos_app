import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_setup_screen.dart';

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
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'La Asamblea',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Qué quieres hacer?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continuar jugando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cierra el dialog
              Navigator.pop(context); // vuelve al setup
            },
            child: const Text('Salir al menú'),
          ),
          TextButton(
            onPressed: () async {
              await _borrarPartidaGuardada();
              if (!mounted) return;
              Navigator.pop(context); // cierra el dialog
              Navigator.pop(context); // vuelve al setup
            },
            child: const Text('Reiniciar partida'),
          ),
        ],
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

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Ley aleatoria aprobada',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _colorLey(ley),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _textoLey(ley),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    await _comprobarVictoriaPorLeyes();
    if (partidaTerminada) return;

    if (ley == LeyType.derecha) {
      await _resolverPoderDerecha();
      if (partidaTerminada) return;
    }

    _pasarSiguienteTurno();
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
        return 'Líder Oculto';
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
          return PoderDerecha.elegirSiguientePresidente;
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
          return PoderDerecha.elegirSiguientePresidente;
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
        return 'Elegir siguiente presidente';
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
            'Elegir portavoz',
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
        'El Líder Oculto ha sido elegido Portavoz.',
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
                      'Presidente: descarta 1 carta',
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
                    tooltip: cartasVisibles ? 'Ocultar cartas' : 'Mostrar cartas',
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
                          ? 'Pulsa una carta para descartarla'
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
                          final copia = List<LeyType>.from(cartas);
                          copia.remove(ley);
                          descarte.add(ley);
                          Navigator.pop(context, copia);
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
                      'Portavoz: elige la ley a aprobar',
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
                    tooltip: cartasVisibles ? 'Ocultar cartas' : 'Mostrar cartas',
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
                    tooltip: cartasVisibles ? 'Ocultar cartas' : 'Mostrar cartas',
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
        'El Líder Oculto ha sido eliminado.',
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
          'Elegir siguiente presidente',
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
    _snack('${players[elegido].name} será el siguiente presidente.');
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
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: const Text(
          'Normas de La Asamblea',
          style: TextStyle(color: Colors.white),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '1. El presidente elige un portavoz.\n\n'
                '2. El presidente roba 3 leyes, descarta 1 y pasa 2 al portavoz.\n\n'
                '3. El portavoz elige cuál se aprueba.\n\n'
                '4. La Izquierda gana con 5 leyes de izquierda.\n\n'
                '5. La Derecha gana con 6 leyes de derecha.\n\n'
                '6. Si el Líder Oculto es elegido portavoz a partir de 3 leyes de derecha, gana la Derecha.\n\n'
                '7. Las leyes de derecha pueden desbloquear poderes especiales según el número de jugadores.\n\n'
                '8. También puedes usar el botón de ley aleatoria si quieres acelerar la partida o improvisar.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
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

  Future<void> _mostrarGanador(String titulo, String mensaje) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF15112B),
        title: Text(
          titulo,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          mensaje,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _borrarPartidaGuardada();
              if (!mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cerrar partida'),
          ),
        ],
      ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
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

  Widget _buildLeyTrack({
    required String title,
    required int total,
    required int active,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15112B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(total, (index) {
              final filled = index < active;
              return Expanded(
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: filled ? color : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: filled ? color : Colors.white24,
                    ),
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF15112B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJugadoresList() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15112B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jugadores',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...players.asMap().entries.map((entry) {
            final i = entry.key;
            final player = entry.value;
            final isPresident = i == presidenteIndex;
            final isPortavoz = i == portavozIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: player.isAlive ? Colors.white.withOpacity(0.04) : Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPresident
                      ? const Color(0xFFF59E0B)
                      : isPortavoz
                      ? const Color(0xFF7C3AED)
                      : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isPresident
                        ? const Color(0xFFF59E0B)
                        : isPortavoz
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF2563EB),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.isAlive ? player.name : '${player.name} (eliminado)',
                      style: TextStyle(
                        color: player.isAlive ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isPresident)
                    const Text(
                      'PRESIDENTE',
                      style: TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  if (isPortavoz)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'PORTAVOZ',
                        style: TextStyle(
                          color: Color(0xFF7C3AED),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    if (!mounted || (players.isEmpty && mazo.isEmpty && descarte.isEmpty)) {
      return const Scaffold(
        backgroundColor: Color(0xFF08051A),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final poderActual = _getPoderDerechaActual();

    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
      if (didPop) return;
      await _mostrarDialogoSalirTablero();
    },
    child: Scaffold(
      backgroundColor: const Color(0xFF08051A),
      appBar: AppBar(
        title: const Text('La Asamblea'),
        backgroundColor: const Color(0xFF08051A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _mostrarNormas,
            icon: const Icon(Icons.menu_book_outlined),
          ),
          IconButton(
            onPressed: _reiniciarPartida,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                _buildInfoCard(
                  'Presidente',
                  players[presidenteIndex].name,
                  Icons.account_balance_outlined,
                  const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 12),
                _buildInfoCard(
                  'Portavoz',
                  portavozIndex != null ? players[portavozIndex!].name : 'Sin elegir',
                  Icons.campaign_outlined,
                  const Color(0xFF7C3AED),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildLeyTrack(
              title: 'Izquierda',
              total: 5,
              active: leyesIzquierda,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 14),
            _buildLeyTrack(
              title: 'Derecha',
              total: 6,
              active: leyesDerecha,
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF15112B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const Text(
                    'Poder actual de la Derecha',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _textoPoder(poderActual),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${players.length} jugadores',
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _buildJugadoresList(),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: partidaTerminada ? null : _seleccionarPortavoz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Elegir portavoz',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: partidaTerminada ? null : _jugarTurno,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Jugar turno',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: partidaTerminada ? null : _sacarLeyAleatoria,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Sacar ley aleatoria',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mazo: ${mazo.length} cartas · Descarte: ${descarte.length}',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    ),
    );
  }
}