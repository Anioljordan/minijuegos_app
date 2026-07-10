import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'asamblea_roles_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';

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

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentGold = Color(0xFFFFD166);
  static const Color accentGreen = Color(0xFF22C55E);

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

        await showAsambleaRulesDialog(context);
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) {
        return Dialog(
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
                        Icons.account_balance_rounded,
                        color: appWhite,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'la asamblea',
                        style: TextStyle(
                          color: appWhite,
                          fontSize: 34,
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
                Text(
                  'Tienes datos guardados. ¿Qué quieres hacer?',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.76),
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
                      child: Text(
                        'ÚLTIMOS JUGADORES',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
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
                    child: Text(
                      'EMPEZAR DESDE CERO',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
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
        icon: Icon(icon, color: appBlue),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              color: appBlue,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
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
    _snack('Últimos jugadores cargados para nueva partida');
  }

  Future<void> _startFromScratch() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(savedGameKey);

    setState(() {
      _players.clear();
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

  Future<void> _addPlayer() async {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    if (_players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      _snack('Ese nombre ya existe');
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
    _snack('Jugadores de la última partida cargados');
  }

  Future<void> _clearPlayersList() async {
    setState(() {
      _players.clear();
    });

    await _clearLastPlayers();
    if (!mounted) return;
    _snack('Lista vaciada');
  }

  void _startGame() {
    if (_players.length < 5 || _players.length > 10) {
      _snack('La Asamblea necesita entre 5 y 10 jugadores');
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

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: appBlue,
        ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
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

  Widget buildTopBar() {
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
              onTap: () => showAsambleaRulesDialog(context),
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
          child: IntrinsicWidth(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text(
                    'la\nasamblea',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 42,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),

                Positioned(
                  left: -46,
                  right: 35,
                  bottom: 0,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: const BorderSide(
            color: accentGold,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        'Añade entre 5 y 10 jugadores para repartir los roles secretos',
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
        fontSize: 30,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
    );
  }

  Widget _smallStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.07),
          border: Border(
            left: BorderSide(
              color: color,
              width: 5,
            ),
            bottom: BorderSide(
              color: appWhite.withOpacity(0.25),
              width: 2,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: appWhite.withOpacity(0.62),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: appWhite,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerTile(AsambleaPlayer player, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.07),
        border: Border.all(
          color: appWhite.withOpacity(0.22),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _removePlayer(index),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: appWhite,
            ),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              buildTopBar(),
              const SizedBox(height: 14),
              buildInfoBar(),
              const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildGlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle('Jugadores'),
                            const SizedBox(height: 8),
                            Text(
                              'Mínimo 5 · máximo 10',
                              style: TextStyle(
                                color: appWhite.withOpacity(0.68),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    style: const TextStyle(
                                      color: appWhite,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    cursorColor: appWhite,
                                    decoration: inputDecoration('Nombre del jugador'),
                                    onSubmitted: (_) => _addPlayer(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _addPlayer,
                                  style: mainButtonStyle(),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 8,
                                    ),
                                    child: Icon(Icons.add_rounded),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _smallStat(
                                  title: 'Actuales',
                                  value: '${_players.length}',
                                  color: accentGreen,
                                ),
                                const SizedBox(width: 10),
                                _smallStat(
                                  title: 'Rango',
                                  value: '5-10',
                                  color: accentGold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _restoreLastPlayers,
                              style: secondaryButtonStyle(),
                              icon: const Icon(Icons.history_rounded),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Text(
                                  'ÚLTIMOS',
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
                            child: OutlinedButton.icon(
                              onPressed: _clearPlayersList,
                              style: secondaryButtonStyle(),
                              icon: const Icon(Icons.delete_sweep_outlined),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Text(
                                  'VACIAR',
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
                      const SizedBox(height: 14),
                      buildGlassCard(
                        child: _players.isEmpty
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 26),
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
                                  Icons.groups_rounded,
                                  color: appWhite,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'todavía no hay jugadores',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: appWhite.withOpacity(0.72),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            sectionTitle('Lista'),
                            const SizedBox(height: 12),
                            ..._players.asMap().entries.map(
                                  (entry) => _playerTile(
                                entry.value,
                                entry.key,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'EMPEZAR PARTIDA',
                      style: TextStyle(
                        color: appBlue,
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
    );
  }
}
