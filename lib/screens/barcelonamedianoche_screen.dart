import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/barcelonamedianoche_data.dart';
import '../widgets/cubo_dialog.dart';
import '../widgets/cubo_secret_reveal.dart';
import '../widgets/cubo_setup_widgets.dart';
import '../widgets/cubo_game_widgets.dart';

part 'barcelonamedianoche_dialogs.dart';
part 'barcelonamedianoche_views.dart';

const Color _appBlue = Color(0xFF2F4F9C);
const Color _appWhite = Color(0xFFF7F7F7);
const Color _accentRed = Color(0xFFE63946);
const Color _accentGold = Color(0xFFFFD166);
const Color _accentBlue = Color(0xFF60A5FA);
const Color _accentGreen = Color(0xFF22C55E);
const Color _accentPurple = Color(0xFF8B5CF6);
const int _maxPlayers = 12;

class BarcelonaMedianocheScreen extends StatefulWidget {
  const BarcelonaMedianocheScreen({super.key});

  @override
  State<BarcelonaMedianocheScreen> createState() =>
      _BarcelonaMedianocheScreenState();
}

class _BarcelonaMedianocheScreenState extends State<BarcelonaMedianocheScreen> {
  final BarcelonaMedianocheGame game = BarcelonaMedianocheGame();

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

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

  final TextEditingController namesController = TextEditingController();

  final TextEditingController roomsController = TextEditingController(
    text: BarcelonaMedianocheGame.defaultRooms.join('\n'),
  );

  final TextEditingController weaponsController = TextEditingController(
    text: BarcelonaMedianocheGame.defaultWeapons.join('\n'),
  );

  final TextEditingController bidController = TextEditingController();

  Timer? _refreshTimer;

