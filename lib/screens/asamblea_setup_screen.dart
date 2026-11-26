import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_roles_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/cubo_setup_widgets.dart';

enum AsambleaRole { izquierda, derecha, liderOculto }

class AsambleaPlayer {
  final String name;
  AsambleaRole? role;
  bool isAlive;

  AsambleaPlayer({required this.name, this.role, this.isAlive = true});
}

class AsambleaSetupScreen extends StatefulWidget {
  const AsambleaSetupScreen({super.key});

  @override
  State<AsambleaSetupScreen> createState() => _AsambleaSetupScreenState();
}

class _AsambleaSetupScreenState extends State<AsambleaSetupScreen> {
  static const String lastPlayersKey = 'asamblea_last_players';
  static const String savedGameKey = 'asamblea_partida_guardada';

  static const int minPlayers = 5;
  static const int maxPlayers = 10;

  final TextEditingController _controller = TextEditingController();
  final List<AsambleaPlayer> _players = [];

  int get playersCount => _players.length;

  bool _startupDialogShown = false;

  /// Paso visible de la configuración (solo interfaz).
  int _setupStep = 0;

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

        if (!mounted) return;

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

    await showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: CuboDecorations.dialog(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CuboDialogHeader(
                  title: 'la asamblea',
                  icon: Icons.account_balance_rounded,
                ),
                const SizedBox(height: 18),
                Text(
                  'Tienes datos guardados. ¿Qué quieres hacer?',
                  style: TextStyle(
                    color: CuboColors.white.withValues(alpha: 0.76),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                if (hasSavedGame) ...[
                  _dialogButton(
                    text: 'Continuar partida',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () async {
                      Navigator.pop(context);
                      await _continueSavedGame();
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                if (hasLastPlayers) ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _newGameWithLastPlayers();
                    },
                    style: secondaryButtonStyle(),
                    icon: const Icon(Icons.history_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ÚLTIMOS JUGADORES',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _startFromScratch();
                  },
                  style: secondaryButtonStyle(),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'EMPEZAR DESDE CERO',
                        maxLines: 1,
                        softWrap: false,
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
          ),
        );
      },
    );
  }

  Widget _dialogButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: mainButtonStyle(),
        icon: Icon(icon, color: CuboColors.blue),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tr(text).toUpperCase(),
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: CuboColors.blue,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueSavedGame() async {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AsambleaBoardScreen(players: [])),
    );
  }

  Future<void> _newGameWithLastPlayers() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(savedGameKey);
    await _loadLastPlayers();

    if (!mounted) return;
    _snack('Últimos jugadores cargados para nueva partida');
  }

  Future<void> _startFromScratch() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(savedGameKey);

    setState(() {
      _players.clear();
      _controller.clear();
    });

    if (!mounted) return;
    _snack('Empieza una partida nueva desde cero');
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

  String _nextAutomaticPlayerName() {
    int number = 1;

    while (_players.any(
      (player) => player.name.toLowerCase() == 'jugador $number',
    )) {
      number++;
    }

    return 'Jugador $number';
  }

  Future<void> _addPlayer() async {
    if (_players.length >= maxPlayers) {
      _snack('El máximo es de $maxPlayers jugadores');
      return;
    }

    final typedName = _controller.text.trim();

    final name = typedName.isEmpty ? _nextAutomaticPlayerName() : typedName;

    final duplicated = _players.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    );

    if (duplicated) {
      _snack('Ese jugador ya está añadido');
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

  bool _checkPlayersCount() {
    if (_players.length >= minPlayers && _players.length <= maxPlayers) {
      return true;
    }
    _snack(
      'La Asamblea necesita entre '
      '$minPlayers y $maxPlayers jugadores',
    );
    return false;
  }

  void _goToStep(int step) {
    if (step > _setupStep && !_checkPlayersCount()) return;
    FocusScope.of(context).unfocus();
    setState(() => _setupStep = step);
  }

  /// Jugadores de derecha según el total (sin contar al Líder Oculto).
  static int _rightCount(int total) {
    if (total <= 6) return 1;
    if (total <= 8) return 2;
    return 3;
  }

  void _startGame() {
    if (!_checkPlayersCount()) return;

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
    final players =
        originalPlayers.map((p) => AsambleaPlayer(name: p.name)).toList()
          ..shuffle(random);

    final numDerecha = _rightCount(players.length);

    players[0].role = AsambleaRole.liderOculto;

    for (int i = 1; i <= numDerecha; i++) {
      players[i].role = AsambleaRole.derecha;
    }

    for (int i = numDerecha + 1; i < players.length; i++) {
      players[i].role = AsambleaRole.izquierda;
    }

    return players;
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CuboColors.blue,
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: null);
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CuboColors.whiteA(0.08),
          border: Border.all(color: CuboColors.whiteA(0.85), width: 2.2),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {

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
            circleButton(
              compact: compact,
              onTap: () => showAsambleaRulesDialog(context),
              child: Icon(
                Icons.question_mark_rounded,
                color: CuboColors.white,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 8 : 14),

        CuboGameTitle(
          'la asamblea',
          side: CuboTitleSide.chill,
          illustration: 'asamblea',
          compact: compact,
        ),
      ],
    );
  }

  Widget _buildSetupSteps() {
    final total = _players.length;
    final right = _rightCount(total);
    return CuboSetupSteps(
      index: _setupStep,
      onStepChanged: _goToStep,
      onStart: _startGame,
      steps: [
        CuboSetupStep(
          title: 'JUGADORES',
          icon: Icons.groups_rounded,
          child: CuboPlayersEditor(
            players: [for (final p in _players) p.name],
            maxPlayers: maxPlayers,
            controller: _controller,
            onAdd: _addPlayer,
            onRemove: _removePlayer,
            emptyHint: 'Pulsa + sin escribir para añadir Jugador 1, Jugador 2…',
          ),
        ),
        CuboSetupStep(
          title: 'CONFIGURACIÓN',
          icon: Icons.how_to_vote_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CuboSetupInfoRow(
                title: 'Líder Oculto',
                icon: Icons.visibility_off_rounded,
                value: '1',
              ),
              const SizedBox(height: 12),
              CuboSetupInfoRow(
                title: 'Derecha',
                icon: Icons.gavel_rounded,
                value: '$right',
              ),
              const SizedBox(height: 12),
              CuboSetupInfoRow(
                title: 'Izquierda',
                icon: Icons.shield_rounded,
                value: '${total - right - 1}',
              ),
            ],
          ),
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

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  compact ? 11 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),

                    SizedBox(height: compact ? 9 : 14),

                    Expanded(child: _buildSetupSteps()),
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
