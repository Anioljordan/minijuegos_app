import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum DescribeStep {
  setup,
  roundIntro,
  turn,
  roundFinished,
  gameFinished,
}

enum DescribeRoundType {
  describe,
  mime,
  sounds,
}

enum WordsSource {
  app,
  custom,
}

class DescribeTeam {
  final String name;
  final List<String> players;
  int points;
  int describerIndex;

  DescribeTeam({
    required this.name,
    required this.players,
    this.points = 0,
    this.describerIndex = 0,
  });

  String get currentDescriber {
    if (players.isEmpty) return '';
    return players[describerIndex % players.length];
  }

  void nextDescriber() {
    if (players.isNotEmpty) {
      describerIndex = (describerIndex + 1) % players.length;
    }
  }
}

class DescribeLaPalabraScreen extends StatefulWidget {
  const DescribeLaPalabraScreen({super.key});

  @override
  State<DescribeLaPalabraScreen> createState() => _DescribeLaPalabraScreenState();
}

class _DescribeLaPalabraScreenState extends State<DescribeLaPalabraScreen> {
  final Random _random = Random();

  DescribeStep currentStep = DescribeStep.setup;
  DescribeRoundType currentRound = DescribeRoundType.describe;
  WordsSource wordsSource = WordsSource.app;

  final TextEditingController playerController = TextEditingController();
  final TextEditingController customWordsController = TextEditingController();
  final TextEditingController teamCountController = TextEditingController(text: '2');
  final TextEditingController secondsController = TextEditingController(text: '30');

  List<String> allPlayers = [];
  List<DescribeTeam> teams = [];

  List<String> appWords = [
    'Perro',
    'Avión',
    'Pizza',
    'Doctor',
    'Netflix',
    'Montaña',
    'Cerveza',
    'Discoteca',
    'Helado',
    'Guitarra',
    'León',
    'Bicicleta',
    'Hospital',
    'Bombero',
    'Playa',
    'Volcán',
    'Tortilla',
    'Tigre',
    'Zapato',
    'Ordenador',
    'Piano',
    'Canguro',
    'Sushi',
    'Restaurante',
    'Coche',
    'Patata',
    'Escalera',
    'Móvil',
    'Balón',
    'Cafetera',
    'Elefante',
    'Jirafa',
    'Cocodrilo',
    'Biblioteca',
    'Fantasma',
    'Supermercado',
    'Martillo',
    'Helicóptero',
    'Paella',
    'Croqueta',
    'Micrófono',
    'Peluquería',
    'Sirena',
    'Chocolate',
    'Castillo',
    'Princesa',
    'Robot',
    'Vaquero',
    'Pingüino',
    'Tiburón',
    'Semáforo',
    'Pescador',
    'Camarero',
    'Profesor',
    'Zoológico',
    'Pirata',
    'Payaso',
    'Cebra',
    'Maleta',
    'Delfín',
  ];

  List<String> baseWords = [];
  List<String> currentRoundWords = [];
  List<String> roundOneWords = [];
  List<String> guessedThisTurn = [];

  int currentTeamIndex = 0;
  int turnSeconds = 30;
  int remainingSeconds = 30;
  int turnsPlayedInRound = 0;
  Timer? timer;

  String currentWord = '';
  bool turnRunning = false;

  @override
  void dispose() {
    timer?.cancel();
    playerController.dispose();
    customWordsController.dispose();
    teamCountController.dispose();
    secondsController.dispose();
    super.dispose();
  }

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void resetAll() {
    turnsPlayedInRound = 0;
    timer?.cancel();
    setState(() {
      currentStep = DescribeStep.setup;
      currentRound = DescribeRoundType.describe;
      wordsSource = WordsSource.app;

      allPlayers = [];
      teams = [];

      baseWords = [];
      currentRoundWords = [];
      roundOneWords = [];
      guessedThisTurn = [];

      currentTeamIndex = 0;
      turnSeconds = 30;
      remainingSeconds = 30;
      currentWord = '';
      turnRunning = false;

      playerController.clear();
      customWordsController.clear();
      teamCountController.text = '2';
      secondsController.text = '30';
    });
  }

  String getRoundTitle(DescribeRoundType round) {
    switch (round) {
      case DescribeRoundType.describe:
        return 'Ronda 1 · Describir';
      case DescribeRoundType.mime:
        return 'Ronda 2 · Mímica';
      case DescribeRoundType.sounds:
        return 'Ronda 3 · Sonidos';
    }
  }

