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
  State<DescribeLaPalabraScreen> createState() =>
      _DescribeLaPalabraScreenState();
}

class _DescribeLaPalabraScreenState extends State<DescribeLaPalabraScreen> {
  final Random _random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentYellow = Color(0xFFFFD166);

  DescribeStep currentStep = DescribeStep.setup;
  DescribeRoundType currentRound = DescribeRoundType.describe;
  WordsSource wordsSource = WordsSource.app;

  final TextEditingController playerController = TextEditingController();
  final TextEditingController customWordsController = TextEditingController();
  final TextEditingController teamCountController =
  TextEditingController(text: '2');
  final TextEditingController secondsController =
  TextEditingController(text: '30');

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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showRulesDialog();
    });
  }

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

  Color getRoundAccent(DescribeRoundType round) {
    switch (round) {
      case DescribeRoundType.describe:
        return accentCyan;
      case DescribeRoundType.mime:
        return accentYellow;
      case DescribeRoundType.sounds:
        return accentPurple;
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
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

  Widget buildTopBar({
    required String title,
    String? subtitle,
  }) {
    String visualTitle = title.toLowerCase();

    if (visualTitle == 'describe la palabra') {
      visualTitle = 'describe\nla palabra';
    }

    if (visualTitle.length > 18 && !visualTitle.contains('\n')) {
      visualTitle = visualTitle.replaceFirst(' ', '\n');
    }

    final bool multiline = visualTitle.contains('\n');
    final double titleHeight = multiline ? 86 : 58;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            circleButton(
              onTap: () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            circleButton(
              onTap: showRulesDialog,
              child: const Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    visualTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 39,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: titleHeight - 10,
                  left: 0,
                  right: -18,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (subtitle != null) ...[
          const SizedBox(height: 10),
          buildInfoBar(
            text: subtitle,
            color: getRoundAccent(currentRound),
          ),
        ],
      ],
    );
  }

  Widget buildInfoBar({
    required String text,
    Color color = accentCyan,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: color,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  Widget buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
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

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.45),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: appWhite.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite,
          width: 2,
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(
        color: appWhite,
        fontSize: 29,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
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

  void showRulesDialog() {
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
                    'DESCRIBE LA PALABRA',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Cread equipos',
                    text:
                    'Añadid jugadores, cread equipos y asignad a cada persona a un equipo.',
                  ),

                  rulesItem(
                    icon: Icons.list_alt_rounded,
                    title: 'Elegid palabras',
                    text:
                    'Podéis usar palabras de la app o escribir vuestra propia lista.',
                  ),

                  rulesItem(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Ronda 1',
                    text:
                    'Describe palabras hablando, pero sin decir la palabra exacta.',
                  ),

                  rulesItem(
                    icon: Icons.accessibility_new_rounded,
                    title: 'Ronda 2',
                    text:
                    'Se usan las palabras acertadas de la ronda 1, pero solo con mímica.',
                  ),

                  rulesItem(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Ronda 3',
                    text:
                    'Se usan las mismas palabras, pero solo puedes hacer sonidos.',
                  ),

                  rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Puntuación',
                    text:
                    'Cada palabra acertada suma 1 punto. Gana el equipo con más puntos.',
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(),
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

  Widget buildSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTopBar(
          title: 'Describe la palabra',
          subtitle: 'Jugadores, equipos y palabras',
        ),

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Añadir jugadores'),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: playerController,
                      style: const TextStyle(
                        color: appWhite,
                        fontWeight: FontWeight.w700,
                      ),
                      cursorColor: appWhite,
                      decoration: inputDecoration('Nombre del jugador'),
                      onSubmitted: (_) => addPlayer(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: addPlayer,
                    style: mainButtonStyle(),
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      child: Icon(Icons.add_rounded),
                    ),
                  ),
                ],
              ),

              if (allPlayers.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(allPlayers.length, (index) {
                    return Chip(
                      backgroundColor: appWhite.withOpacity(0.10),
                      side: BorderSide(
                        color: appWhite.withOpacity(0.28),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      label: Text(
                        allPlayers[index],
                        style: const TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      deleteIconColor: appWhite.withOpacity(0.8),
                      onDeleted: () => removePlayer(index),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Equipos'),

              const SizedBox(height: 14),

              Text(
                'NÚMERO DE EQUIPOS',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: teamCountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: appWhite,
                decoration: inputDecoration('Ejemplo: 2'),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: createEmptyTeams,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'CREAR',
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
                    child: OutlinedButton(
                      onPressed: autoDistributePlayers,
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'ALEATORIO',
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

              if (teams.isNotEmpty) ...[
                const SizedBox(height: 18),

                Text(
                  'ASIGNAR JUGADORES',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),

                const SizedBox(height: 10),

                ...allPlayers.map((player) {
                  final assignedTeam = getPlayerAssignedTeamIndex(player);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: appWhite.withOpacity(0.07),
                      border: Border.all(
                        color: appWhite.withOpacity(0.22),
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player,
                            style: const TextStyle(
                              color: appWhite,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        DropdownButton<int>(
                          value: assignedTeam,
                          dropdownColor: appBlue,
                          hint: Text(
                            'Equipo',
                            style: TextStyle(
                              color: appWhite.withOpacity(0.7),
                            ),
                          ),
                          style: const TextStyle(
                            color: appWhite,
                            fontWeight: FontWeight.w700,
                          ),
                          underline: const SizedBox(),
                          iconEnabledColor: appWhite,
                          items: List.generate(
                            teams.length,
                                (index) => DropdownMenuItem(
                              value: index,
                              child: Text(
                                teams[index].name,
                                style: const TextStyle(color: appWhite),
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

                const SizedBox(height: 8),

                ...teams.map(
                      (team) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: appWhite.withOpacity(0.07),
                      border: Border(
                        left: BorderSide(
                          color: accentCyan,
                          width: 6,
                        ),
                        bottom: BorderSide(
                          color: appWhite.withOpacity(0.28),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name.toUpperCase(),
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          team.players.isEmpty
                              ? 'Sin jugadores'
                              : team.players.join(', '),
                          style: TextStyle(
                            color: appWhite.withOpacity(0.72),
                            height: 1.35,
                            fontWeight: FontWeight.w600,
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

        const SizedBox(height: 14),

        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionTitle('Palabras y tiempo'),

              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.07),
                  border: Border.all(
                    color: appWhite.withOpacity(0.22),
                  ),
                ),
                child: Column(
                  children: [
                    RadioListTile<WordsSource>(
                      value: WordsSource.app,
                      groupValue: wordsSource,
                      activeColor: appWhite,
                      title: const Text(
                        'Palabras de la app',
                        style: TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.w700,
                        ),
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
                      activeColor: appWhite,
                      title: const Text(
                        'Escribir mi lista',
                        style: TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.w700,
                        ),
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
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: inputDecoration(
                    'Una palabra por línea\nPerro\nAvión\nPizza',
                  ),
                ),
              ],

              const SizedBox(height: 14),

              Text(
                'SEGUNDOS POR TURNO',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: secondsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: appWhite,
                decoration: inputDecoration('Ejemplo: 30'),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: startGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'EMPEZAR JUEGO',
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

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: Icon(
                  getRoundIcon(currentRound),
                  color: appWhite,
                  size: 38,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                team.name.toLowerCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'DESCRIBE: ${team.currentDescriber}'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.78),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Palabras restantes: ${currentRoundWords.length}',
                style: TextStyle(
                  color: appWhite.withOpacity(0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: startTurn,
                  style: mainButtonStyle(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'EMPEZAR TURNO',
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
        ),

        const SizedBox(height: 14),

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

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$remainingSeconds',
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.30),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  currentWord.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 39,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: passWord,
                      style: secondaryButtonStyle(),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'PASAR',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
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
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'ACIERTO',
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

        const SizedBox(height: 14),

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

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: appWhite,
                  size: 36,
                ),
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
                  color: appWhite.withOpacity(0.82),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              buildScoreBoard(),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: goToNextRound,
                  style: mainButtonStyle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      isLastRound ? 'VER GANADOR' : 'SIGUIENTE RONDA',
                      style: const TextStyle(
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

        const SizedBox(height: 18),

        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: appWhite,
                  size: 39,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'ganador',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                winner.name.toLowerCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 34,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${winner.points} puntos',
                style: TextStyle(
                  color: appWhite.withOpacity(0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              buildScoreBoard(),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: secondaryButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'MENÚ',
                          style: TextStyle(
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
                      onPressed: resetAll,
                      style: mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text(
                          'OTRA VEZ',
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
          'puntuación',
          style: TextStyle(
            color: appWhite,
            fontSize: 25,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 12),

        ...sortedTeams.map(
              (team) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: appWhite.withOpacity(0.07),
              border: Border(
                left: BorderSide(
                  color: accentGreen,
                  width: 5,
                ),
                bottom: BorderSide(
                  color: appWhite.withOpacity(0.25),
                  width: 2,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      color: appWhite,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${team.points} pts',
                  style: const TextStyle(
                    color: appWhite,
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
      backgroundColor: appBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: body,
          ),
        ),
      ),
    );
  }
}