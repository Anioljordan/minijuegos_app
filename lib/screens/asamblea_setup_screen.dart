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

  static const int minPlayers = 5;
  static const int maxPlayers = 10;

  final TextEditingController _controller = TextEditingController();
  final List<AsambleaPlayer> _players = [];

  int get playersCount => _players.length;

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
                    color: appWhite.withValues(alpha: 0.76),
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
        icon: Icon(icon, color: appBlue),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tr(text).toUpperCase(),
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: appBlue,
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

    while (
    _players.any(
          (player) =>
      player.name.toLowerCase() == 'jugador $number',
    )
    ) {
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

    final name = typedName.isEmpty
        ? _nextAutomaticPlayerName()
        : typedName;

    final duplicated = _players.any(
          (player) =>
      player.name.toLowerCase() == name.toLowerCase(),
    );

    if (duplicated) {
      _snack('Ese jugador ya está añadido');
      return;
    }

    setState(() {
      _players.add(
        AsambleaPlayer(name: name),
      );

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

  Future<void> _changePlayers(int change) async {
    if (change > 0) {
      // El + del contador siempre añade un nombre automático.
      _controller.clear();
      await _addPlayer();
      return;
    }

    if (_players.isEmpty) return;

    await _removePlayer(_players.length - 1);
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
    if (_players.length < minPlayers ||
        _players.length > maxPlayers) {
      _snack(
        'La Asamblea necesita entre '
            '$minPlayers y $maxPlayers jugadores',
      );
      return;
    }

    final playersWithRoles = _assignRoles(_players);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AsambleaRolesScreen(
          players: playersWithRoles,
        ),
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
          border: Border.all(
            color: CuboColors.whiteA(0.85),
            width: 2.2,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final illustrationSize = compact ? 72.0 : 104.0;

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
                color: appWhite,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 8 : 14),

        Padding(
          padding: EdgeInsets.only(
            right: compact ? 4 : 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CuboIllustration('asamblea', size: illustrationSize),
              SizedBox(height: compact ? 6 : 10),
              CuboSectionTitle(
                'la asamblea',
                alignEnd: true,
                size: titleSize,
                gap: compact ? 8 : 10,
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: CuboDecorations.glass(),
      child: child,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: tr(hint),
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.45),
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: appWhite.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.28), width: 1.4),
      ),
      enabledBorder: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.28), width: 1.4),
      ),
      focusedBorder: CuboInputs.rounded(
        const BorderSide(color: appWhite, width: 2),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      tr(text).toLowerCase(),
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
        decoration: CuboDecorations.glass(radius: CuboRadii.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr(title).toUpperCase(),
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

  Widget _playerTile(
      AsambleaPlayer player,
      int index, {
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
              color: accentGreen.withValues(alpha: 0.16),
              border: Border.all(
                color: accentGreen.withValues(alpha: 0.80),
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
              player.name,
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
            onPressed: () => _removePlayer(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: appWhite.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }
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

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool compact,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final veryNarrow = screenWidth < 350;

    final size = veryNarrow
        ? 34.0
        : compact
        ? 38.0
        : 44.0;

    return Material(
      color: onTap == null
          ? appWhite.withValues(alpha: 0.04)
          : appWhite.withValues(alpha: 0.10),
      shape: const CircleBorder(),
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
                  color: accentGreen.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentGreen.withOpacity(0.75),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: accentGreen,
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
                    letterSpacing: veryNarrow ? 0.1 : 0.4,
                  ),
                ),
              ),

              SizedBox(width: gap),

              _buildCounterButton(
                icon: Icons.remove_rounded,
                onTap: _players.isEmpty
                    ? null
                    : () => _changePlayers(-1),
                compact: compact,
              ),

              SizedBox(
                width: valueWidth,
                child: Text(
                  '$playersCount',
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

              _buildCounterButton(
                icon: Icons.add_rounded,
                onTap: _players.length >= maxPlayers
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

  Widget _buildPlayersEditor({
    required bool compact,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final veryNarrow = screenWidth < 350;
    return buildGlassCard(
      padding: EdgeInsets.all(compact ? 13 : 16),
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
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addPlayer(),
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: inputDecoration(
                    'Nombre opcional',
                  ),
                ),
              ),

              SizedBox(width: veryNarrow ? 6 : 9),

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
                  onPressed: _players.length >= maxPlayers
                      ? null
                      : _addPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    foregroundColor: appWhite,
                    disabledBackgroundColor:
                    appWhite.withOpacity(0.18),
                    disabledForegroundColor:
                    appWhite.withOpacity(0.42),
                    elevation: 0,

                    // Centra correctamente el símbolo +
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.center,

                    shape: const RoundedRectangleBorder(
                      borderRadius: CuboRadii.inputAll,
                    ),
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

          if (_players.isEmpty)
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
                  width: 1.3,
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
                  '$playersCount / $maxPlayers',
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

            ..._players.asMap().entries.map(
                  (entry) => CuboEntrance(
                    key: ObjectKey(entry.value),
                    child: _playerTile(
                      entry.value,
                      entry.key,
                      compact: compact,
                    ),
                  ),
            ),
          ],
        ],
      ),
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
                  buildTopBar(
                    compact: compact,
                  ),

                  SizedBox(
                    height: compact ? 9 : 14,
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildPlayersEditor(
                            compact: compact,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: compact ? 10 : 14,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: compact ? 62 : 72,
                    child: ElevatedButton.icon(
                      onPressed: _startGame,
                      style: CuboButtons.primary(padding: null),
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        size: compact ? 30 : 36,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'EMPEZAR PARTIDA',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: compact ? 14 : 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
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
