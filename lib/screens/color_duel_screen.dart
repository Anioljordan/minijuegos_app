import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/color_wheel_picker.dart';

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

  ColorDuelPhase _phase = ColorDuelPhase.setup;

  final TextEditingController _playersCountController =
  TextEditingController(text: '2');
  final TextEditingController _roundsController =
  TextEditingController(text: '5');
  final TextEditingController _memorizeSecondsController =
  TextEditingController(text: '3');

  List<TextEditingController> _nameControllers = [
    TextEditingController(text: 'Jugador 1'),
    TextEditingController(text: 'Jugador 2'),
  ];

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
  void dispose() {
    _timer?.cancel();
    _playersCountController.dispose();
    _roundsController.dispose();
    _memorizeSecondsController.dispose();

    for (final controller in _nameControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _updatePlayerControllers() {
    final count = int.tryParse(_playersCountController.text) ?? 2;
    final safeCount = count.clamp(1, 12);

    if (_nameControllers.length < safeCount) {
      for (int i = _nameControllers.length; i < safeCount; i++) {
        _nameControllers.add(
          TextEditingController(text: 'Jugador ${i + 1}'),
        );
      }
    } else if (_nameControllers.length > safeCount) {
      final extra = _nameControllers.sublist(safeCount);

      for (final controller in extra) {
        controller.dispose();
      }

      _nameControllers = _nameControllers.sublist(0, safeCount);
    }

    setState(() {});
  }

  void _changePlayersCount(int delta) {
    final current = int.tryParse(_playersCountController.text) ?? 2;
    final next = (current + delta).clamp(1, 12);

    _playersCountController.text = next.toString();
    _updatePlayerControllers();
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
    final count =
    (int.tryParse(_playersCountController.text) ?? 2).clamp(1, 12);

    _totalRounds =
        (int.tryParse(_roundsController.text) ?? 5).clamp(1, 20);

    _memorizeSeconds =
        (int.tryParse(_memorizeSecondsController.text) ?? 3).clamp(1, 10);

    _players = List.generate(count, (index) {
      final name = _nameControllers[index].text.trim().isEmpty
          ? 'Jugador ${index + 1}'
          : _nameControllers[index].text.trim();

      return ColorDuelPlayer(name: name);
    });

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

  Widget _glassCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(18),
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(0.085),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
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
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF2563EB),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.38),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fancyInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.68)),
      filled: true,
      fillColor: const Color(0xFF0F172A).withOpacity(0.75),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: Color(0xFF60A5FA), width: 1.4),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Memoria Fotográfica',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                if (_phase != ColorDuelPhase.setup)
                  Text(
                    'Ronda $_currentRound de $_totalRounds',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: const Icon(
              Icons.palette_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF7C3AED),
                  Color(0xFF2563EB),
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.62),
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: selected
              ? const Color(0xFF2563EB).withOpacity(0.30)
              : Colors.white.withOpacity(0.07),
          border: Border.all(
            color: selected
                ? const Color(0xFF60A5FA)
                : Colors.white.withOpacity(0.10),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.11),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.68),
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF60A5FA),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniInfoCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPhase() {
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _glassCard(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF2563EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.remove_red_eye_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Memoriza el color',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cada jugador verá un color durante unos segundos. Luego tendrá que recrearlo con la ruleta de colores.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _miniInfoCard(
                      icon: Icons.visibility_rounded,
                      title: 'Mira',
                      text: 'Memoriza rápido',
                    ),
                    const SizedBox(width: 10),
                    _miniInfoCard(
                      icon: Icons.palette_rounded,
                      title: 'Copia',
                      text: 'Elige el color',
                    ),
                    const SizedBox(width: 10),
                    _miniInfoCard(
                      icon: Icons.emoji_events_rounded,
                      title: 'Gana',
                      text: 'Más precisión',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _stepperCard(
            title: 'Jugadores',
            subtitle: 'Personas que jugarán',
            value: _playersCountController.text,
            icon: Icons.groups_rounded,
            onMinus: () => _changePlayersCount(-1),
            onPlus: () => _changePlayersCount(1),
          ),

          const SizedBox(height: 12),

          _stepperCard(
            title: 'Rondas',
            subtitle: 'Cuántas veces jugaréis',
            value: _roundsController.text,
            icon: Icons.flag_rounded,
            onMinus: () => _changeRounds(-1),
            onPlus: () => _changeRounds(1),
          ),

          const SizedBox(height: 12),

          _stepperCard(
            title: 'Memoria',
            subtitle: 'Segundos para ver el color',
            value: '${_memorizeSecondsController.text}s',
            icon: Icons.timer_rounded,
            onMinus: () => _changeSeconds(-1),
            onPlus: () => _changeSeconds(1),
          ),

          const SizedBox(height: 20),

          const Text(
            'Modo de juego',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

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

          const SizedBox(height: 12),

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

          const SizedBox(height: 20),

          const Text(
            'Nombres',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          _glassCard(
            child: Column(
              children: List.generate(_nameControllers.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _nameControllers.length - 1 ? 0 : 12,
                  ),
                  child: TextField(
                    controller: _nameControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: _fancyInput('Jugador ${index + 1}'),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

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
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _glassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Turno de ${_players[_currentPlayerIndex].name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _gameMode == ColorDuelMode.sameColorForAll
                    ? 'Memoriza este color'
                    : 'Memoriza tu color',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: _targetColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _targetColor.withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Center(
                  child: Text(
                    '$_secondsLeft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
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
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _glassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Pasa el móvil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Turno de ${player.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Que nadie más mire la pantalla',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _glassCard(
            child: Column(
              children: [
                Text(
                  'Turno de ${player.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Elige el color que más se parezca',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _currentSelectedColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.20),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _currentSelectedColor.withOpacity(0.45),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ColorWheelPicker(
                  onColorChanged: (color) {
                    setState(() {
                      _red = color.red.toDouble();
                      _green = color.green.toDouble();
                      _blue = color.blue.toDouble();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.06),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Text(
                    'RGB(${_red.round()}, ${_green.round()}, ${_blue.round()})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _primaryButton(
                  text: 'Confirmar color',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _confirmCurrentPlayerColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundResultPhase() {
    final roundRanking = _sortedPlayersByRound();

    return SingleChildScrollView(
      key: const ValueKey('roundResult'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Resultado de la ronda',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          if (_gameMode == ColorDuelMode.sameColorForAll) ...[
            _glassCard(
              child: Column(
                children: [
                  Text(
                    'Color objetivo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.72),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 180,
                    height: 110,
                    decoration: BoxDecoration(
                      color: _targetColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.20),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _targetColor.withOpacity(0.45),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
              padding: const EdgeInsets.only(bottom: 14),
              child: _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Objetivo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 82,
                                decoration: BoxDecoration(
                                  color: targetForPlayer,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Elegido',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 82,
                                decoration: BoxDecoration(
                                  color:
                                  player.selectedColor ?? Colors.transparent,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withOpacity(0.08),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: accuracy / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF22C55E),
                                Color(0xFF3B82F6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Precisión: $accuracy%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.06),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Ronda',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.65),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '+${player.lastRoundScore}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white.withOpacity(0.06),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.65),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${player.totalScore}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
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
            );
          }),
          const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _glassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 74,
                  color: Colors.amber,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Resultado final',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ganador: ${winner.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...finalRanking.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;

            final medalColor = index == 0
                ? Colors.amber
                : index == 1
                ? Colors.blueGrey.shade200
                : const Color(0xFFCD7F32);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _glassCard(
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: medalColor.withOpacity(0.18),
                        border: Border.all(color: medalColor.withOpacity(0.5)),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: medalColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.06),
                      ),
                      child: Text(
                        '${player.totalScore} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
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
      backgroundColor: const Color(0xFF070B1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1023),
              Color(0xFF11162C),
              Color(0xFF1B1140),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentPhase(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}