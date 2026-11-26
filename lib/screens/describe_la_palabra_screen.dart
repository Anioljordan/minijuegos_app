import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/cubo_setup_widgets.dart';

enum DescribeStep { setup, roundIntro, turn, roundFinished, gameFinished }

enum DescribeRoundType { describe, mime, sounds }

enum WordsSource { app, custom }

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

  static const int minPlayers = 2;
  static const int maxPlayers = 12;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  Widget _singleLineResponsiveText(
    String text, {
    required TextStyle style,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: style,
      ),
    );
  }

  DescribeStep currentStep = DescribeStep.setup;

  /// Paso visible de la configuración (solo interfaz).
  int _setupStep = 0;
  DescribeRoundType currentRound = DescribeRoundType.describe;
  WordsSource wordsSource = WordsSource.app;

  final TextEditingController playerController = TextEditingController();
  final TextEditingController customWordsController = TextEditingController();
  final TextEditingController teamCountController = TextEditingController(
    text: '2',
  );
  final TextEditingController secondsController = TextEditingController(
    text: '30',
  );

  List<String> allPlayers = [];
  List<DescribeTeam> teams = [];

  List<String> appWords = [
    'Perro',
    'Avión',
    'Pizza',
    'Doctor',
    'Netflix',
    'Montaña',
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
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  void resetAll() {
    turnsPlayedInRound = 0;
    timer?.cancel();
    setState(() {
      currentStep = DescribeStep.setup;
      _setupStep = 0;
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
        return CuboColors.chill;
      case DescribeRoundType.mime:
        return CuboColors.fiesta;
      case DescribeRoundType.sounds:
        return CuboColors.white;
    }
  }

  String _nextAutomaticPlayerName() {
    int number = 1;

    while (allPlayers.any(
      (player) => player.toLowerCase() == 'jugador $number',
    )) {
      number++;
    }

    return 'Jugador $number';
  }

  void addPlayer() {
    if (allPlayers.length >= maxPlayers) {
      showSnack('El máximo es de $maxPlayers jugadores');
      return;
    }

    final typedName = playerController.text.trim();

    final name = typedName.isEmpty ? _nextAutomaticPlayerName() : typedName;

    final duplicated = allPlayers.any(
      (player) => player.toLowerCase() == name.toLowerCase(),
    );

    if (duplicated) {
      showSnack('Ese jugador ya está añadido');
      return;
    }

    setState(() {
      allPlayers.add(name);
      playerController.clear();

      // Los equipos anteriores ya no coinciden con los jugadores.
      teams.clear();
    });
  }

  void removePlayer(int index) {
    if (index < 0 || index >= allPlayers.length) return;

    setState(() {
      allPlayers.removeAt(index);

      // Al cambiar la lista, se deben crear los equipos otra vez.
      teams.clear();
    });
  }

  void createEmptyTeams() {
    final teamCount = int.tryParse(teamCountController.text.trim()) ?? 0;

    if (allPlayers.length < minPlayers) {
      showSnack('Añade al menos $minPlayers jugadores');
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
        (index) => DescribeTeam(name: 'Equipo ${index + 1}', players: []),
      );
    });
  }

  void autoDistributePlayers() {
    if (teams.length < 2) {
      showSnack('Primero crea los equipos');
      return;
    }

    final shuffledPlayers = List<String>.from(allPlayers)..shuffle(_random);

    setState(() {
      for (final team in teams) {
        team.players.clear();
      }

      for (int index = 0; index < shuffledPlayers.length; index++) {
        teams[index % teams.length].players.add(shuffledPlayers[index]);
      }
    });
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

    final words =
        customWordsController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
          ..shuffle();

    return words;
  }

  void startGame() {
    final seconds = int.tryParse(secondsController.text.trim()) ?? 0;

    turnsPlayedInRound = 0;

    if (allPlayers.length < minPlayers) {
      showSnack('Añade al menos $minPlayers jugadores');
      return;
    }

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
      currentRoundWords = List<String>.from(words)..shuffle(_random);

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

    timer?.cancel();

    setState(() {
      guessedThisTurn = [];
      remainingSeconds = turnSeconds;
      turnRunning = true;
      currentWord = currentRoundWords.first;
      currentStep = DescribeStep.turn;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingSeconds <= 1) {
        timer.cancel();
        endTurn();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
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

  ButtonStyle mainButtonStyle({
    Color backgroundColor = CuboColors.white,
    Color foregroundColor = CuboColors.blue,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.25),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.45),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const StadiumBorder(),
    );
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
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
      ),
    );
  }

  Widget buildTopBar({
    required bool compact,
    String? subtitle,
    bool showReset = false,
    bool showIllustration = false,
  }) {

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
                if (showReset) ...[
                  circleButton(
                    compact: compact,
                    onTap: resetAll,
                    child: Icon(
                      Icons.restart_alt_rounded,
                      color: CuboColors.white,
                      size: compact ? 23 : 27,
                    ),
                  ),
                  SizedBox(width: compact ? 9 : 12),
                ],
                circleButton(
                  compact: compact,
                  onTap: showRulesDialog,
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

        SizedBox(height: compact ? 6 : 12),
        CuboGameTitle(
          'describe la palabra',
          side: CuboTitleSide.chill,
          illustration: showIllustration ? 'describe' : null,
          compact: compact,
        ),

        if (subtitle != null) ...[
          SizedBox(height: compact ? 6 : 10),
          buildInfoBar(
            text: subtitle,
            color: currentStep == DescribeStep.setup
                ? CuboColors.chill
                : getRoundAccent(currentRound),
            compact: compact,
          ),
        ],
      ],
    );
  }

  Widget buildInfoBar({
    required String text,
    required Color color,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: compact ? 8 : 10),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: CuboColors.whiteA(0.82),
                fontSize: compact ? 11.5 : 12.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPanel({
    required Widget child,
    EdgeInsets? padding,
    Color? accent,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.10),
        borderRadius: CuboRadii.lgAll,
        border: Border.all(
          color: accent?.withValues(alpha: 0.55) ?? CuboColors.whiteA(0.22),
          width: 1.4,
        ),
      ),
      child: child,
    );
  }

  Widget sectionTitle(String text, {bool compact = false}) {
    return Text(
      tr(text).toLowerCase(),
      style: TextStyle(
        color: CuboColors.white,
        fontSize: compact ? 24 : 29,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  int get _roundNumber {
    switch (currentRound) {
      case DescribeRoundType.describe:
        return 1;
      case DescribeRoundType.mime:
        return 2;
      case DescribeRoundType.sounds:
        return 3;
    }
  }

  String get _roundShortName {
    switch (currentRound) {
      case DescribeRoundType.describe:
        return 'DESCRIBIR';
      case DescribeRoundType.mime:
        return 'MÍMICA';
      case DescribeRoundType.sounds:
        return 'SONIDOS';
    }
  }

  Widget buildRoundProgress({required bool compact}) {
    return Row(
      children: List.generate(3, (index) {
        final number = index + 1;
        final active = number == _roundNumber;
        final completed = number < _roundNumber;
        final Color color = index == 0
            ? CuboColors.chill
            : index == 1
            ? CuboColors.fiesta
            : CuboColors.white;

        return Expanded(
          child: Container(
            height: compact ? 7 : 9,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
            decoration: BoxDecoration(
              color: active || completed ? color : CuboColors.whiteA(0.16),
              borderRadius: BorderRadius.circular(99),
              border: active
                  ? Border.all(color: CuboColors.whiteA(0.85), width: 1.4)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _smallLabel(
    String text, {
    Alignment alignment = Alignment.centerLeft,
  }) {
    return _singleLineResponsiveText(
      tr(text).toUpperCase(),
      alignment: alignment,
      style: TextStyle(
        color: CuboColors.white.withValues(alpha: 0.67),
        fontSize: 10.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.7,
      ),
    );
  }

  Widget _compactActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final veryNarrow = _isVeryNarrowScreen;

    return Expanded(
      child: SizedBox(
        height: compact ? 52 : 60,
        child: Material(
          color: onTap == null
              ? backgroundColor.withValues(alpha: 0.28)
              : backgroundColor,
          shape: StadiumBorder(
            side: BorderSide(
              color: CuboColors.whiteA(onTap == null ? 0.12 : 0.40),
              width: 1.4,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: veryNarrow
                    ? 8
                    : compact
                    ? 10
                    : 14,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: foregroundColor.withValues(
                      alpha: onTap == null ? 0.4 : 1,
                    ),
                    size: veryNarrow
                        ? 19
                        : compact
                        ? 22
                        : 25,
                  ),

                  SizedBox(
                    width: veryNarrow
                        ? 4
                        : compact
                        ? 6
                        : 8,
                  ),

                  Expanded(
                    child: _singleLineResponsiveText(
                      label,
                      alignment: Alignment.center,
                      style: TextStyle(
                        color: foregroundColor.withValues(
                          alpha: onTap == null ? 0.4 : 1,
                        ),
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
      ),
    );
  }

  Widget _scoreStrip({required bool compact}) {
    final colors = [
      CuboColors.chill,
      CuboColors.fiesta,
      CuboColors.white,
      CuboColors.blueLight,
    ];

    return SizedBox(
      height: compact ? 58 : 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sortedTeams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final team = sortedTeams[index];
          final color = colors[index % colors.length];
          return Container(
            width: compact ? 105 : 118,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: CuboDecorations.glass(radius: CuboRadii.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        tr(team.name).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CuboColors.whiteA(0.72),
                          fontSize: compact ? 9 : 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${team.points} pts',
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: compact ? 17 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildScoreBoard({bool compact = false}) {
    final colors = [
      CuboColors.chill,
      CuboColors.fiesta,
      CuboColors.white,
      CuboColors.blueLight,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Puntuación', compact: compact),
        SizedBox(height: compact ? 9 : 12),
        ...sortedTeams.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          final color = colors[index % colors.length];

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: compact ? 9 : 11,
            ),
            decoration: CuboDecorations.glass(radius: CuboRadii.md),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.22),
                    border: Border.all(color: color, width: 1.4),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: CuboColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    team.name,
                    style: const TextStyle(
                      color: CuboColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${team.points} pts',
                  style: const TextStyle(
                    color: CuboColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void showRulesDialog() {
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.50),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.80,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),
                  const SizedBox(height: 18),
                  const Text(
                    'DESCRIBE LA PALABRA',
                    style: TextStyle(
                      color: CuboColors.white,
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
                      style: CuboButtons.primary(padding: null),
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

  static const List<Color> _teamColors = [
    CuboColors.chill,
    CuboColors.fiesta,
    CuboColors.white,
    CuboColors.alert,
  ];

  static const int _minSeconds = 10;
  static const int _maxSeconds = 180;
  static const int _secondsStep = 5;

  int get _teamCount => int.tryParse(teamCountController.text.trim()) ?? 2;

  int get _seconds => int.tryParse(secondsController.text.trim()) ?? 30;

  /// Crea los equipos y reparte a los jugadores al azar.
  void _prepareTeams() {
    createEmptyTeams();
    if (teams.length >= 2) autoDistributePlayers();
  }

  void _changeTeamCount(int delta) {
    final next = (_teamCount + delta).clamp(2, max(2, allPlayers.length));
    teamCountController.text = '$next';
    _prepareTeams();
  }

  void _changeSeconds(int delta) {
    final next = (_seconds + delta).clamp(_minSeconds, _maxSeconds);
    setState(() => secondsController.text = '$next');
  }

  void _moveToNextTeam(String player) {
    final from = getPlayerAssignedTeamIndex(player) ?? -1;
    assignPlayerToTeam(player, (from + 1) % teams.length);
  }

  void _goToSetupStep(int step) {
    if (step > _setupStep) {
      if (_setupStep == 0) {
        if (allPlayers.length < minPlayers) {
          showSnack('Añade al menos $minPlayers jugadores');
          return;
        }
        if (_teamCount > allPlayers.length) {
          teamCountController.text = '${allPlayers.length}';
        }
        if (teams.isEmpty) _prepareTeams();
      } else if (_setupStep == 1 && !validateTeams()) {
        return;
      }
    }
    FocusScope.of(context).unfocus();
    setState(() => _setupStep = step);
  }

  Widget _setupTeamCard(DescribeTeam team, int index) {
    final color = _teamColors[index % _teamColors.length];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.12),
        borderRadius: const BorderRadius.all(Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: CuboColors.blueInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tr(team.name).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CuboColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Text(
                '${team.players.length}',
                style: TextStyle(
                  color: CuboColors.whiteA(0.72),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (team.players.isEmpty)
            Text(
              'Sin jugadores',
              style: TextStyle(
                color: CuboColors.whiteA(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final player in team.players)
                  CuboPressable(
                    onTap: () => _moveToNextTeam(player),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: CuboColors.whiteA(0.14),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              player,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CuboColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.swap_horiz_rounded,
                            color: CuboColors.whiteA(0.6),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTeamsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuboLightCounter(
          title: 'Número de equipos',
          icon: Icons.groups_2_rounded,
          value: '$_teamCount',
          onMinus: _teamCount <= 2 ? null : () => _changeTeamCount(-1),
          onPlus: _teamCount >= allPlayers.length
              ? null
              : () => _changeTeamCount(1),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Toca un jugador para cambiarlo de equipo',
                style: TextStyle(
                  color: CuboColors.whiteA(0.72),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            CuboPressable(
              onTap: autoDistributePlayers,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 9, 14, 9),
                decoration: const BoxDecoration(
                  color: CuboColors.chill,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shuffle_rounded,
                      color: CuboColors.blueInk,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'REPARTIR',
                      style: TextStyle(
                        color: CuboColors.blueInk,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < teams.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _setupTeamCard(teams[i], i),
        ],
      ],
    );
  }

  Widget _buildWordsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CuboSetupOption(
          title: 'PALABRAS APP',
          icon: Icons.auto_awesome_rounded,
          selected: wordsSource == WordsSource.app,
          onTap: () => setState(() => wordsSource = WordsSource.app),
        ),
        const SizedBox(height: 12),
        CuboSetupOption(
          title: 'MI LISTA',
          icon: Icons.edit_note_rounded,
          selected: wordsSource == WordsSource.custom,
          onTap: () => setState(() => wordsSource = WordsSource.custom),
        ),
        if (wordsSource == WordsSource.custom) ...[
          const SizedBox(height: 12),
          CuboSetupTextField(
            controller: customWordsController,
            hint: 'Una palabra por línea\nPerro\nAvión\nPizza',
            minLines: 4,
            maxLines: 7,
          ),
        ],
        const SizedBox(height: 12),
        CuboLightCounter(
          title: 'Segundos por turno',
          icon: Icons.timer_rounded,
          value: '$_seconds',
          onMinus: _seconds <= _minSeconds
              ? null
              : () => _changeSeconds(-_secondsStep),
          onPlus: _seconds >= _maxSeconds
              ? null
              : () => _changeSeconds(_secondsStep),
        ),
        const SizedBox(height: 12),
        const CuboSetupInfoRow(
          title: 'Rondas',
          icon: Icons.layers_rounded,
          value: '3',
        ),
      ],
    );
  }

  Widget buildSetup({required bool compact}) {
    return Column(
      children: [
        buildTopBar(compact: compact, showIllustration: true),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: CuboSetupSteps(
            index: _setupStep,
            onStepChanged: _goToSetupStep,
            onStart: startGame,
            steps: [
              CuboSetupStep(
                title: 'JUGADORES',
                icon: Icons.groups_rounded,
                child: CuboPlayersEditor(
                  players: allPlayers,
                  maxPlayers: maxPlayers,
                  controller: playerController,
                  onAdd: addPlayer,
                  onRemove: removePlayer,
                  emptyHint:
                      'Pulsa + sin escribir para añadir Jugador 1, Jugador 2…',
                ),
              ),
              CuboSetupStep(
                title: 'Equipos',
                icon: Icons.groups_2_rounded,
                child: _buildTeamsStep(),
              ),
              CuboSetupStep(
                title: 'Palabras y tiempo',
                icon: Icons.chat_bubble_rounded,
                child: _buildWordsStep(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRoundIntro({required bool compact}) {
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No hay equipos disponibles',
          style: TextStyle(
            color: CuboColors.white,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    if (currentTeamIndex < 0 || currentTeamIndex >= teams.length) {
      currentTeamIndex = 0;
    }

    final team = teams[currentTeamIndex];
    final accent = getRoundAccent(currentRound);

    return Column(
      children: [
        buildTopBar(
          compact: compact,
          subtitle: getRoundDescription(currentRound),
          showReset: true,
        ),

        SizedBox(height: compact ? 9 : 12),

        buildRoundProgress(compact: compact),

        SizedBox(height: compact ? 9 : 13),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildPanel(
                  accent: accent,
                  padding: EdgeInsets.all(compact ? 15 : 20),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 68 : 82,
                        height: compact ? 68 : 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.20),
                          border: Border.all(color: accent, width: 2.2),
                        ),
                        child: Icon(
                          getRoundIcon(currentRound),
                          color: CuboColors.white,
                          size: compact ? 34 : 41,
                        ),
                      ),

                      SizedBox(height: compact ? 12 : 16),

                      Text(
                        'RONDA $_roundNumber · $_roundShortName',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: accent,
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),

                      SizedBox(height: compact ? 7 : 10),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tr(team.name).toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white,
                            fontSize: compact ? 37 : 46,
                            height: 0.92,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 12 : 16),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: compact ? 11 : 14,
                        ),
                        decoration: CuboDecorations.glass(radius: CuboRadii.md),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: CuboColors.white,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _smallLabel('Le toca a'),

                                  const SizedBox(height: 3),

                                  Text(
                                    team.currentDescriber,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: CuboColors.white,
                                      fontSize: compact ? 17 : 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // IMPORTANTE:
                            // Esta parte ahora tiene un ancho
                            // definido y ya no intenta ocupar
                            // infinito dentro del Row.
                            SizedBox(
                              width: compact ? 70 : 85,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _smallLabel(
                                    'Palabras',
                                    alignment: Alignment.centerRight,
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    '${currentRoundWords.length}',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: compact ? 22 : 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: compact ? 9 : 12),

                _scoreStrip(compact: compact),
              ],
            ),
          ),
        ),

        SizedBox(height: compact ? 8 : 12),

        SizedBox(
          width: double.infinity,
          height: compact ? 54 : 62,
          child: ElevatedButton.icon(
            onPressed: currentRoundWords.isEmpty ? null : startTurn,
            style: mainButtonStyle(
              backgroundColor: accent,
              foregroundColor: CuboColors.blueInk,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'EMPEZAR TURNO',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTurn({required bool compact}) {
    if (teams.isEmpty ||
        currentTeamIndex < 0 ||
        currentTeamIndex >= teams.length) {
      return Center(
        child: Text(
          'No hay equipo disponible',
          style: TextStyle(
            color: CuboColors.white,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    final team = teams[currentTeamIndex];
    final accent = getRoundAccent(currentRound);
    final danger = remainingSeconds <= 5;

    return Column(
      children: [
        buildTopBar(
          compact: compact,
          subtitle: '${team.name} · ${team.currentDescriber}',
          showReset: true,
        ),

        SizedBox(height: compact ? 8 : 11),

        buildRoundProgress(compact: compact),

        SizedBox(height: compact ? 8 : 11),

        _scoreStrip(compact: compact),

        SizedBox(height: compact ? 8 : 11),

        Expanded(
          child: Column(
            children: [
              // CABECERA DEL TURNO
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CuboStatusChip(
                        'Quedan ${currentRoundWords.length} palabras',
                        icon: Icons.layers_rounded,
                        uppercase: false,
                      ),
                    ),
                  ),

                  SizedBox(width: compact ? 10 : 14),

                  // TEMPORIZADOR
                  Container(
                    width: compact ? 62 : 72,
                    height: compact ? 62 : 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (danger ? CuboColors.alert : accent).withValues(
                        alpha: 0.20,
                      ),
                      border: Border.all(
                        color: danger ? CuboColors.alert : accent,
                        width: 2.6,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$remainingSeconds',
                        style: TextStyle(
                          color: danger ? CuboColors.white : CuboColors.white,
                          fontSize: compact ? 27 : 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 8 : 12),

              // PALABRA
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: CuboCardSwitcher(
                      child: CuboHeroCard(
                        key: ValueKey('word-$currentWord'),
                        chip: _roundShortName,
                        chipIcon: getRoundIcon(currentRound),
                        padding: EdgeInsets.fromLTRB(
                          18,
                          compact ? 16 : 20,
                          18,
                          compact ? 30 : 42,
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: compact ? 10 : 18),
                          child: Text(
                            tr(currentWord).toLowerCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CuboColors.blueInk,
                              fontSize: compact ? 43 : 56,
                              height: 0.92,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: compact ? 8 : 12),

        // BOTONES
        Row(
          children: [
            _compactActionButton(
              icon: Icons.skip_next_rounded,
              label: 'PASAR',
              backgroundColor: CuboColors.whiteA(0.10),
              foregroundColor: CuboColors.white,
              onTap: passWord,
              compact: compact,
            ),

            const SizedBox(width: 9),

            _compactActionButton(
              icon: Icons.check_rounded,
              label: 'ACIERTO',
              backgroundColor: CuboColors.white,
              foregroundColor: CuboColors.blue,
              onTap: markCorrect,
              compact: compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRoundFinished({required bool compact}) {
    final isLastRound = currentRound == DescribeRoundType.sounds;
    final accent = getRoundAccent(currentRound);

    return Column(
      children: [
        buildTopBar(
          compact: compact,
          subtitle: 'Ronda $_roundNumber completada',
          showReset: true,
        ),
        SizedBox(height: compact ? 9 : 12),
        buildRoundProgress(compact: compact),
        SizedBox(height: compact ? 9 : 13),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildPanel(
                  accent: accent,
                  padding: EdgeInsets.all(compact ? 15 : 19),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 68 : 80,
                        height: compact ? 68 : 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.20),
                          border: Border.all(color: accent, width: 2.2),
                        ),
                        child: Icon(
                          Icons.flag_rounded,
                          color: CuboColors.white,
                          size: compact ? 34 : 40,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        isLastRound ? 'juego completado' : 'ronda completada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CuboColors.white,
                          fontSize: compact ? 31 : 39,
                          height: 0.92,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.9,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 13),
                      Text(
                        currentRound == DescribeRoundType.describe
                            ? 'Las palabras acertadas pasan ahora a la ronda de mímica.'
                            : currentRound == DescribeRoundType.mime
                            ? 'Las mismas palabras pasan ahora a la ronda de sonidos.'
                            : 'Las tres rondas han terminado. Ya podéis ver el ganador.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: CuboColors.white.withValues(alpha: 0.76),
                          fontSize: compact ? 12.5 : 14,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 9 : 12),
                buildPanel(
                  padding: EdgeInsets.all(compact ? 12 : 15),
                  child: buildScoreBoard(compact: compact),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        SizedBox(
          width: double.infinity,
          height: compact ? 54 : 62,
          child: ElevatedButton.icon(
            onPressed: goToNextRound,
            style: mainButtonStyle(
              backgroundColor: isLastRound ? CuboColors.fiesta : accent,
              foregroundColor: CuboColors.blueInk,
            ),
            icon: Icon(
              isLastRound
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: _singleLineResponsiveText(
              isLastRound ? 'VER GANADOR' : 'SIGUIENTE RONDA',
              alignment: Alignment.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildGameFinished({required bool compact}) {
    final winner = winningTeam;

    return Column(
      children: [
        buildTopBar(
          compact: compact,
          subtitle: 'La partida ha terminado',
          showReset: true,
        ),
        SizedBox(height: compact ? 9 : 13),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CuboIllustration(
                  'describe',
                  size: compact ? 84 : 116,
                  popIn: true,
                ),
                SizedBox(height: compact ? 8 : 12),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    compact ? 20 : 26,
                    16,
                    compact ? 18 : 23,
                  ),
                  decoration: CuboDecorations.whiteCard(radius: CuboRadii.xl),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 60 : 72,
                        height: compact ? 60 : 72,
                        decoration: const BoxDecoration(
                          color: CuboColors.fiesta,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: CuboColors.blueInk,
                          size: compact ? 34 : 42,
                        ),
                      ),
                      SizedBox(height: compact ? 11 : 15),
                      const Text(
                        'EQUIPO GANADOR',
                        style: TextStyle(
                          color: CuboColors.blueInk,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 7),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          winner.name.toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.blueInk,
                            fontSize: compact ? 40 : 48,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${winner.points} PUNTOS',
                        style: TextStyle(
                          color: CuboColors.blueInk,
                          fontSize: compact ? 15 : 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: compact ? 9 : 13),
                buildPanel(
                  padding: EdgeInsets.all(compact ? 12 : 15),
                  child: buildScoreBoard(compact: compact),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Row(
          children: [
            _compactActionButton(
              icon: Icons.home_outlined,
              label: 'MENÚ',
              backgroundColor: CuboColors.whiteA(0.10),
              foregroundColor: CuboColors.white,
              onTap: () => Navigator.pop(context),
              compact: compact,
            ),
            const SizedBox(width: 9),
            _compactActionButton(
              icon: Icons.replay_rounded,
              label: 'OTRA VEZ',
              backgroundColor: CuboColors.white,
              foregroundColor: CuboColors.blue,
              onTap: resetAll,
              compact: compact,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CuboColors.blue,
      body: CuboGameBackground(
        accent: CuboColors.chill,
        halo: CuboHalo.topLeft,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 380;
              final veryNarrow = constraints.maxWidth < 340;

              final compact = constraints.maxHeight < 740 || narrow;

              final horizontalPadding = veryNarrow
                  ? 8.0
                  : compact
                  ? 12.0
                  : 18.0;

              final verticalPadding = compact ? 10.0 : 18.0;

              Widget body;

              switch (currentStep) {
                case DescribeStep.setup:
                  body = buildSetup(compact: compact);
                  break;

                case DescribeStep.roundIntro:
                  body = buildRoundIntro(compact: compact);
                  break;

                case DescribeStep.turn:
                  body = buildTurn(compact: compact);
                  break;

                case DescribeStep.roundFinished:
                  body = buildRoundFinished(compact: compact);
                  break;

                case DescribeStep.gameFinished:
                  body = buildGameFinished(compact: compact);
                  break;
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  compact ? 11 : 16,
                ),
                child: body,
              );
            },
          ),
        ),
      ),
    );
  }
}
