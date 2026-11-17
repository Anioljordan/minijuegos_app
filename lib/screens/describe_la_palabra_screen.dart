import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

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

  static const int minPlayers = 2;
  static const int maxPlayers = 12;

  bool get _isNarrowScreen =>
      MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen =>
      MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 ||
          _isNarrowScreen;

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

  String _nextAutomaticPlayerName() {
    int number = 1;

    while (
    allPlayers.any(
          (player) =>
      player.toLowerCase() == 'jugador $number',
    )
    ) {
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

    final name = typedName.isEmpty
        ? _nextAutomaticPlayerName()
        : typedName;

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

  void _changePlayers(int change) {
    if (change > 0) {
      // El + del contador siempre crea un jugador automático.
      playerController.clear();
      addPlayer();
      return;
    }

    if (allPlayers.isEmpty) return;

    removePlayer(allPlayers.length - 1);
  }

  void createEmptyTeams() {
    final teamCount =
        int.tryParse(teamCountController.text.trim()) ?? 0;

    if (allPlayers.length < minPlayers) {
      showSnack(
        'Añade al menos $minPlayers jugadores',
      );
      return;
    }

    if (teamCount < 2) {
      showSnack(
        'Tiene que haber al menos 2 equipos',
      );
      return;
    }

    if (teamCount > allPlayers.length) {
      showSnack(
        'No puede haber más equipos que jugadores',
      );
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

    final shuffledPlayers =
    List<String>.from(allPlayers)..shuffle(_random);

    setState(() {
      for (final team in teams) {
        team.players.clear();
      }

      for (int index = 0;
      index < shuffledPlayers.length;
      index++) {
        teams[index % teams.length]
            .players
            .add(shuffledPlayers[index]);
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

    final words = customWordsController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList()
      ..shuffle();

    return words;
  }

  void startGame() {
    final seconds =
        int.tryParse(secondsController.text.trim()) ?? 0;

    turnsPlayedInRound = 0;

    if (allPlayers.length < minPlayers) {
      showSnack(
        'Añade al menos $minPlayers jugadores',
      );
      return;
    }

    if (!validateTeams()) return;

    if (seconds < 10) {
      showSnack(
        'Pon al menos 10 segundos por turno',
      );
      return;
    }

    final words = getPreparedWords();

    if (words.length < 8) {
      showSnack(
        'Necesitas al menos 8 palabras',
      );
      return;
    }

    setState(() {
      turnSeconds = seconds;
      remainingSeconds = seconds;
      currentRound = DescribeRoundType.describe;

      baseWords = words;
      currentRoundWords =
      List<String>.from(words)..shuffle(_random);

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

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
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
      },
    );
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
    Color backgroundColor = appWhite,
    Color foregroundColor = appBlue,
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
            border: Border.all(
              color: CuboColors.whiteA(0.55),
              width: 1.6,
            ),
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
            Row(
              children: [
                if (showReset) ...[
                  circleButton(
                    compact: compact,
                    onTap: resetAll,
                    child: Icon(
                      Icons.restart_alt_rounded,
                      color: appWhite,
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
                    color: appWhite,
                    size: compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        if (showIllustration) ...[
          SizedBox(height: compact ? 4 : 10),
          Align(
            alignment: Alignment.centerRight,
            child: CuboIllustration(
              'describe',
              size: compact ? 72 : 108,
            ),
          ),
          SizedBox(height: compact ? 6 : 12),
        ] else
          SizedBox(height: compact ? 14 : 24),

        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                'describe la palabra',
                maxLines: 1,
                textAlign: TextAlign.right,
                style: CuboText.title(size: titleSize),
              ),
            ),
            SizedBox(height: compact ? 9 : 12),
            const CuboPillBar(),
          ],
        ),

        if (subtitle != null) ...[
          SizedBox(height: compact ? 6 : 10),
          buildInfoBar(
            text: subtitle,
            color: currentStep == DescribeStep.setup
                ? accentCyan
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
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compact ? 8 : 10,
      ),
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

  InputDecoration inputDecoration(String hint, {bool dense = false}) {
    return InputDecoration(
      hintText: tr(hint),
      hintStyle: TextStyle(
        color: CuboColors.whiteA(0.50),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: CuboColors.whiteA(0.07),
      isDense: dense,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 13,
        vertical: dense ? 11 : 14,
      ),
      border: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.28), width: 1.2),
      ),
      enabledBorder: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.28), width: 1.2),
      ),
      focusedBorder: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.75), width: 1.6),
      ),
    );
  }

  Widget sectionTitle(String text, {bool compact = false}) {
    return Text(
      tr(text).toLowerCase(),
      style: TextStyle(
        color: appWhite,
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
            ? accentCyan
            : index == 1
            ? accentYellow
            : accentPurple;

        return Expanded(
          child: Container(
            height: compact ? 7 : 9,
            margin: EdgeInsets.only(right: index == 2 ? 0 : 7),
            decoration: BoxDecoration(
              color: active || completed
                  ? color
                  : CuboColors.whiteA(0.16),
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
        color: appWhite.withOpacity(0.67),
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
                    color: foregroundColor.withOpacity(
                      onTap == null ? 0.4 : 1,
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
                        color: foregroundColor.withOpacity(
                          onTap == null ? 0.4 : 1,
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

  Widget _sourceSelector({required bool compact}) {
    Widget option({
      required WordsSource value,
      required String label,
      required IconData icon,
    }) {
      final selected = wordsSource == value;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => wordsSource = value),
          child: Container(
            height: compact ? 58 : 66,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: CuboDecorations.glass(
              selected: selected,
              radius: CuboRadii.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                selected
                    ? CuboCheckBadge(selected: true, size: compact ? 20 : 22)
                    : Icon(icon, color: appWhite, size: compact ? 21 : 24),
                SizedBox(
                  width: _isVeryNarrowScreen ? 5 : 7,
                ),
                Expanded(
                  child: _singleLineResponsiveText(
                    label,
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: appWhite,
                      fontSize: compact ? 10.5 : 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(
          value: WordsSource.app,
          label: 'PALABRAS APP',
          icon: Icons.auto_awesome_rounded,
        ),
        const SizedBox(width: 9),
        option(
          value: WordsSource.custom,
          label: 'MI LISTA',
          icon: Icons.edit_note_rounded,
        ),
      ],
    );
  }

  Widget _teamSummaryCard(DescribeTeam team, int index) {
    final colors = [accentCyan, accentYellow, accentPurple, accentGreen];
    final color = colors[index % colors.length];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.20),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr(team.name).toUpperCase(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  team.players.isEmpty
                      ? 'Sin jugadores'
                      : team.players.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.66),
                    fontSize: 11.5,
                    height: 1.2,
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

  Widget _scoreStrip({required bool compact}) {
    final colors = [accentCyan, accentYellow, accentPurple, accentGreen];

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
                    color: appWhite,
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
    final colors = [accentCyan, accentYellow, accentPurple, accentGreen];

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
                      color: appWhite,
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
    showDialog(
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

  Widget _buildPlayerCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final veryNarrow = _isVeryNarrowScreen;

    final size = veryNarrow
        ? 34.0
        : compact
        ? 38.0
        : 44.0;

    return Material(
      color: onTap == null
          ? CuboColors.whiteA(0.04)
          : CuboColors.whiteA(0.12),
      shape: CircleBorder(
        side: BorderSide(
          color: CuboColors.whiteA(onTap == null ? 0.12 : 0.40),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              color: appWhite.withOpacity(
                onTap == null ? 0.28 : 1,
              ),
              size: veryNarrow
                  ? 19
                  : compact
                  ? 21
                  : 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersCounter({
    required bool compact,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final veryNarrow = constraints.maxWidth < 330;

        final leadingSize = veryNarrow
            ? 34.0
            : compact
            ? 38.0
            : 44.0;

        final gap = veryNarrow ? 6.0 : 9.0;

        final valueWidth = veryNarrow
            ? 27.0
            : compact
            ? 33.0
            : 40.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            veryNarrow
                ? 8
                : compact
                ? 10
                : 12,
          ),
          decoration: CuboDecorations.glass(radius: CuboRadii.md),
          child: Row(
            children: [
              Container(
                width: leadingSize,
                height: leadingSize,
                decoration: BoxDecoration(
                  color: accentCyan.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentCyan.withOpacity(0.75),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: accentCyan,
                  size: veryNarrow
                      ? 19
                      : compact
                      ? 21
                      : 24,
                ),
              ),

              SizedBox(width: gap),

              Expanded(
                child: _singleLineResponsiveText(
                  'JUGADORES',
                  style: TextStyle(
                    color: appWhite,
                    fontSize: veryNarrow
                        ? 10.5
                        : compact
                        ? 12
                        : 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing:
                    veryNarrow ? 0.1 : 0.4,
                  ),
                ),
              ),

              SizedBox(width: gap),

              _buildPlayerCounterButton(
                icon: Icons.remove_rounded,
                onTap: allPlayers.isEmpty
                    ? null
                    : () => _changePlayers(-1),
                compact: compact,
              ),

              SizedBox(
                width: valueWidth,
                child: Text(
                  '${allPlayers.length}',
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appWhite,
                    fontSize: veryNarrow
                        ? 18
                        : compact
                        ? 20
                        : 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              _buildPlayerCounterButton(
                icon: Icons.add_rounded,
                onTap: allPlayers.length >= maxPlayers
                    ? null
                    : () => _changePlayers(1),
                compact: compact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerTile({
    required String player,
    required int index,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.fromLTRB(
        compact ? 9 : 11,
        compact ? 7 : 8,
        5,
        compact ? 7 : 8,
      ),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        children: [
          Container(
            width: compact ? 31 : 35,
            height: compact ? 31 : 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentCyan.withValues(alpha: 0.18),
              border: Border.all(
                color: accentCyan.withValues(alpha: 0.85),
                width: 1.6,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: appWhite,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              player,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appWhite,
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          IconButton(
            tooltip: tr('Eliminar jugador'),
            onPressed: () => removePlayer(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: appWhite.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersEditor({
    required bool compact,
  }) {
    final veryNarrow = _isVeryNarrowScreen;
    return buildPanel(
      accent: accentCyan,
      padding: EdgeInsets.all(compact ? 12 : 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlayersCounter(
            compact: compact,
          ),

          SizedBox(height: compact ? 12 : 14),

          Align(
            alignment: Alignment.centerLeft,
            child: _singleLineResponsiveText(
              'AÑADIR JUGADOR',
              style: TextStyle(
                color: appWhite.withOpacity(0.70),
                fontSize: compact ? 10.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: playerController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => addPlayer(),
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: inputDecoration(
                    'Nombre opcional',
                    dense: compact,
                  ),
                ),
              ),

              SizedBox(
                width: veryNarrow ? 6 : 9,
              ),

              SizedBox(
                width: veryNarrow
                    ? 44
                    : compact
                    ? 50
                    : 54,
                height: veryNarrow
                    ? 48
                    : compact
                    ? 50
                    : 54,
                child: ElevatedButton(
                  onPressed: allPlayers.length >= maxPlayers
                      ? null
                      : addPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentCyan,
                    foregroundColor: appBlue,
                    disabledBackgroundColor:
                    appWhite.withOpacity(0.18),
                    disabledForegroundColor:
                    appWhite.withOpacity(0.42),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,
                    shape: const CircleBorder(),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      size: 29,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: compact ? 12 : 14),

          if (allPlayers.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: compact ? 16 : 20,
              ),
              decoration: BoxDecoration(
                color: CuboColors.whiteA(0.05),
                borderRadius: CuboRadii.mdAll,
                border: Border.all(
                  color: CuboColors.whiteA(0.18),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: appWhite.withOpacity(0.48),
                    size: compact ? 28 : 34,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Todavía no has añadido jugadores',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.66),
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Pulsa + sin escribir para añadir Jugador 1, Jugador 2…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.44),
                      fontSize: compact ? 10.5 : 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _singleLineResponsiveText(
                    'LISTA DE JUGADORES',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.70),
                      fontSize: compact ? 10.5 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  '${allPlayers.length} / $maxPlayers',
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.62),
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            ...allPlayers.asMap().entries.map(
                  (entry) => _buildPlayerTile(
                player: entry.value,
                index: entry.key,
                compact: compact,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildSetup({required bool compact}) {
    return Column(
      children: [
        buildTopBar(
          compact: compact,
          showIllustration: true,
        ),
        SizedBox(height: compact ? 10 : 14),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPlayersEditor(
                  compact: compact,
                ),
                SizedBox(height: compact ? 9 : 12),
                buildPanel(
                  accent: accentYellow,
                  padding: EdgeInsets.all(compact ? 12 : 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Equipos', compact: compact),
                      SizedBox(height: compact ? 10 : 13),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 390;

                          final teamCountField = TextField(
                            controller: teamCountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: appWhite,
                              fontWeight: FontWeight.w800,
                            ),
                            cursorColor: appWhite,
                            decoration: inputDecoration(
                              'Número de equipos',
                              dense: compact,
                            ),
                          );

                          final createButton = SizedBox(
                            height: compact ? 48 : 54,
                            child: ElevatedButton(
                              onPressed: createEmptyTeams,
                              style: CuboButtons.primary(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'CREAR',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          );

                          final shuffleButton = SizedBox(
                            height: compact ? 48 : 54,
                            child: OutlinedButton.icon(
                              onPressed: autoDistributePlayers,
                              style: secondaryButtonStyle(),
                              icon: Icon(
                                Icons.shuffle_rounded,
                                size: compact ? 20 : 23,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'REPARTIR',
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (narrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                teamCountField,
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(child: createButton),
                                    const SizedBox(width: 8),
                                    Expanded(child: shuffleButton),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: teamCountField,
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 92,
                                child: createButton,
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 118,
                                child: shuffleButton,
                              ),
                            ],
                          );
                        },
                      ),
                      if (teams.isNotEmpty) ...[
                        SizedBox(height: compact ? 12 : 15),
                        _smallLabel('Asignar jugadores'),
                        const SizedBox(height: 8),
                        ...allPlayers.map((player) {
                          final assignedTeam =
                          getPlayerAssignedTeamIndex(player);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: CuboDecorations.glass(
                              radius: CuboRadii.input,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    player,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: appWhite,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                DropdownButton<int>(
                                  value: assignedTeam,
                                  dropdownColor: appBlue,
                                  borderRadius: CuboRadii.mdAll,
                                  hint: Text(
                                    'Equipo',
                                    style: TextStyle(
                                      color: appWhite.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: appWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  underline: const SizedBox.shrink(),
                                  iconEnabledColor: appWhite,
                                  items: List.generate(
                                    teams.length,
                                        (index) => DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        teams[index].name,
                                        style: const TextStyle(
                                          color: appWhite,
                                        ),
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
                        SizedBox(height: compact ? 6 : 9),
                        ...teams.asMap().entries.map(
                              (entry) => _teamSummaryCard(
                            entry.value,
                            entry.key,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: compact ? 9 : 12),
                buildPanel(
                  accent: accentPurple,
                  padding: EdgeInsets.all(compact ? 12 : 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('Palabras y tiempo', compact: compact),
                      SizedBox(height: compact ? 10 : 13),
                      _sourceSelector(compact: compact),
                      if (wordsSource == WordsSource.custom) ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: customWordsController,
                          minLines: 4,
                          maxLines: 7,
                          style: const TextStyle(
                            color: appWhite,
                            fontWeight: FontWeight.w700,
                          ),
                          cursorColor: appWhite,
                          decoration: inputDecoration(
                            'Una palabra por línea\nPerro\nAvión\nPizza',
                            dense: compact,
                          ),
                        ),
                      ],
                      SizedBox(height: compact ? 11 : 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _smallLabel('Segundos por turno'),
                                const SizedBox(height: 7),
                                TextField(
                                  controller: secondsController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(
                                    color: appWhite,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  cursorColor: appWhite,
                                  decoration: inputDecoration(
                                    '30',
                                    dense: compact,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: compact ? 67 : 74,
                              decoration: CuboDecorations.glass(
                                radius: CuboRadii.md,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.layers_rounded,
                                    color: appWhite,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '3 RONDAS',
                                    style: TextStyle(
                                      color: appWhite.withOpacity(0.76),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
            onPressed: () {
              FocusScope.of(context).unfocus();
              startGame();
            },
            style: CuboButtons.primary(padding: null),
            icon: const Icon(Icons.play_arrow_rounded),
            label: _singleLineResponsiveText(
              'EMPEZAR TURNO',
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

  Widget buildRoundIntro({required bool compact}) {
    if (teams.isEmpty) {
      return Center(
        child: Text(
          'No hay equipos disponibles',
          style: TextStyle(
            color: appWhite,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    if (currentTeamIndex < 0 ||
        currentTeamIndex >= teams.length) {
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

        SizedBox(
          height: compact ? 9 : 12,
        ),

        buildRoundProgress(
          compact: compact,
        ),

        SizedBox(
          height: compact ? 9 : 13,
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                buildPanel(
                  accent: accent,
                  padding: EdgeInsets.all(
                    compact ? 15 : 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 68 : 82,
                        height: compact ? 68 : 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.20),
                          border: Border.all(
                            color: accent,
                            width: 2.2,
                          ),
                        ),
                        child: Icon(
                          getRoundIcon(currentRound),
                          color: appWhite,
                          size: compact ? 34 : 41,
                        ),
                      ),

                      SizedBox(
                        height: compact ? 12 : 16,
                      ),

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

                      SizedBox(
                        height: compact ? 7 : 10,
                      ),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          tr(team.name).toLowerCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: appWhite,
                            fontSize: compact ? 37 : 46,
                            height: 0.92,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: compact ? 12 : 16,
                      ),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: compact ? 11 : 14,
                        ),
                        decoration: CuboDecorations.glass(
                          radius: CuboRadii.md,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              color: appWhite,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _smallLabel(
                                    'Le toca a',
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    team.currentDescriber,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: appWhite,
                                      fontSize:
                                      compact ? 17 : 20,
                                      fontWeight:
                                      FontWeight.w900,
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
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [
                                  _smallLabel(
                                    'Palabras',
                                    alignment:
                                    Alignment.centerRight,
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    '${currentRoundWords.length}',
                                    textAlign:
                                    TextAlign.right,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize:
                                      compact ? 22 : 26,
                                      fontWeight:
                                      FontWeight.w900,
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

                SizedBox(
                  height: compact ? 9 : 12,
                ),

                _scoreStrip(
                  compact: compact,
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          height: compact ? 8 : 12,
        ),

        SizedBox(
          width: double.infinity,
          height: compact ? 54 : 62,
          child: ElevatedButton.icon(
            onPressed:
            currentRoundWords.isEmpty
                ? null
                : startTurn,
            style: mainButtonStyle(
              backgroundColor: accent,
              foregroundColor:
              currentRound ==
                  DescribeRoundType.mime
                  ? appBlue
                  : appWhite,
            ),
            icon: const Icon(
              Icons.play_arrow_rounded,
            ),
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
            color: appWhite,
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

        SizedBox(
          height: compact ? 8 : 11,
        ),

        buildRoundProgress(
          compact: compact,
        ),

        SizedBox(
          height: compact ? 8 : 11,
        ),

        _scoreStrip(
          compact: compact,
        ),

        SizedBox(
          height: compact ? 8 : 11,
        ),

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

                  SizedBox(
                    width: compact ? 10 : 14,
                  ),

                  // TEMPORIZADOR
                  Container(
                    width: compact ? 62 : 72,
                    height: compact ? 62 : 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (
                          danger
                              ? const Color(0xFFFF4D6D)
                              : accent
                      ).withValues(alpha: 0.20),
                      border: Border.all(
                        color: danger
                            ? const Color(0xFFFF4D6D)
                            : accent,
                        width: 2.6,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$remainingSeconds',
                        style: TextStyle(
                          color: danger
                              ? const Color(0xFFFF8FA3)
                              : appWhite,
                          fontSize: compact ? 27 : 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: compact ? 8 : 12,
              ),

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

        SizedBox(
          height: compact ? 8 : 12,
        ),

        // BOTONES
        Row(
          children: [
            _compactActionButton(
              icon: Icons.skip_next_rounded,
              label: 'PASAR',
              backgroundColor: CuboColors.whiteA(0.10),
              foregroundColor: appWhite,
              onTap: passWord,
              compact: compact,
            ),

            const SizedBox(width: 9),

            _compactActionButton(
              icon: Icons.check_rounded,
              label: 'ACIERTO',
              backgroundColor: appWhite,
              foregroundColor: appBlue,
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
                          color: appWhite,
                          size: compact ? 34 : 40,
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 16),
                      Text(
                        isLastRound ? 'juego completado' : 'ronda completada',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appWhite,
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
                          color: appWhite.withOpacity(0.76),
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
              backgroundColor: isLastRound ? accentGreen : accent,
              foregroundColor: currentRound == DescribeRoundType.mime
                  ? appBlue
                  : appWhite,
            ),
            icon: Icon(
              isLastRound
                  ? Icons.emoji_events_rounded
                  : Icons.arrow_forward_rounded,
            ),
            label: _singleLineResponsiveText(
              isLastRound
                  ? 'VER GANADOR'
                  : 'SIGUIENTE RONDA',
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
                  decoration: CuboDecorations.whiteCard(
                    radius: CuboRadii.xl,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: compact ? 60 : 72,
                        height: compact ? 60 : 72,
                        decoration: const BoxDecoration(
                          color: accentYellow,
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
              foregroundColor: appWhite,
              onTap: () => Navigator.pop(context),
              compact: compact,
            ),
            const SizedBox(width: 9),
            _compactActionButton(
              icon: Icons.replay_rounded,
              label: 'OTRA VEZ',
              backgroundColor: appWhite,
              foregroundColor: appBlue,
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
      body: CuboBackground(
        halo: CuboHalo.topLeft,
        child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 380;
            final veryNarrow = constraints.maxWidth < 340;

            final compact =
                constraints.maxHeight < 740 || narrow;

            final horizontalPadding = veryNarrow
                ? 8.0
                : compact
                ? 12.0
                : 18.0;

            final verticalPadding =
            compact ? 10.0 : 18.0;

            Widget body;

            switch (currentStep) {
              case DescribeStep.setup:
                body = buildSetup(
                  compact: compact,
                );
                break;

              case DescribeStep.roundIntro:
                body = buildRoundIntro(
                  compact: compact,
                );
                break;

              case DescribeStep.turn:
                body = buildTurn(
                  compact: compact,
                );
                break;

              case DescribeStep.roundFinished:
                body = buildRoundFinished(
                  compact: compact,
                );
                break;

              case DescribeStep.gameFinished:
                body = buildGameFinished(
                  compact: compact,
                );
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
