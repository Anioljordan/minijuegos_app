import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_roles_screen.dart';
import 'asamblea_board_screen.dart';

enum AsambleaRole {
  izquierda,
  derecha,
  liderOculto,
}

class AsambleaPlayer {
  final String name;
  AsambleaRole? role;
  bool isAlive;

  AsambleaPlayer({
    required this.name,
    this.role,
    this.isAlive = true,
  });
}

class AsambleaSetupScreen extends StatefulWidget {
  const AsambleaSetupScreen({super.key});

  @override
  State<AsambleaSetupScreen> createState() => _AsambleaSetupScreenState();
}

class _AsambleaSetupScreenState extends State<AsambleaSetupScreen> {
  static const String lastPlayersKey = 'asamblea_last_players';
  static const String savedGameKey = 'asamblea_partida_guardada';

  final TextEditingController _controller = TextEditingController();
  final List<AsambleaPlayer> _players = [];

  bool _startupDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initSetup();
  }

  Future<void> _initSetup() async {
    await _loadLastPlayers();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_startupDialogShown) {
        _startupDialogShown = true;
        await _showStartupDialogIfNeeded();
      }
    });
  }

  Future<void> _showStartupDialogIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSavedGame = prefs.getString(savedGameKey) != null;
    final hasLastPlayers = prefs.getString(lastPlayersKey) != null;

    if (!hasSavedGame && !hasLastPlayers) return;
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
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
            if (hasSavedGame)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _continueSavedGame();
                },
                child: const Text('Continuar partida'),
              ),
            if (hasLastPlayers)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _newGameWithLastPlayers();
                },
                child: const Text('Nueva partida con últimos jugadores'),
              ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _startFromScratch();
              },
              child: const Text('Empezar desde cero'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _continueSavedGame() async {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AsambleaBoardScreen(players: []),
      ),
    );
  }

  Future<void> _newGameWithLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(savedGameKey);
    await _loadLastPlayers();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Últimos jugadores cargados para nueva partida'),
      ),
    );
  }

  Future<void> _startFromScratch() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(savedGameKey);

    setState(() {
      _players.clear();
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Empieza una partida nueva desde cero'),
      ),
    );
  }

  Future<void> _loadLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(lastPlayersKey);

    if (raw == null) {
      setState(() {
        _players.clear();
      });
      return;
    }

    final List<dynamic> names = jsonDecode(raw);

    setState(() {
      _players.clear();
      _players.addAll(
        names.map((name) => AsambleaPlayer(name: name.toString())),
      );
    });
  }

  Future<void> _saveLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final names = _players.map((p) => p.name).toList();
    await prefs.setString(lastPlayersKey, jsonEncode(names));
  }

  Future<void> _clearLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(lastPlayersKey);
  }

  Future<void> _addPlayer() async {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    if (_players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ese nombre ya existe'),
        ),
      );
      return;
    }

    setState(() {
      _players.add(AsambleaPlayer(name: name));
      _controller.clear();
    });

    await _saveLastPlayers();
  }

  Future<void> _removePlayer(int index) async {
    setState(() {
      _players.removeAt(index);
    });

    if (_players.isEmpty) {
      await _clearLastPlayers();
    } else {
      await _saveLastPlayers();
    }
  }

  Future<void> _restoreLastPlayers() async {
    await _loadLastPlayers();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jugadores de la última partida cargados'),
      ),
    );
  }

  Future<void> _clearPlayersList() async {
    setState(() {
      _players.clear();
    });

    await _clearLastPlayers();
  }

  void _startGame() {
    if (_players.length < 5 || _players.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La Asamblea necesita entre 5 y 10 jugadores'),
        ),
      );
      return;
    }

    final playersWithRoles = _assignRoles(_players);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsambleaRolesScreen(players: playersWithRoles),
      ),
    );
  }

  List<AsambleaPlayer> _assignRoles(List<AsambleaPlayer> originalPlayers) {
    final random = Random();
    final players = originalPlayers
        .map((p) => AsambleaPlayer(name: p.name))
        .toList()
      ..shuffle(random);

    final total = players.length;

    int numDerecha;
    if (total <= 6) {
      numDerecha = 1;
    } else if (total <= 8) {
      numDerecha = 2;
    } else {
      numDerecha = 3;
    }

    players[0].role = AsambleaRole.liderOculto;

    for (int i = 1; i <= numDerecha; i++) {
      players[i].role = AsambleaRole.derecha;
    }

    for (int i = numDerecha + 1; i < players.length; i++) {
      players[i].role = AsambleaRole.izquierda;
    }

    return players;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      appBar: AppBar(
        title: const Text('La Asamblea'),
        backgroundColor: const Color(0xFF08051A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _restoreLastPlayers,
            icon: const Icon(Icons.history),
            tooltip: 'Cargar última partida',
          ),
          IconButton(
            onPressed: _clearPlayersList,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vaciar lista',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF15112B),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Añade los jugadores',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mínimo 5 · Máximo 10',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Nombre del jugador',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF1E1838),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Añadir',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _players.isEmpty
                  ? const Center(
                child: Text(
                  'Todavía no hay jugadores',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  final player = _players[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15112B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        player.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _removePlayer(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Empezar partida',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}