  /// setState para las extensiones de los otros archivos de la pantalla.
  void _update([VoidCallback? fn]) => setState(fn ?? () {});

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && game.phase == BmPhase.playing) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showInvitationDialog();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    namesController.dispose();
    roomsController.dispose();
    weaponsController.dispose();
    bidController.dispose();
    super.dispose();
  }

  static const EdgeInsets _pillPadding = EdgeInsets.symmetric(horizontal: 16);

  ButtonStyle _mainButtonStyle() {
    return CuboButtons.primary(padding: _pillPadding);
  }

  /// Para [OutlinedButton].
  ButtonStyle _secondaryButtonStyle() {
    return CuboButtons.secondary(padding: _pillPadding);
  }

  /// Cabecera común a todas las fases: logo + normas y el título chill.
  Widget _screenHeader({
    required String title,
    String? subtitle,
    String? illustration,
  }) {
    final compact = _isCompactScreen;
    // Ancho completo aunque el padre alinee al inicio, para que el título
    // chill quede siempre a la derecha.
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CuboGameHeader(onRules: _showRulesDialog),
          SizedBox(height: compact ? 6 : 12),
          CuboGameTitle(
            tr(title).replaceAll('\n', ' ').toLowerCase(),
            side: CuboTitleSide.chill,
            illustration: illustration,
            compact: compact,
          ),
          if (subtitle != null) ...[
            SizedBox(height: compact ? 12 : 14),
            _infoBar(text: subtitle, color: _accentRed),
          ],
        ],
      ),
    );
  }

  /// Marco de las fases a pantalla completa (configuración y reparto).
  Widget _phaseFrame({
    required String key,
    required String title,
    String? illustration,
    required Widget child,
  }) {
    final compact = _isCompactScreen;
    final side = compact ? 13.0 : 18.0;
    return Padding(
      key: ValueKey(key),
      padding: EdgeInsets.fromLTRB(
        side,
        compact ? 11 : 18,
        side,
        compact ? 11 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _screenHeader(title: title, illustration: illustration),
          SizedBox(height: compact ? 10 : 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _infoBar({required String text, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 14, 11),
      decoration: CuboDecorations.glass(radius: CuboRadii.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _accentDot(color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: CuboColors.whiteA(0.80),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Punto de color que sustituye a la antigua barra lateral de acento.
  Widget _accentDot(Color color) {
    return Container(
      width: 9,
      height: 9,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _panel({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: CuboDecorations.glass(),
      child: child,
    );
  }

  Widget _sectionTitle(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr(text).toLowerCase(), style: CuboText.title(size: 28)),
        const SizedBox(height: 8),
        const CuboPillBar(width: 36, height: 5),
      ],
    );
  }

  String _nextAutomaticSetupPlayerName() {
    int number = 1;

    while (game.players.any(
      (player) => player.name.toLowerCase() == 'jugador $number',
    )) {
      number++;
    }

    return 'Jugador $number';
  }

  void _addSetupPlayer() {
    if (game.players.length >= _maxPlayers) {
      _snack('El máximo es de $_maxPlayers jugadores.');
      return;
    }

    final typedName = namesController.text.trim();

    final newName = typedName.isEmpty
        ? _nextAutomaticSetupPlayerName()
        : typedName;

    final duplicated = game.players.any(
      (player) => player.name.toLowerCase() == newName.toLowerCase(),
    );

    if (duplicated) {
      _snack('Ese jugador ya está añadido.');
      return;
    }

    final names = game.players.map((player) => player.name).toList();

    names.add(newName);

    setState(() {
      game.setPlayersFromNames(names);
      namesController.clear();
    });
  }

  void _removeSetupPlayer(int index) {
    final names = game.players.map((player) => player.name).toList();

    if (index < 0 || index >= names.length) return;

    names.removeAt(index);

    setState(() {
      game.setPlayersFromNames(names);
    });
  }

  Widget _buildCurrentPhase() {
    switch (game.phase) {
      case BmPhase.setup:
        return _buildSetupView();
      case BmPhase.reveal:
        return _buildRevealView();
      case BmPhase.playing:
        return _buildGameView();
      case BmPhase.auction:
        return _buildAuctionView();
      case BmPhase.ended:
        return _buildEndView();
    }
  }

  int _setupStep = 0;

  void _goToSetupStep(int step) {
    if (step > _setupStep && !game.canStart) {
      _snack('Se necesitan al menos 4 jugadores.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _setupStep = step);
  }

  static int _lineCount(TextEditingController controller) => controller.text
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .length;

  Widget _buildSetupView() {
    final total = game.players.length;
    final killers = game.killerCount;
    final agents = game.agentCount;
    return _phaseFrame(
      key: 'setup',
      title: 'Barcelona Medianoche',
      illustration: 'bcn_medianoche',
      child: CuboSetupSteps(
        index: _setupStep,
        onStepChanged: _goToSetupStep,
        onStart: _startGame,
        steps: [
          CuboSetupStep(
            title: 'JUGADORES',
            icon: Icons.groups_rounded,
            child: CuboPlayersEditor(
              players: [for (final p in game.players) p.name],
              maxPlayers: _maxPlayers,
              controller: namesController,
              onAdd: _addSetupPlayer,
              onRemove: _removeSetupPlayer,
              emptyHint:
                  'Pulsa + sin escribir para añadir Jugador 1, Jugador 2…',
            ),
          ),
          CuboSetupStep(
            title: 'LA NOCHE',
            icon: Icons.nightlife_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CuboSetupInfoRow(
                  title: 'Asesinos',
                  icon: Icons.local_fire_department_rounded,
                  value: '$killers',
                  accent: _accentRed,
                ),
                const SizedBox(height: 10),
                CuboSetupInfoRow(
                  title: 'Agentes',
                  icon: Icons.local_police_rounded,
                  value: '$agents',
                  accent: _accentBlue,
                ),
                const SizedBox(height: 10),
                CuboSetupInfoRow(
                  title: 'Invitados',
                  icon: Icons.person_rounded,
                  value: '${(total - killers - agents).clamp(0, total)}',
                  accent: _accentGreen,
                ),
                const SizedBox(height: 18),
                CuboSetupOption(
                  title: 'Mis lugares',
                  subtitle: '${_lineCount(roomsController)} ${tr('lugares')}',
                  icon: Icons.place_rounded,
                  selected: false,
                  onTap: () => _showMissionListDialog(editingRooms: true),
                ),
                const SizedBox(height: 10),
                CuboSetupOption(
                  title: 'Mis armas',
                  subtitle: '${_lineCount(weaponsController)} ${tr('armas')}',
                  icon: Icons.hardware_rounded,
                  selected: false,
                  onTap: () => _showMissionListDialog(editingRooms: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealView() {
    final player = game.revealedPlayer;
    final target = game.findPlayerById(player.currentTargetId);
    final compact = _isCompactScreen;
    return _phaseFrame(
      key: 'reveal',
      title: 'reparto secreto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CuboRevealProgress(
            current: game.revealIndex + 1,
            total: game.players.length,
          ),
          SizedBox(height: compact ? 10 : 14),
          Expanded(
            child: CuboSecretReveal(
              revealKey: game.revealIndex,
              playerName: player.name,
              onRevealed: () {
                if (!game.revealRoleVisible) {
                  setState(() => game.revealRoleVisible = true);
                }
              },
              face: CuboSecretFace(
                icon: _roleIcon(player.role),
                color: _roleColor(player.role),
                label: 'TU ROL',
                title: tr(player.role.label),
                description: _roleDescription(player.role),
                extra: player.role == BmRole.asesino
                    ? _missionSummary(player, target)
                    : null,
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          CuboRevealNextButton(
            enabled: game.revealRoleVisible,
            isLast: game.isLastReveal,
            lastLabel: 'EMPEZAR LA NOCHE',
            lastIcon: Icons.nightlife_rounded,
            onTap: () => setState(game.nextReveal),
          ),
        ],
      ),
    );
  }

  /// Misión del asesino en una sola tarjeta de tres líneas, para que quepa
  /// también en móviles pequeños.
  Widget _missionSummary(BmPlayer player, BmPlayer? target) {
    final rows = [
      (Icons.person_pin_rounded, 'Objetivo', target?.name ?? 'Sin objetivo'),
      (Icons.place_rounded, 'Habitación', player.currentRoom ?? '-'),
      (Icons.hardware_rounded, 'Objeto', player.currentWeapon ?? '-'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: CuboColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (icon, label, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Icon(icon, color: _accentRed, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    tr(label).toUpperCase(),
                    style: TextStyle(
                      color: CuboColors.blueInk.withValues(alpha: 0.55),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CuboColors.blueInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// [light] es la variante para usar dentro de la tarjeta blanca.
  Widget _secretInfoTile(String label, String value, {bool light = false}) {
    final fg = light ? CuboColors.blueInk : _appWhite;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
      decoration: light
          ? const BoxDecoration(
              color: CuboColors.blueTint,
              borderRadius: CuboRadii.mdAll,
            )
          : CuboDecorations.glass(radius: CuboRadii.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(label).toUpperCase(),
            style: TextStyle(
              color: fg.withValues(alpha: 0.62),
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(BmRole role) {
    switch (role) {
      case BmRole.asesino:
        return _accentRed;
      case BmRole.agente:
        return _accentBlue;
      case BmRole.invitado:
        return _accentGreen;
    }
  }

  IconData _roleIcon(BmRole role) {
    switch (role) {
      case BmRole.asesino:
        return Icons.local_fire_department_rounded;
      case BmRole.agente:
        return Icons.local_police_rounded;
      case BmRole.invitado:
        return Icons.person_rounded;
    }
  }

  String _roleDescription(BmRole role) {
    switch (role) {
      case BmRole.asesino:
        return 'Cumple tu misión sin testigos. Necesitas a tu objetivo, la habitación indicada y el objeto asignado.';
      case BmRole.agente:
        return 'Observa la velada. Si presencias un crimen o consigues una prueba clara, puedes detener al asesino.';
      case BmRole.invitado:
        return 'Sobrevive, negocia, protege tu fortuna y evita quedar atrapado entre asesinos y agentes.';
    }
  }

  InputDecoration _setupInputDecoration(String hint) {
    return CuboInputs.decoration(hintText: tr(hint));
  }

  bool _applyMissionConfiguration() {
    final roomNames = roomsController.text.split('\n');
    final weaponNames = weaponsController.text.split('\n');

    game.setMissionOptions(roomNames: roomNames, weaponNames: weaponNames);

    if (game.rooms.isEmpty) {
      _snack('Añade al menos una habitación.');
      return false;
    }

    if (game.weapons.isEmpty) {
      _snack('Añade al menos un objeto del crimen.');
      return false;
    }

    return true;
  }

  void _startGame() {
    if (!_applyMissionConfiguration()) return;

    if (!game.canStart) {
      _snack('Se necesitan al menos 4 jugadores.');
      return;
    }

    if (game.hasDuplicateNames) {
      _snack('Usa nombres distintos para evitar confusiones.');
      return;
    }

    setState(game.startGame);
  }

  void _restartSamePlayers() {
    final names = game.players.map((player) => player.name).toList();

    setState(() {
      game.setPlayersFromNames(names);
      game.startGame();
      bidController.clear();
    });
  }

  void _restartDifferentPlayers() {
    setState(() {
      namesController.clear();
      game.setPlayersFromNames([]);
      bidController.clear();
    });
  }

  List<(String, String)> _playerChoices(List<BmPlayer> players) {
    return [for (final player in players) (player.id, player.name)];
  }

  void _submitAuctionBid() {
    final amount = int.tryParse(bidController.text.trim()) ?? 0;
    final message = game.submitSecretBid(amount);

    if (message != 'Puja guardada.') {
      _snack(message);
      return;
    }

    bidController.clear();
    setState(() {});
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _appBlue,
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildCurrentPhase(),
          ),
        ),
      ),
    );
  }
}