  String getRoundDescription(DescribeRoundType round) {
    switch (round) {
      case DescribeRoundType.describe:
        return 'Describe la palabra hablando, pero sin decirla.';
      case DescribeRoundType.mime:
        return 'Haz mímica. No puedes hablar.';
      case DescribeRoundType.sounds:
        return 'Solo sonidos. Nada de palabras ni mímica completa.';
    }
  }

  IconData getRoundIcon(DescribeRoundType round) {
    switch (round) {
      case DescribeRoundType.describe:
        return Icons.chat_bubble_rounded;
      case DescribeRoundType.mime:
        return Icons.accessibility_new_rounded;
      case DescribeRoundType.sounds:
        return Icons.graphic_eq_rounded;
    }
  }

  void addPlayer() {
    final name = playerController.text.trim();
    if (name.isEmpty) return;
    if (allPlayers.contains(name)) {
      showSnack('Ese jugador ya está añadido');
      return;
    }

    setState(() {
      allPlayers.add(name);
      playerController.clear();
    });
  }

  void removePlayer(int index) {
    final player = allPlayers[index];

    setState(() {
      allPlayers.removeAt(index);
      for (final team in teams) {
        team.players.remove(player);
      }
    });
  }

  void createEmptyTeams() {
    final teamCount = int.tryParse(teamCountController.text) ?? 0;

    if (allPlayers.length < 2) {
      showSnack('Añade al menos 2 jugadores');
      return;
    }

    if (teamCount < 2) {
      showSnack('Tiene que haber al menos 2 equipos');
      return;
    }

    if (teamCount > allPlayers.length) {
      showSnack('No puede haber más equipos que jugadores');
      return;
    }

    setState(() {
      teams = List.generate(
        teamCount,
            (index) => DescribeTeam(
          name: 'Equipo ${index + 1}',
          players: [],
        ),
      );
    });
  }

  void autoDistributePlayers() {
    if (teams.length < 2) {
      showSnack('Primero crea los equipos');
      return;
    }

    final shuffledPlayers = List<String>.from(allPlayers)..shuffle();

    for (final team in teams) {
      team.players.clear();
    }

    for (int i = 0; i < shuffledPlayers.length; i++) {
      teams[i % teams.length].players.add(shuffledPlayers[i]);
    }

    setState(() {});
  }

  void assignPlayerToTeam(String player, int teamIndex) {
    setState(() {
      for (final team in teams) {
        team.players.remove(player);
      }
      teams[teamIndex].players.add(player);
    });
  }

  int? getPlayerAssignedTeamIndex(String player) {
    for (int i = 0; i < teams.length; i++) {
      if (teams[i].players.contains(player)) {
        return i;
      }
    }
    return null;
  }

  bool validateTeams() {
    if (teams.length < 2) {
      showSnack('Crea al menos 2 equipos');
      return false;
    }

    for (final player in allPlayers) {
      final assigned = getPlayerAssignedTeamIndex(player);
      if (assigned == null) {
        showSnack('Todos los jugadores tienen que estar en un equipo');
        return false;
      }
    }

    for (final team in teams) {
      if (team.players.isEmpty) {
        showSnack('No puede haber equipos vacíos');
        return false;
      }
    }

    return true;
  }

  List<String> getPreparedWords() {
    if (wordsSource == WordsSource.app) {
      final words = List<String>.from(appWords)..shuffle();
      return words.take(min(40, words.length)).toList();
    }

    final words = customWordsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList()
      ..shuffle();

    return words;
  }

  void startGame() {
    final seconds = int.tryParse(secondsController.text) ?? 0;
    turnsPlayedInRound = 0;
    if (!validateTeams()) return;

    if (seconds < 10) {
      showSnack('Pon al menos 10 segundos por turno');
      return;
    }

    final words = getPreparedWords();

    if (words.length < 8) {
      showSnack('Necesitas al menos 8 palabras');
      return;
    }

    setState(() {
      turnSeconds = seconds;
      remainingSeconds = seconds;
      currentRound = DescribeRoundType.describe;
      baseWords = words;
      currentRoundWords = List<String>.from(words)..shuffle();
      roundOneWords = [];
      guessedThisTurn = [];
      currentTeamIndex = 0;

      for (final team in teams) {
        team.points = 0;
        team.describerIndex = 0;
      }

      currentStep = DescribeStep.roundIntro;
    });
  }

