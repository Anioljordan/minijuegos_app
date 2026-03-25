import 'dart:math';
import 'package:flutter/material.dart';
import '../data/impostor_data.dart';

class ImpostorScreen extends StatefulWidget {
  const ImpostorScreen({super.key});

  @override
  State<ImpostorScreen> createState() => _ImpostorScreenState();
}

class _ImpostorScreenState extends State<ImpostorScreen> {
  final TextEditingController nombreController = TextEditingController();
  final List<String> jugadores = [];
  final Random random = Random();

  String palabraSecreta = '';
  int impostorIndex = -1;
  int jugadorActualIndex = 0;
  bool partidaEmpezada = false;
  bool cartaDescubierta = false;

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cómo se juega'),
        content: const Text(
          'Añade los jugadores y empieza la partida.\n\n'
              'Todos verán una palabra secreta menos el impostor.\n\n'
              'Cada jugador debe mirar su pantalla en privado y pasar el móvil al siguiente.',
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

  void agregarJugador() {
    final nombre = nombreController.text.trim();

    if (nombre.isEmpty) return;
    if (jugadores.contains(nombre)) return;

    setState(() {
      jugadores.add(nombre);
      nombreController.clear();
    });
  }

  void eliminarJugador(int index) {
    setState(() {
      jugadores.removeAt(index);
    });
  }

  void empezarPartida() {
    if (jugadores.length < 3) return;

    setState(() {
      palabraSecreta = palabrasImpostor[random.nextInt(palabrasImpostor.length)];
      impostorIndex = random.nextInt(jugadores.length);
      jugadorActualIndex = 0;
      partidaEmpezada = true;
      cartaDescubierta = false;
    });
  }

  void descubrirCarta() {
    setState(() {
      cartaDescubierta = true;
    });
  }

  void siguienteJugador() {
    if (jugadorActualIndex < jugadores.length - 1) {
      setState(() {
        jugadorActualIndex++;
        cartaDescubierta = false;
      });
    } else {
      mostrarFinReparto();
    }
  }

  void mostrarFinReparto() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Todo listo'),
        content: const Text(
          'Todos los jugadores ya han visto su rol.\n\n'
              'Ahora empieza la ronda para descubrir al impostor.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              reiniciarJuego();
            },
            child: const Text('Volver a empezar'),
          ),
        ],
      ),
    );
  }

  void reiniciarJuego() {
    setState(() {
      palabraSecreta = '';
      impostorIndex = -1;
      jugadorActualIndex = 0;
      partidaEmpezada = false;
      cartaDescubierta = false;
    });
  }

  String getMensajeJugadorActual() {
    if (jugadorActualIndex == impostorIndex) {
      return 'Eres el impostor';
    } else {
      return 'La palabra es:\n$palabraSecreta';
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool puedeEmpezar = jugadores.length >= 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostor'),
        actions: [
          IconButton(
            onPressed: mostrarNormas,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: partidaEmpezada ? _buildPantallaRoles() : _buildPantallaJugadores(puedeEmpezar),
      ),
    );
  }

  Widget _buildPantallaJugadores(bool puedeEmpezar) {
    return Column(
      children: [
        const Text(
          'Añade jugadores',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: nombreController,
          decoration: const InputDecoration(
            labelText: 'Nombre del jugador',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => agregarJugador(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: agregarJugador,
            child: const Text('Añadir jugador'),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Jugadores: ${jugadores.length}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: jugadores.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(jugadores[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => eliminarJugador(index),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: puedeEmpezar ? empezarPartida : null,
            child: const Text('Empezar partida'),
          ),
        ),
      ],
    );
  }

  Widget _buildPantallaRoles() {
    final nombreJugador = jugadores[jugadorActualIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Turno de $nombreJugador',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        if (!cartaDescubierta) ...[
          const Text(
            'Pasa el móvil a este jugador y pulsa el botón',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: descubrirCarta,
            child: const Text('Ver mi rol'),
          ),
        ] else ...[
          Text(
            getMensajeJugadorActual(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: siguienteJugador,
            child: Text(
              jugadorActualIndex < jugadores.length - 1
                  ? 'Siguiente jugador'
                  : 'Terminar',
            ),
          ),
        ],
      ],
    );
  }
}