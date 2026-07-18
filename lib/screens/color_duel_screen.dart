import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/color_wheel_picker.dart';
import '../widgets/app_logo_button.dart';

enum ColorDuelPhase {
  setup,
  memorize,
  passPhone,
  pick,
  roundResult,
  finalResult,
}

enum ColorDuelMode {
  sameColorForAll,
  differentColorPerPlayer,
}

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

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF22C55E);

  ColorDuelPhase _phase = ColorDuelPhase.setup;

  final TextEditingController _playerNameController =
  TextEditingController();
  final TextEditingController _roundsController =
  TextEditingController(text: '5');
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
            color: appWhite.withOpacity(0.85),
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

  Widget _primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonStyle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: appBlue, size: 22),
                const SizedBox(width: 9),
              ],
              Text(
                text.toUpperCase(),
                style: const TextStyle(
                  color: appBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fancyInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: appWhite.withOpacity(0.65),
        fontWeight: FontWeight.w700,
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

  Widget _buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 70.0 : 92.0;
    final lineTop = compact ? 40.0 : 60.0;

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
                color: appWhite,
                size: compact ? 23 : 27,
              ),
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
                        'memoria fotográfica',
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

        if (showRound) ...[
          SizedBox(height: compact ? 6 : 10),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compact ? 8 : 9,
            ),
            decoration: BoxDecoration(
              color: appWhite.withOpacity(0.06),
              border: Border(
                left: const BorderSide(
                  color: accentPurple,
                  width: 6,
                ),
                bottom: BorderSide(
                  color: appWhite.withOpacity(0.36),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              'RONDA $_currentRound DE $_totalRounds',
              style: TextStyle(
                color: appWhite.withOpacity(0.82),
                fontSize: compact ? 11.5 : 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
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

  Future<void> _showRulesDialog() {
    return showDialog(
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
                    'MEMORIA FOTOGRÁFICA',
                    style: TextStyle(
                      color: appWhite,
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
                    'Cada jugador verá un color durante unos segundos. Intenta recordarlo lo mejor posible.',
                  ),

                  _rulesItem(
                    icon: Icons.phone_android_rounded,
                    title: 'Pasa el móvil',
                    text:
                    'Cuando termine el tiempo, pasa el móvil al jugador correspondiente sin enseñar el color.',
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
          backgroundColor: appBlue,
        ),
      );
  }

  void _addSetupPlayer() {
    final name = _playerNameController.text.trim();

    if (name.isEmpty) {
      _showSetupMessage('Escribe el nombre del jugador.');
      return;
    }

    if (_setupPlayerNames.length >= 12) {
      _showSetupMessage('El máximo es de 12 jugadores.');
      return;
    }

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

  Color get _currentSelectedColor => Color.fromARGB(
    255,
    _red.round(),
    _green.round(),
    _blue.round(),
  );

  void _startGame() {
    if (_setupPlayerNames.length < 2) {
      _showSetupMessage('Añade al menos 2 jugadores.');
      return;
    }

    _totalRounds =
        (int.tryParse(_roundsController.text) ?? 5).clamp(1, 20);

    _memorizeSeconds =
        (int.tryParse(_memorizeSecondsController.text) ?? 3).clamp(1, 10);

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
      _phase = ColorDuelPhase.memorize;
    });

    _startMemorizeCountdown();
  }

  void _startMemorizeCountdown() {
    _timer?.cancel();

    timerCallback(Timer timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();

        setState(() {
          _phase = ColorDuelPhase.passPhone;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    }

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      timerCallback,
    );
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
        _phase = ColorDuelPhase.memorize;
      });

      _startMemorizeCountdown();
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

  Widget _stepperCard({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return _glassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: appWhite, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.62),
                    fontSize: 11.5,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, color: appWhite),
          ),
          Text(
            value,
            style: const TextStyle(
              color: appWhite,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, color: appWhite),
          ),
        ],
      ),
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? appWhite.withOpacity(0.14) : appWhite.withOpacity(0.07),
          border: Border(
            left: BorderSide(
              color: selected ? accentPurple : appWhite.withOpacity(0.26),
              width: selected ? 7 : 2,
            ),
            bottom: BorderSide(
              color: appWhite.withOpacity(0.30),
              width: 2,
            ),
            top: BorderSide(
              color: appWhite.withOpacity(0.18),
              width: 1,
            ),
            right: BorderSide(
              color: appWhite.withOpacity(0.18),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: appWhite, size: 28),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.68),
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                color: appWhite,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(
        color: appWhite,
        fontSize: 30,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  Widget _buildSetupPhase() {
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [


          _sectionTitle('Jugadores'),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Añade entre 2 y 12 jugadores.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_setupPlayerNames.length}/12',
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _playerNameController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addSetupPlayer(),
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: _fancyInput('Nombre del jugador'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 54,
                height: 54,
                child: ElevatedButton(
                  onPressed: _addSetupPlayer,
                  style: mainButtonStyle(),
                  child: const Icon(
                    Icons.add_rounded,
                    color: appBlue,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_setupPlayerNames.isEmpty)
            _glassCard(
              child: Text(
                'Todavía no has añadido jugadores.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.62),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Column(
              children: List.generate(_setupPlayerNames.length, (index) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
                  decoration: BoxDecoration(
                    color: appWhite.withOpacity(0.08),
                    border: Border(
                      left: const BorderSide(
                        color: accentPurple,
                        width: 6,
                      ),
                      bottom: BorderSide(
                        color: appWhite.withOpacity(0.26),
                        width: 2,
                      ),
                      top: BorderSide(
                        color: appWhite.withOpacity(0.16),
                      ),
                      right: BorderSide(
                        color: appWhite.withOpacity(0.16),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: appWhite.withOpacity(0.70),
                            width: 1.8,
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: appWhite,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          _setupPlayerNames[index],
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeSetupPlayer(index),
                        tooltip: 'Eliminar jugador',
                        icon: Icon(
                          Icons.close_rounded,
                          color: appWhite.withOpacity(0.78),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

          const SizedBox(height: 18),

          _sectionTitle('Partida'),

          const SizedBox(height: 10),

          _stepperCard(
            title: 'Rondas',
            subtitle: 'Cuántas veces jugaréis',
            value: _roundsController.text,
            icon: Icons.flag_rounded,
            onMinus: () => _changeRounds(-1),
            onPlus: () => _changeRounds(1),
          ),

          const SizedBox(height: 10),

          _stepperCard(
            title: 'Memoria',
            subtitle: 'Segundos para ver el color',
            value: '${_memorizeSecondsController.text}s',
            icon: Icons.timer_rounded,
            onMinus: () => _changeSeconds(-1),
            onPlus: () => _changeSeconds(1),
          ),

          const SizedBox(height: 18),

          _sectionTitle('Modo'),

          const SizedBox(height: 10),

          _modeCard(
            title: 'Mismo color',
            subtitle: 'Todos memorizan el mismo color en cada ronda.',
            icon: Icons.group_work_rounded,
            selected: _gameMode == ColorDuelMode.sameColorForAll,
            onTap: () {
              setState(() {
                _gameMode = ColorDuelMode.sameColorForAll;
              });
            },
          ),

          const SizedBox(height: 10),

          _modeCard(
            title: 'Color distinto',
            subtitle: 'Cada jugador tendrá un color diferente.',
            icon: Icons.auto_awesome_rounded,
            selected: _gameMode == ColorDuelMode.differentColorPerPlayer,
            onTap: () {
              setState(() {
                _gameMode = ColorDuelMode.differentColorPerPlayer;
              });
            },
          ),

          const SizedBox(height: 18),

          _primaryButton(
            text: 'Empezar partida',
            icon: Icons.play_arrow_rounded,
            onPressed: _startGame,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case ColorDuelPhase.setup:
        return _buildSetupPhase();
      case ColorDuelPhase.memorize:
        return _buildMemorizePhase();
      case ColorDuelPhase.passPhone:
        return _buildPassPhonePhase();
      case ColorDuelPhase.pick:
        return _buildPickPhase();
      case ColorDuelPhase.roundResult:
        return _buildRoundResultPhase();
      case ColorDuelPhase.finalResult:
        return _buildFinalResultPhase();
    }
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
              Text(
                'Turno de ${_players[_currentPlayerIndex].name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 25,
                  height: 0.95,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _gameMode == ColorDuelMode.sameColorForAll
                    ? 'Memoriza este color'
                    : 'Memoriza tu color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  color: _targetColor,
                  border: Border.all(
                    color: appWhite.withOpacity(0.75),
                    width: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appWhite.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$_secondsLeft',
                    style: const TextStyle(
                      color: appWhite,
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

  Widget _buildPassPhonePhase() {
    final player = _players[_currentPlayerIndex];

    return Padding(
      key: const ValueKey('passPhone'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: Center(
        child: _glassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  Icons.phone_android_rounded,
                  color: appWhite,
                  size: 39,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'pasa\nel móvil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Turno de ${player.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Que nadie más mire la pantalla',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 22),

              _primaryButton(
                text: 'Estoy listo',
                icon: Icons.visibility_outlined,
                onPressed: _goToPickPhase,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickPhase() {
    final player = _players[_currentPlayerIndex];

    return SingleChildScrollView(
      key: const ValueKey('pick'),
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      child: _glassCard(
        child: Column(
          children: [
            Text(
              'Turno de ${player.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontSize: 25,
                height: 0.95,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Elige el color que más se parezca',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite.withOpacity(0.70),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 130,
              decoration: BoxDecoration(
                color: _currentSelectedColor,
                border: Border.all(
                  color: appWhite.withOpacity(0.75),
                  width: 3,
                ),
              ),
            ),

            const SizedBox(height: 18),

            ColorWheelPicker(
              onColorChanged: (color) {
                setState(() {
                  _red = color.red.toDouble();
                  _green = color.green.toDouble();
                  _blue = color.blue.toDouble();
                });
              },
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: appWhite.withOpacity(0.08),
                border: Border.all(
                  color: appWhite.withOpacity(0.26),
                  width: 1.4,
                ),
              ),
              child: Text(
                'RGB(${_red.round()}, ${_green.round()}, ${_blue.round()})',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _primaryButton(
              text: 'Confirmar color',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _confirmCurrentPlayerColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorBlock({
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: appWhite.withOpacity(0.72),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            height: 74,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: appWhite.withOpacity(0.50),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox({
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.07),
          border: Border.all(
            color: appWhite.withOpacity(0.22),
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: appWhite.withOpacity(0.62),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: appWhite,
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

          if (_gameMode == ColorDuelMode.sameColorForAll) ...[
            _glassCard(
              child: Column(
                children: [
                  Text(
                    'COLOR OBJETIVO',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.72),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 90,
                    decoration: BoxDecoration(
                      color: _targetColor,
                      border: Border.all(
                        color: appWhite.withOpacity(0.65),
                        width: 2.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

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
                        color: appWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _colorBlock(
                          label: 'Objetivo',
                          color: targetForPlayer,
                        ),
                        const SizedBox(width: 12),
                        _colorBlock(
                          label: 'Elegido',
                          color: player.selectedColor ?? Colors.transparent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: appWhite.withOpacity(0.12),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: accuracy / 100,
                        child: Container(
                          color: accentGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'PRECISIÓN: $accuracy%',
                      style: TextStyle(
                        color: appWhite.withOpacity(0.74),
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
                    size: 39,
                    color: appWhite,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'resultado\nfinal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appWhite,
                    fontSize: 38,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.9,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Ganador: ${winner.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.76),
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
                          color: appWhite.withOpacity(0.85),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: appWhite,
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
                          color: appWhite,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    Text(
                      '${player.totalScore} pts',
                      style: TextStyle(
                        color: appWhite.withOpacity(0.78),
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
                  _buildTopBar(compact: compact),

                  SizedBox(height: compact ? 10 : 14),

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
    );
  }
}