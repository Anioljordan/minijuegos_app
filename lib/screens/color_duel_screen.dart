import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../widgets/color_wheel_picker.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/cubo_setup_widgets.dart';

enum ColorDuelPhase { setup, ready, memorize, pick, roundResult, finalResult }

enum ColorDuelMode { sameColorForAll, differentColorPerPlayer }

class ColorDuelPlayer {
  final String name;
  int totalScore;
  Color? selectedColor;
  int lastRoundScore;

  ColorDuelPlayer({
    required this.name,
    this.totalScore = 0,
    this.selectedColor,
    this.lastRoundScore = 0,
  });
}

class ColorDuelScreen extends StatefulWidget {
  const ColorDuelScreen({super.key});

  @override
  State<ColorDuelScreen> createState() => _ColorDuelScreenState();
}

class _ColorDuelScreenState extends State<ColorDuelScreen> {
  final Random _random = Random();

  static const int minPlayers = 2;
  static const int maxPlayers = 12;

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 || _isNarrowScreen;

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

  ColorDuelPhase _phase = ColorDuelPhase.setup;

  /// Paso visible de la configuración (solo interfaz).
  int _setupStep = 0;

  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _roundsController = TextEditingController(
    text: '5',
  );
  final TextEditingController _memorizeSecondsController =
      TextEditingController(text: '3');

  final List<String> _setupPlayerNames = [];

  List<ColorDuelPlayer> _players = [];

  int _currentRound = 1;
  int _totalRounds = 5;
  int _memorizeSeconds = 3;
  int _secondsLeft = 3;
  int _currentPlayerIndex = 0;

  Color _targetColor = Colors.red;
  ColorDuelMode _gameMode = ColorDuelMode.sameColorForAll;
  Map<int, Color> _playerTargetColors = {};