  void startTurn() {
    if (currentRoundWords.isEmpty) {
      finishRound();
      return;
    }

    guessedThisTurn = [];
    remainingSeconds = turnSeconds;
    turnRunning = true;
    currentWord = currentRoundWords.first;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 1) {
        timer.cancel();
        endTurn();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });

    setState(() {
      currentStep = DescribeStep.turn;
    });
  }

  void markCorrect() {
    if (!turnRunning || currentRoundWords.isEmpty) return;

    final word = currentRoundWords.removeAt(0);
    guessedThisTurn.add(word);
    teams[currentTeamIndex].points++;

    if (currentRound == DescribeRoundType.describe) {
      roundOneWords.add(word);
    }

    if (currentRoundWords.isEmpty) {
      timer?.cancel();
      endTurn();
      return;
    }

    setState(() {
      currentWord = currentRoundWords.first;
    });
  }

  void passWord() {
    if (!turnRunning || currentRoundWords.isEmpty) return;

    final word = currentRoundWords.removeAt(0);
    currentRoundWords.add(word);

    setState(() {
      currentWord = currentRoundWords.first;
    });
  }

  void endTurn() {
    turnRunning = false;
    teams[currentTeamIndex].nextDescriber();

    turnsPlayedInRound++;

    // Si ya han jugado todos los equipos, termina la ronda
    if (turnsPlayedInRound >= teams.length) {
      finishRound();
      return;
    }

    setState(() {
      currentTeamIndex = (currentTeamIndex + 1) % teams.length;
      currentStep = DescribeStep.roundIntro;
    });
  }

  void finishRound() {
    timer?.cancel();
    turnRunning = false;

    setState(() {
      currentStep = DescribeStep.roundFinished;
    });
  }

  void goToNextRound() {
    if (currentRound == DescribeRoundType.describe) {
      setState(() {
        currentRound = DescribeRoundType.mime;
        currentRoundWords = List<String>.from(roundOneWords)..shuffle();
        currentTeamIndex = 0;
        turnsPlayedInRound = 0;
        currentStep = DescribeStep.roundIntro;
      });
      return;
    }

    if (currentRound == DescribeRoundType.mime) {
      setState(() {
        currentRound = DescribeRoundType.sounds;
        currentRoundWords = List<String>.from(roundOneWords)..shuffle();
        currentTeamIndex = 0;
        turnsPlayedInRound = 0;
        currentStep = DescribeStep.roundIntro;
      });
      return;
    }

    setState(() {
      currentStep = DescribeStep.gameFinished;
    });
  }

  DescribeTeam get winningTeam {
    final sorted = List<DescribeTeam>.from(teams)
      ..sort((a, b) => b.points.compareTo(a.points));
    return sorted.first;
  }

  List<DescribeTeam> get sortedTeams {
    final sorted = List<DescribeTeam>.from(teams)
      ..sort((a, b) => b.points.compareTo(a.points));
    return sorted;
  }

  Widget buildTopBar({
    required String title,
    String? subtitle,
    bool showHome = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHome)
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded, color: Colors.white),
              tooltip: 'Volver al menú',
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF22D3EE), Color(0xFF14B8A6)],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.70),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
      filled: true,
      fillColor: const Color(0xFF0F172A),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF14B8A6)),
      ),
    );
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF14B8A6),
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
      side: BorderSide(color: Colors.white.withOpacity(0.18)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Describe la palabra',
          subtitle: 'Jugadores, equipos y palabras',
        ),
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Añadir jugadores',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: playerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration('Nombre del jugador'),
                      onSubmitted: (_) => addPlayer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: addPlayer,
                    style: mainButtonStyle(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      child: Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (allPlayers.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(allPlayers.length, (index) {
                    return Chip(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      label: Text(
                        allPlayers[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                      deleteIconColor: Colors.white70,
                      onDeleted: () => removePlayer(index),
                    );
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Equipos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Número de equipos',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: teamCountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration('Ejemplo: 2'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: createEmptyTeams,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Crear equipos',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: autoDistributePlayers,
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Reparto aleatorio',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (teams.isNotEmpty) ...[
                const SizedBox(height: 18),
                const Text(
                  'Asignar jugadores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...allPlayers.map((player) {
                  final assignedTeam = getPlayerAssignedTeamIndex(player);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DropdownButton<int>(
                          value: assignedTeam,
                          dropdownColor: const Color(0xFF0F172A),
                          hint: const Text(
                            'Equipo',
                            style: TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: List.generate(
                            teams.length,
                                (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                teams[index].name,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value != null) {
                              assignPlayerToTeam(player, value);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                ...teams.map(
                      (team) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          team.players.isEmpty ? 'Sin jugadores' : team.players.join(', '),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Palabras y tiempo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    RadioListTile<WordsSource>(
                      value: WordsSource.app,
                      groupValue: wordsSource,
                      activeColor: const Color(0xFF14B8A6),
                      title: const Text(
                        'Palabras de la app',
                        style: TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setState(() {
                          wordsSource = value!;
                        });
                      },
                    ),
                    RadioListTile<WordsSource>(
                      value: WordsSource.custom,
                      groupValue: wordsSource,
                      activeColor: const Color(0xFF14B8A6),
                      title: const Text(
                        'Escribir mi lista',
                        style: TextStyle(color: Colors.white),
                      ),
                      onChanged: (value) {
                        setState(() {
                          wordsSource = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (wordsSource == WordsSource.custom) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: customWordsController,
                  maxLines: 8,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'Una palabra por línea\nPerro\nAvión\nPizza',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Segundos por turno',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: inputDecoration('Ejemplo: 30'),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Empezar juego',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRoundIntro() {
    final team = teams[currentTeamIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: getRoundTitle(currentRound),
          subtitle: getRoundDescription(currentRound),
        ),
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.tealAccent.withOpacity(0.14),
                ),
                child: Icon(
                  getRoundIcon(currentRound),
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                team.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Describe: ${team.currentDescriber}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.80),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Palabras restantes: ${currentRoundWords.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: startTurn,
                  style: mainButtonStyle(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Empezar turno',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildScoreCard(),
      ],
    );
  }

  Widget buildTurn() {
    final team = teams[currentTeamIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: team.name,
          subtitle: 'Describe: ${team.currentDescriber}',
        ),
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.tealAccent.withOpacity(0.22),
                      Colors.cyanAccent.withOpacity(0.14),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '$remainingSeconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Text(
                  currentWord,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: passWord,
                      style: secondaryButtonStyle(),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Pasar',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: markCorrect,
                      style: mainButtonStyle(),
                      icon: const Icon(Icons.check_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Acierto',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        buildScoreCard(),
      ],
    );
  }

  Widget buildRoundFinished() {
    final isLastRound = currentRound == DescribeRoundType.sounds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: '${getRoundTitle(currentRound)} terminada',
          subtitle: 'Resumen de puntuaciones',
        ),
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            children: [
              const Icon(
                Icons.flag_rounded,
                color: Colors.white,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                currentRound == DescribeRoundType.describe
                    ? 'Las palabras acertadas pasan a la ronda 2'
                    : currentRound == DescribeRoundType.mime
                    ? 'Las mismas palabras pasan a la ronda 3'
                    : 'Habéis terminado el juego',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              buildScoreBoard(),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: goToNextRound,
                  style: mainButtonStyle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      isLastRound ? 'Ver ganador' : 'Siguiente ronda',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildGameFinished() {
    final winner = winningTeam;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Juego terminado',
          subtitle: 'Ya tenemos ganador',
        ),
        const SizedBox(height: 22),
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber.withOpacity(0.18),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: 46,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                winner.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${winner.points} puntos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              buildScoreBoard(),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Menú',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: resetAll,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'Jugar otra vez',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildScoreCard() {
    return buildGlassCard(
      padding: const EdgeInsets.all(14),
      child: buildScoreBoard(),
    );
  }

  Widget buildScoreBoard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Puntuación',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedTeams.map(
              (team) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${team.points} pts',
                  style: const TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (currentStep) {
      case DescribeStep.setup:
        body = buildSetup();
        break;
      case DescribeStep.roundIntro:
        body = buildRoundIntro();
        break;
      case DescribeStep.turn:
        body = buildTurn();
        break;
      case DescribeStep.roundFinished:
        body = buildRoundFinished();
        break;
      case DescribeStep.gameFinished:
        body = buildGameFinished();
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06121A),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0B1F2A),
                Color(0xFF07131C),
                Color(0xFF041017),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                left: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.tealAccent.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 120,
                right: -20,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent.withOpacity(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SingleChildScrollView(
                    child: body,
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