  double _red = 128;
  double _green = 128;
  double _blue = 128;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _playerNameController.dispose();
    _roundsController.dispose();
    _memorizeSecondsController.dispose();
    super.dispose();
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: EdgeInsets.zero);
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _circleButton({
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
            color: CuboColors.white.withValues(alpha: 0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: CuboDecorations.glassRaised(radius: CuboRadii.card),
      child: child,
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    return SizedBox(
      width: double.infinity,
      height: compact ? 54 : 62,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonStyle(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: veryNarrow ? 7 : 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: CuboColors.blue,
                  size: veryNarrow
                      ? 19
                      : compact
                      ? 21
                      : 24,
                ),
                SizedBox(width: veryNarrow ? 5 : 9),
              ],

              Expanded(
                child: _singleLineResponsiveText(
                  tr(text).toUpperCase(),
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: CuboColors.blue,
                    fontSize: compact ? 13.5 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar({required bool compact}) {

    final bool showRound = _phase != ColorDuelPhase.setup;

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
            _circleButton(
              compact: compact,
              onTap: _showRulesDialog,
              child: Icon(
                Icons.question_mark_rounded,
                color: CuboColors.white,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 6 : 12),
        CuboGameTitle(
          'memoria fotográfica',
          side: CuboTitleSide.chill,
          illustration: showRound ? null : 'color_memory',
          compact: compact,
        ),

        if (showRound) ...[
          SizedBox(height: compact ? 6 : 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 8 : 9,
            ),
            decoration: CuboDecorations.glass(radius: CuboRadii.md),
            child: Row(
              children: [
                Flexible(
                  child: _singleLineResponsiveText(
                    'RONDA $_currentRound DE $_totalRounds',
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.82),
                      fontSize: compact ? 11.5 : 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CuboProgressDots(
                      total: _totalRounds,
                      current: _currentRound - 1,
                      maxDots: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  Future<void> _showRulesDialog() {
    return showCuboDialog(
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
                    'MEMORIA FOTOGRÁFICA',
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _rulesItem(
                    icon: Icons.visibility_rounded,
                    title: 'Memoriza',
                    text:
                        'Cada jugador verá un color durante unos segundos. Cuando termine el tiempo aparecerá directamente la ruleta para recrearlo.',
                  ),

                  _rulesItem(
                    icon: Icons.palette_rounded,
                    title: 'Recrea el color',
                    text:
                        'Usa la ruleta para elegir el color que crees que era el original.',
                  ),

                  _rulesItem(
                    icon: Icons.group_work_rounded,
                    title: 'Modos',
                    text:
                        'Podéis jugar con el mismo color para todos o con un color distinto para cada jugador.',
                  ),

                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Puntuación',
                    text:
                        'Cuanto más se parezca tu color al objetivo, más puntos ganas.',
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

  void _showSetupMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CuboColors.blue,
        ),
      );
  }

  String _nextAutomaticPlayerName() {
    int number = 1;

    while (_setupPlayerNames.any(
      (name) => name.toLowerCase() == 'jugador $number',
    )) {
      number++;
    }

    return 'Jugador $number';
  }

  void _addSetupPlayer() {
    if (_setupPlayerNames.length >= maxPlayers) {
      _showSetupMessage('El máximo es de $maxPlayers jugadores.');
      return;
    }

    final typedName = _playerNameController.text.trim();

    final name = typedName.isEmpty ? _nextAutomaticPlayerName() : typedName;

    final duplicated = _setupPlayerNames.any(
      (playerName) => playerName.toLowerCase() == name.toLowerCase(),
    );

    if (duplicated) {
      _showSetupMessage('Ese jugador ya está añadido.');
      return;
    }

    setState(() {
      _setupPlayerNames.add(name);
      _playerNameController.clear();
    });
  }

  void _removeSetupPlayer(int index) {
    if (index < 0 || index >= _setupPlayerNames.length) {
      return;
    }

    setState(() {
      _setupPlayerNames.removeAt(index);
    });
  }

  void _changeRounds(int delta) {
    final current = int.tryParse(_roundsController.text) ?? 5;
    final next = (current + delta).clamp(1, 20);

    setState(() {
      _roundsController.text = next.toString();
    });
  }

  void _changeSeconds(int delta) {
    final current = int.tryParse(_memorizeSecondsController.text) ?? 3;
    final next = (current + delta).clamp(1, 10);

    setState(() {
      _memorizeSecondsController.text = next.toString();
    });
  }

  Color _generateRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  double _colorDistance(Color a, Color b) {
    final dr = a.red - b.red;
    final dg = a.green - b.green;
    final db = a.blue - b.blue;

    return sqrt((dr * dr + dg * dg + db * db).toDouble());
  }

  int _calculateScore(Color target, Color selected) {
    const maxDistance = 441.67295593;
    final distance = _colorDistance(target, selected);
    final normalized = (1 - (distance / maxDistance)).clamp(0.0, 1.0);

    return (normalized * 1000).round();
  }

  int _calculateAccuracyPercent(Color target, Color selected) {
    const maxDistance = 441.67295593;
    final distance = _colorDistance(target, selected);
    final normalized = (1 - (distance / maxDistance)).clamp(0.0, 1.0);

    return (normalized * 100).round();
  }

  Color get _currentSelectedColor =>
      Color.fromARGB(255, _red.round(), _green.round(), _blue.round());

  void _startGame() {
    if (_setupPlayerNames.length < minPlayers) {
      _showSetupMessage('Añade al menos $minPlayers jugadores.');
      return;
    }

    _totalRounds = (int.tryParse(_roundsController.text) ?? 5).clamp(1, 20);

    _memorizeSeconds = (int.tryParse(_memorizeSecondsController.text) ?? 3)
        .clamp(1, 10);

    _players = _setupPlayerNames
        .map((name) => ColorDuelPlayer(name: name))
        .toList();

    _currentRound = 1;
    _currentPlayerIndex = 0;

    _startNewRound();
  }

  void _startNewRound() {
    _secondsLeft = _memorizeSeconds;
    _currentPlayerIndex = 0;
    _playerTargetColors = {};

    if (_gameMode == ColorDuelMode.sameColorForAll) {
      _targetColor = _generateRandomColor();
    } else {
      for (int i = 0; i < _players.length; i++) {
        _playerTargetColors[i] = _generateRandomColor();
      }

      _targetColor = _playerTargetColors[0]!;
    }

    for (final player in _players) {
      player.selectedColor = null;
      player.lastRoundScore = 0;
    }

    setState(() {
      _phase = ColorDuelPhase.ready;
    });
  }

  /// El color no se muestra hasta que el jugador pulsa "Preparado".
  void _startMemorize() {
    setState(() {
      _secondsLeft = _memorizeSeconds;
      _phase = ColorDuelPhase.memorize;
    });

    _startMemorizeCountdown();
  }

  void _startMemorizeCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();

        if (!mounted) return;

        // Al terminar, abre directamente el selector de color.
        _goToPickPhase();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _goToPickPhase() {
    _red = 128;
    _green = 128;
    _blue = 128;

    if (_gameMode == ColorDuelMode.differentColorPerPlayer) {
      _targetColor = _playerTargetColors[_currentPlayerIndex]!;
    }

    setState(() {
      _phase = ColorDuelPhase.pick;
    });
  }

  void _confirmCurrentPlayerColor() {
    final selected = _currentSelectedColor;
    final player = _players[_currentPlayerIndex];

    final Color roundTargetColor = _gameMode == ColorDuelMode.sameColorForAll
        ? _targetColor
        : _playerTargetColors[_currentPlayerIndex]!;

    final score = _calculateScore(roundTargetColor, selected);

    player.selectedColor = selected;
    player.lastRoundScore = score;
    player.totalScore += score;

    if (_currentPlayerIndex < _players.length - 1) {
      _currentPlayerIndex++;
      _secondsLeft = _memorizeSeconds;

      if (_gameMode == ColorDuelMode.differentColorPerPlayer) {
        _targetColor = _playerTargetColors[_currentPlayerIndex]!;
      }

      setState(() {
        _phase = ColorDuelPhase.ready;
      });
    } else {
      setState(() {
        _phase = ColorDuelPhase.roundResult;
      });
    }
  }

  void _nextAfterRoundResult() {
    if (_currentRound < _totalRounds) {
      _currentRound++;
      _startNewRound();
    } else {
      setState(() {
        _phase = ColorDuelPhase.finalResult;
      });
    }
  }

  void _resetGame() {
    _timer?.cancel();

    setState(() {
      _phase = ColorDuelPhase.setup;
      _setupStep = 0;
      _players = [];
      _currentRound = 1;
      _currentPlayerIndex = 0;
      _targetColor = Colors.red;
      _playerTargetColors = {};
      _red = 128;
      _green = 128;
      _blue = 128;
    });
  }

  List<ColorDuelPlayer> _sortedPlayersByRound() {
    final sorted = [..._players];
    sorted.sort((a, b) => b.lastRoundScore.compareTo(a.lastRoundScore));

    return sorted;
  }

  List<ColorDuelPlayer> _sortedPlayersByTotal() {
    final sorted = [..._players];
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return sorted;
  }

  Widget _sectionTitle(String text) {
    return SizedBox(
      width: double.infinity,
      child: _singleLineResponsiveText(
        tr(text).toLowerCase(),
        style: TextStyle(
          color: CuboColors.white,
          fontSize: _isCompactScreen ? 24 : 30,
          height: 0.95,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.7,
        ),
      ),
    );
  }

  void _goToSetupStep(int step) {
    if (step > _setupStep && _setupPlayerNames.length < minPlayers) {
      _showSetupMessage('Añade al menos $minPlayers jugadores.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _setupStep = step);
  }

  Widget _buildSetupPhase() {
    return CuboSetupSteps(
      key: const ValueKey('setup'),
      index: _setupStep,
      onStepChanged: _goToSetupStep,
      onStart: _startGame,
      steps: [
        CuboSetupStep(
          title: 'JUGADORES',
          icon: Icons.groups_rounded,
          child: CuboPlayersEditor(
            players: _setupPlayerNames,
            maxPlayers: maxPlayers,
            controller: _playerNameController,
            onAdd: _addSetupPlayer,
            onRemove: _removeSetupPlayer,
          ),
        ),
        CuboSetupStep(
          title: 'CONFIGURACIÓN',
          icon: Icons.palette_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CuboLightCounter(
                title: 'Rondas',
                icon: Icons.flag_rounded,
                value: _roundsController.text,
                onMinus: () => _changeRounds(-1),
                onPlus: () => _changeRounds(1),
              ),
              const SizedBox(height: 12),
              CuboLightCounter(
                title: 'Memoria',
                icon: Icons.timer_rounded,
                value: '${_memorizeSecondsController.text}s',
                onMinus: () => _changeSeconds(-1),
                onPlus: () => _changeSeconds(1),
              ),
              const SizedBox(height: 12),
              CuboSetupOption(
                title: 'Mismo color',
                subtitle: 'Uno para todos',
                icon: Icons.group_work_rounded,
                selected: _gameMode == ColorDuelMode.sameColorForAll,
                onTap: () =>
                    setState(() => _gameMode = ColorDuelMode.sameColorForAll),
              ),
              const SizedBox(height: 12),
              CuboSetupOption(
                title: 'Color distinto',
                subtitle: 'Uno por jugador',
                icon: Icons.auto_awesome_rounded,
                selected: _gameMode == ColorDuelMode.differentColorPerPlayer,
                onTap: () => setState(
                  () => _gameMode = ColorDuelMode.differentColorPerPlayer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case ColorDuelPhase.setup:
        return _buildSetupPhase();
      case ColorDuelPhase.ready:
        return _buildReadyPhase();
      case ColorDuelPhase.memorize:
        return _buildMemorizePhase();
      case ColorDuelPhase.pick:
        return _buildPickPhase();
      case ColorDuelPhase.roundResult:
        return _buildRoundResultPhase();
      case ColorDuelPhase.finalResult:
        return _buildFinalResultPhase();
    }
  }

  /// Pantalla de paso entre jugadores: el color sigue tapado hasta que el
  /// jugador que tiene el móvil pulsa "Preparado".
  Widget _buildReadyPhase() {
    final player = _players[_currentPlayerIndex];
    final compact = _isCompactScreen;
    final hiddenSize = compact ? 150.0 : 190.0;

    return Padding(
      key: ValueKey('ready_${_currentRound}_$_currentPlayerIndex'),
      padding: EdgeInsets.only(top: compact ? 6 : 10, bottom: compact ? 8 : 12),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: _glassCard(
                padding: const EdgeInsets.fromLTRB(18, 24, 18, 26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tr('PÁSALE EL MÓVIL A'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CuboColors.whiteA(0.62),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.9,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: _singleLineResponsiveText(
                        player.name,
                        alignment: Alignment.center,
                        style: TextStyle(
                          color: CuboColors.white,
                          fontSize: compact ? 30 : 38,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 18 : 24),
                    Container(
                      width: hiddenSize,
                      height: hiddenSize,
                      decoration: BoxDecoration(
                        color: CuboColors.whiteA(0.06),
                        borderRadius: CuboRadii.lgAll,
                        border: Border.all(
                          color: CuboColors.whiteA(0.28),
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Icons.visibility_off_rounded,
                        color: CuboColors.whiteA(0.45),
                        size: hiddenSize * 0.3,
                      ),
                    ),
                    SizedBox(height: compact ? 14 : 18),
                    Text(
                      tr('El color sale al pulsar Preparado'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CuboColors.whiteA(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          _primaryButton(
            text: 'Preparado',
            icon: Icons.visibility_rounded,
            onPressed: _startMemorize,
          ),
        ],
      ),
    );
  }

  Widget _buildMemorizePhase() {
    return Padding(
      key: const ValueKey('memorize'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Center(
        child: _glassCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isCompactScreen) ...[
                CuboStatusChip(
                  _gameMode == ColorDuelMode.sameColorForAll
                      ? 'Mismo color'
                      : 'Color distinto',
                  icon: Icons.palette_rounded,
                ),
                const SizedBox(height: 12),
              ],

              SizedBox(
                width: double.infinity,
                child: _singleLineResponsiveText(
                  'Turno de ${_players[_currentPlayerIndex].name}',
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: _isCompactScreen ? 21 : 25,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _gameMode == ColorDuelMode.sameColorForAll
                    ? 'Memoriza este color'
                    : 'Memoriza tu color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final size = min(
                    _isVeryNarrowScreen ||
                            MediaQuery.sizeOf(context).height < 740
                        ? 190.0
                        : 230.0,
                    constraints.maxWidth,
                  );

                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: _targetColor,
                      borderRadius: CuboRadii.lgAll,
                      border: Border.all(
                        color: CuboColors.white.withValues(alpha: 0.75),
                        width: 3,
                      ),
                      boxShadow: CuboShadows.soft,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CuboColors.white.withValues(alpha: 0.85),
                    width: 2.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$_secondsLeft',
                    style: const TextStyle(
                      color: CuboColors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
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

  Widget _buildPickPhase() {
    final player = _players[_currentPlayerIndex];

    final compact = _isCompactScreen;

    return Padding(
      key: const ValueKey('pick'),
      padding: EdgeInsets.only(top: compact ? 6 : 10, bottom: compact ? 8 : 12),
      child: Column(
        children: [
          Expanded(
            child: _glassCard(
              padding: EdgeInsets.all(compact ? 11 : 15),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _singleLineResponsiveText(
                          'Turno de ${player.name}',
                          alignment: Alignment.center,
                          style: TextStyle(
                            color: CuboColors.white,
                            fontSize: compact ? 19 : 24,
                            height: 0.95,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 5 : 7),

                      Text(
                        'Recrea el color que acabas de memorizar',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CuboColors.white.withValues(alpha: 0.65),
                          fontSize: compact ? 11 : 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: compact ? 9 : 12),

                      // PREVISUALIZACIÓN MÁS PEQUEÑA
                      Container(
                        width: double.infinity,
                        height: compact ? 52 : 68,
                        decoration: BoxDecoration(
                          color: _currentSelectedColor,
                          borderRadius: CuboRadii.mdAll,
                          border: Border.all(
                            color: CuboColors.white.withValues(alpha: 0.70),
                            width: 2.4,
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 9 : 13),

                      Expanded(
                        child: Center(
                          child: ColorWheelPicker(
                            // Fuerza un selector
                            // nuevo para cada turno.
                            key: ValueKey(
                              'color_picker_${_currentRound}_${_currentPlayerIndex}',
                            ),

                            maxWheelSize: compact ? 185 : 225,

                            // Coincide con el gris
                            // inicial RGB(128,128,128)
                            initialHue: 0,
                            initialSaturation: 0,
                            initialValue: 128 / 255,

                            onColorChanged: (color) {
                              setState(() {
                                _red = color.red.toDouble();

                                _green = color.green.toDouble();

                                _blue = color.blue.toDouble();
                              });
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: compact ? 5 : 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: CuboColors.white.withValues(alpha: 0.42),
                            size: compact ? 14 : 16,
                          ),

                          const SizedBox(width: 5),

                          Flexible(
                            child: Text(
                              'Toca para elegir · arrastra el punto para afinar',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CuboColors.white.withValues(alpha: 0.44),
                                fontSize: compact ? 9.5 : 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          SizedBox(height: compact ? 8 : 12),

          // SIEMPRE VISIBLE
          _primaryButton(
            text: 'Confirmar color',
            icon: Icons.check_circle_outline_rounded,
            onPressed: _confirmCurrentPlayerColor,
          ),
        ],
      ),
    );
  }

  Widget _colorBlock({required String label, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _singleLineResponsiveText(
              tr(label).toUpperCase(),
              alignment: Alignment.center,
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Container(
            height: 74,
            decoration: BoxDecoration(
              color: color,
              borderRadius: CuboRadii.mdAll,
              border: Border.all(
                color: CuboColors.white.withValues(alpha: 0.50),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: CuboDecorations.glass(radius: CuboRadii.md),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: _singleLineResponsiveText(
                tr(label).toUpperCase(),
                alignment: Alignment.center,
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.62),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: CuboColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundResultPhase() {
    final roundRanking = _sortedPlayersByRound();

    return SingleChildScrollView(
      key: const ValueKey('roundResult'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionTitle('Resultado de la ronda'),

          const SizedBox(height: 14),

          ...roundRanking.map((player) {
            final playerIndex = _players.indexOf(player);
            final Color targetForPlayer =
                _gameMode == ColorDuelMode.sameColorForAll
                ? _targetColor
                : _playerTargetColors[playerIndex]!;

            final accuracy = _calculateAccuracyPercent(
              targetForPlayer,
              player.selectedColor ?? Colors.black,
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: CuboColors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _colorBlock(label: 'Objetivo', color: targetForPlayer),
                        const SizedBox(width: 12),
                        _colorBlock(
                          label: 'Elegido',
                          color: player.selectedColor ?? Colors.transparent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        height: 8,
                        color: CuboColors.white.withValues(alpha: 0.12),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: accuracy / 100,
                          child: Container(color: CuboColors.chill),
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'PRECISIÓN: $accuracy%',
                      style: TextStyle(
                        color: CuboColors.white.withValues(alpha: 0.74),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _scoreBox(
                          label: 'Ronda',
                          value: '+${player.lastRoundScore}',
                        ),
                        const SizedBox(width: 10),
                        _scoreBox(
                          label: 'Total',
                          value: '${player.totalScore}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 4),

          _primaryButton(
            text: _currentRound < _totalRounds
                ? 'Siguiente ronda'
                : 'Ver resultado final',
            icon: Icons.arrow_forward_rounded,
            onPressed: _nextAfterRoundResult,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResultPhase() {
    final finalRanking = _sortedPlayersByTotal();
    final winner = finalRanking.first;

    return SingleChildScrollView(
      key: const ValueKey('finalResult'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _glassCard(
            child: Column(
              children: [
                CuboIllustration(
                  'color_memory',
                  size: _isCompactScreen ? 84 : 108,
                  popIn: true,
                ),

                const SizedBox(height: 12),

                const Text(
                  'resultado\nfinal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.white,
                    fontSize: 38,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                  ),
                ),

                const SizedBox(height: 10),

                const CuboPillBar(),

                const SizedBox(height: 12),

                Text(
                  'Ganador: ${winner.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CuboColors.white.withValues(alpha: 0.76),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          ...finalRanking.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _glassCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CuboColors.white.withValues(alpha: 0.85),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: CuboColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          color: CuboColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Text(
                      '${player.totalScore} pts',
                      style: TextStyle(
                        color: CuboColors.white.withValues(alpha: 0.78),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          _primaryButton(
            text: 'Volver a jugar',
            icon: Icons.refresh_rounded,
            onPressed: _resetGame,
          ),
        ],
      ),
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

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  compact ? 10 : 16,
                ),
                child: Column(
                  children: [
                    _buildTopBar(compact: compact),

                    SizedBox(height: compact ? 8 : 14),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _buildCurrentPhase(),
                      ),
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
