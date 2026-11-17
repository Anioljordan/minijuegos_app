import 'dart:async';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import '../data/barcelonamedianoche_data.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class BarcelonaMedianocheScreen extends StatefulWidget {
  const BarcelonaMedianocheScreen({super.key});

  @override
  State<BarcelonaMedianocheScreen> createState() =>
      _BarcelonaMedianocheScreenState();
}

class _BarcelonaMedianocheScreenState
    extends State<BarcelonaMedianocheScreen> {
  final BarcelonaMedianocheGame game = BarcelonaMedianocheGame();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentGold = Color(0xFFFFD166);
  static const Color accentBlue = Color(0xFF60A5FA);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentPurple = Color(0xFF8B5CF6);

  static const int minPlayers = 4;
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

  final TextEditingController namesController = TextEditingController();

  final TextEditingController roomsController = TextEditingController(
    text: BarcelonaMedianocheGame.defaultRooms.join('\n'),
  );

  final TextEditingController weaponsController = TextEditingController(
    text: BarcelonaMedianocheGame.defaultWeapons.join('\n'),
  );

  final TextEditingController bidController = TextEditingController();

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) {
        if (mounted && game.phase == BmPhase.playing) {
          setState(() {});
        }
      },
    );

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

  ButtonStyle _dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentRed,
      foregroundColor: appWhite,
      disabledBackgroundColor: CuboColors.whiteA(0.16),
      disabledForegroundColor: CuboColors.whiteA(0.45),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: _pillPadding,
      shape: const StadiumBorder(),
    );
  }

  /// Para [OutlinedButton].
  ButtonStyle _secondaryButtonStyle() {
    return CuboButtons.secondary(padding: _pillPadding);
  }

  /// Mismo aspecto que [_secondaryButtonStyle] pero para [ElevatedButton].
  ButtonStyle _secondaryElevatedStyle() {
    return CuboButtons.secondaryElevated(padding: _pillPadding);
  }

  Widget _circleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    final compact = _isCompactScreen;
    final size = compact ? 44.0 : 50.0;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
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
      ),
    );
  }

  Widget _screenHeader({
    required String title,
    String? subtitle,
    VoidCallback? extraAction,
    IconData? extraIcon,
    VoidCallback? onBack,
    bool showIllustration = false,
    bool illustrationPopIn = false,
  }) {
    final compact = _isCompactScreen;

    final titleSize = compact ? 34.0 : 42.0;
    final shortScreen = MediaQuery.sizeOf(context).height < 740;

    // Convierte los títulos de dos líneas en una sola línea,
    // igual que en Impostor.
    final visualTitle = tr(title).replaceAll('\n', ' ').toLowerCase();

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
                if (extraAction != null && extraIcon != null) ...[
                  _circleButton(
                    onTap: extraAction,
                    child: Icon(
                      extraIcon,
                      color: appWhite,
                      size: compact ? 23 : 27,
                    ),
                  ),
                  SizedBox(width: compact ? 9 : 12),
                ],
                _circleButton(
                  onTap: _showRulesDialog,
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

        SizedBox(height: compact ? 14 : 22),

        if (showIllustration) ...[
          Align(
            alignment: Alignment.centerRight,
            child: CuboIllustration(
              'bcn_medianoche',
              size: shortScreen ? 88 : 116,
              popIn: illustrationPopIn,
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
        ],

        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  visualTitle,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.right,
                  style: CuboText.title(size: titleSize),
                ),
              ),
              SizedBox(height: compact ? 10 : 12),
              const CuboPillBar(),
            ],
          ),
        ),

        if (subtitle != null) ...[
          SizedBox(height: compact ? 12 : 14),
          _infoBar(
            text: subtitle,
            color: accentRed,
          ),
        ],
      ],
    );
  }

  Widget _infoBar({
    required String text,
    required Color color,
  }) {
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

  Widget _panel({
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

  Widget _sectionTitle(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(text).toLowerCase(),
          style: CuboText.title(size: 28),
        ),
        const SizedBox(height: 8),
        const CuboPillBar(width: 36, height: 5),
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
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),
                  const SizedBox(height: 18),
                  Text(
                    'BARCELONA, MEDIANOCHE',
                    style: CuboText.chip(size: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Una subasta privada, una fortuna familiar y varios invitados dispuestos a ensuciarse las manos. Todos empiezan con 100€ y solo los supervivientes pueden quedarse con la herencia.',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.78),
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _rulesItem(
                    icon: Icons.visibility_off_rounded,
                    title: 'Identidades secretas',
                    text:
                    'Cada jugador es Asesino, Agente o Invitado. Nadie debe enseñar su identidad.',
                  ),
                  _rulesItem(
                    icon: Icons.tune_rounded,
                    title: 'Escenario personalizado',
                    text:
                    'Antes de empezar podéis editar las habitaciones y los objetos del crimen. Escribe una opción por línea.',
                  ),
                  _rulesItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Misión del asesino',
                    text:
                    'Cada asesino recibe un objetivo, una habitación y un objeto. Para matar deben cumplirse las tres condiciones.',
                  ),
                  _rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Sin testigos',
                    text:
                    'No se puede asesinar si hay otro jugador vivo presente. Cuando una misión se cumple, el asesino recibe una nueva.',
                  ),
                  _rulesItem(
                    icon: Icons.payments_rounded,
                    title: 'Cuando alguien muere',
                    text:
                    'La víctima entrega todo su dinero al atacante. Queda eliminada: puede hablar y negociar, pero ya no actúa, puja ni puede ganar.',
                  ),
                  _rulesItem(
                    icon: Icons.local_police_rounded,
                    title: 'Agentes',
                    text:
                    'Un agente puede declarar una detención si ha presenciado el crimen o tiene una prueba clara.',
                  ),
                  _rulesItem(
                    icon: Icons.timer_rounded,
                    title: 'Detención correcta',
                    text:
                    'El asesino paga hasta 40€ al agente y no puede cometer asesinatos durante 10 minutos. Sí puede hablar, negociar y pujar.',
                  ),
                  _rulesItem(
                    icon: Icons.warning_amber_rounded,
                    title: 'Acusación falsa',
                    text:
                    'Si no había prueba clara o el acusado era inocente, el agente paga hasta 40€ al acusado.',
                  ),
                  _rulesItem(
                    icon: Icons.handshake_rounded,
                    title: 'Tratos y robos',
                    text:
                    'Se permiten alianzas, intercambios y robos acordados por la mesa. Registra en la app cualquier cambio de dinero o bienes.',
                  ),
                  _rulesItem(
                    icon: Icons.diamond_rounded,
                    title: 'Subasta final',
                    text:
                    'Al terminar la noche se subastan 5 lotes. Las pujas son secretas y solo participan los jugadores vivos.',
                  ),
                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Quién gana',
                    text:
                    'Gana el superviviente con mayor fortuna total: dinero restante + valor de los bienes adquiridos.',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: CuboButtons.primary(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
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


  Future<void> _showInvitationDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.62),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dialogTitle(
                icon: Icons.mail_outline_rounded,
                title: 'la invitación',
              ),
              const SizedBox(height: 18),
              Text(
                'Habéis sido convocados a una subasta privada. Algunos han venido por dinero. Otros por venganza. Y entre vosotros hay asesinos y agentes encubiertos.',
                style: TextStyle(
                  color: appWhite.withOpacity(0.82),
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: _mainButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'ACEPTAR INVITACIÓN',
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
      ),
    );
  }

  Future<void> _showMissionListDialog({
    required bool editingRooms,
  }) async {
    final title = editingRooms ? 'mis lugares' : 'mis armas';
    final label = editingRooms ? 'LUGARES DISPONIBLES' : 'OBJETOS DEL CRIMEN';
    final hint = editingRooms
        ? 'Biblioteca\nSalón\nJardín\nBodega'
        : 'Copa\nAbrecartas\nCandelabro\nBufanda';
    final defaults = editingRooms
        ? BarcelonaMedianocheGame.defaultRooms
        : BarcelonaMedianocheGame.defaultWeapons;
    final sourceController =
    editingRooms ? roomsController : weaponsController;
    final editorController = TextEditingController(
      text: sourceController.text,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.58),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: CuboDecorations.dialog(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _dialogTitle(
                  icon: editingRooms
                      ? Icons.place_rounded
                      : Icons.hardware_rounded,
                  title: title,
                ),
                const SizedBox(height: 12),
                Text(
                  'Escribe una opción por línea. Estas opciones se usarán en las misiones de los asesinos.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.72),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: editorController,
                  minLines: 6,
                  maxLines: 12,
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: _setupInputDecoration(hint),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    editorController.text = defaults.join('\n');
                  },
                  style: _secondaryButtonStyle(),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'RESTAURAR ORIGINALES',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    final cleaned = editorController.text
                        .split('\n')
                        .map((item) => item.trim())
                        .where((item) => item.isNotEmpty)
                        .toList();

                    if (cleaned.isEmpty) {
                      _snack(
                        editingRooms
                            ? 'Añade al menos un lugar.'
                            : 'Añade al menos un objeto del crimen.',
                      );
                      return;
                    }

                    setState(() {
                      sourceController.text = cleaned.join('\n');
                      game.setMissionOptions(
                        roomNames: roomsController.text.split('\n'),
                        weaponNames: weaponsController.text.split('\n'),
                      );
                    });

                    Navigator.pop(dialogContext);
                    _snack(
                      editingRooms
                          ? 'Lugares guardados.'
                          : 'Armas guardadas.',
                    );
                  },
                  style: _mainButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'GUARDAR',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'CANCELAR',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.72),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    editorController.dispose();
  }

  String _nextAutomaticSetupPlayerName() {
    int number = 1;

    while (
    game.players.any(
          (player) =>
      player.name.toLowerCase() == 'jugador $number',
    )
    ) {
      number++;
    }

    return 'Jugador $number';
  }

  void _addSetupPlayer() {
    if (game.players.length >= maxPlayers) {
      _snack('El máximo es de $maxPlayers jugadores.');
      return;
    }

    final typedName = namesController.text.trim();

    final newName = typedName.isEmpty
        ? _nextAutomaticSetupPlayerName()
        : typedName;

    final duplicated = game.players.any(
          (player) =>
      player.name.toLowerCase() == newName.toLowerCase(),
    );

    if (duplicated) {
      _snack('Ese jugador ya está añadido.');
      return;
    }

    final names = game.players
        .map((player) => player.name)
        .toList();

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

  void _changeSetupPlayers(int change) {
    if (change > 0) {
      namesController.clear();
      _addSetupPlayer();
      return;
    }

    if (game.players.isEmpty) return;

    _removeSetupPlayer(
      game.players.length - 1,
    );
  }

  Widget _setupPlayerTile(
      BmPlayer player,
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
              color: accentGold.withValues(alpha: 0.16),
              border: Border.all(
                color: accentGold.withValues(alpha: 0.80),
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
            onPressed: () => _removeSetupPlayer(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: appWhite.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupCounterButton({
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
        side: BorderSide(color: CuboColors.whiteA(onTap == null ? 0.12 : 0.30)),
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

  Widget _buildSetupPlayersEditor({
    required bool compact,
  }) {
    final playerCount = game.players.length;
    final veryNarrow = _isVeryNarrowScreen;

    return _panel(
      padding: EdgeInsets.all(compact ? 13 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSetupPlayersCounter(
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
                  controller: namesController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addSetupPlayer(),
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w800,
                  ),
                  cursorColor: appWhite,
                  decoration: _setupInputDecoration(
                    'Nombre opcional',
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
                  onPressed: playerCount >= maxPlayers
                      ? null
                      : _addSetupPlayer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
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
                    shape: const RoundedRectangleBorder(
                      borderRadius: CuboRadii.mdAll,
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

          if (game.players.isEmpty)
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
                  '$playerCount / $maxPlayers',
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

            ...game.players.asMap().entries.map(
                  (entry) => _setupPlayerTile(
                entry.value,
                entry.key,
                compact: compact,
              ),
            ),
          ],
        ],
      ),
    );
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

  Widget _buildSetupView() {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    final playerCount = game.players.length;

    final missingPlayers =
    (minPlayers - playerCount)
        .clamp(0, minPlayers);

    return SingleChildScrollView(
      key: const ValueKey('setup'),
      keyboardDismissBehavior:
      ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        veryNarrow
            ? 8
            : compact
            ? 12
            : 18,
        compact ? 10 : 18,
        veryNarrow
            ? 8
            : compact
            ? 12
            : 18,
        compact ? 18 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _screenHeader(
            title: 'barcelona\nmedianoche',
            showIllustration: true,
          ),

          SizedBox(height: compact ? 14 : 20),

          CuboEntrance(
            index: 0,
            child: _panel(
            padding: EdgeInsets.all(compact ? 13 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  'personaliza la noche',
                ),

                const SizedBox(height: 10),

                Text(
                  'Puedes usar el escenario original o añadir tus propios lugares y objetos del crimen.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.68),
                    fontSize: compact ? 11.5 : 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: compact ? 12 : 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showMissionListDialog(
                              editingRooms: true,
                            ),
                        style: _secondaryButtonStyle(),
                        icon: const Icon(
                          Icons.place_rounded,
                        ),
                        label: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 11 : 13,
                          ),
                          child: _singleLineResponsiveText(
                            'MIS LUGARES',
                            alignment: Alignment.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: compact ? 10.5 : 11.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: veryNarrow ? 6 : 10,
                    ),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showMissionListDialog(
                              editingRooms: false,
                            ),
                        style: _secondaryButtonStyle(),
                        icon: const Icon(
                          Icons.hardware_rounded,
                        ),
                        label: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: compact ? 11 : 13,
                          ),
                          child: _singleLineResponsiveText(
                            'MIS ARMAS',
                            alignment: Alignment.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: compact ? 10.5 : 11.5,
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
          ),

          SizedBox(height: compact ? 10 : 14),

          CuboEntrance(
            index: 1,
            child: _buildSetupPlayersEditor(
              compact: compact,
            ),
          ),

          SizedBox(height: compact ? 12 : 16),

          SizedBox(
            width: double.infinity,
            height: compact ? 58 : 64,
            child: ElevatedButton(
              onPressed: game.canStart
                  ? _startGame
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: appWhite,
                foregroundColor: appBlue,
                disabledBackgroundColor: CuboColors.whiteA(0.16),
                disabledForegroundColor: CuboColors.whiteA(0.45),
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.symmetric(
                  horizontal: veryNarrow ? 14 : 20,
                ),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_off_rounded,
                    size: compact ? 20 : 23,
                  ),

                  SizedBox(
                    width: veryNarrow ? 6 : 9,
                  ),

                  Expanded(
                    child: _singleLineResponsiveText(
                      game.canStart
                          ? 'COMENZAR REPARTO SECRETO'
                          : 'FALTAN $missingPlayers JUGADORES',
                      alignment: Alignment.center,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupPlayersCounter({
    required bool compact,
  }) {
    final playerCount = game.players.length;

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
                  color: accentGold.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentGold.withOpacity(0.75),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: accentGold,
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

              _buildSetupCounterButton(
                icon: Icons.remove_rounded,
                onTap: game.players.isEmpty
                    ? null
                    : () => _changeSetupPlayers(-1),
                compact: compact,
              ),

              SizedBox(
                width: valueWidth,
                child: Text(
                  '$playerCount',
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

              _buildSetupCounterButton(
                icon: Icons.add_rounded,
                onTap: playerCount >= maxPlayers
                    ? null
                    : () => _changeSetupPlayers(1),
                compact: compact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRevealView() {
    final player = game.revealedPlayer;
    final target = game.findPlayerById(player.currentTargetId);
    final compact = _isCompactScreen;
    final roleColor = _roleColor(player.role);

    return SingleChildScrollView(
      key: const ValueKey('reveal'),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 18 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _screenHeader(
            title: 'reparto\nsecreto',

          ),
          SizedBox(height: compact ? 12 : 18),
          Row(
            children: [
              Text(
                'REPARTO DE ROLES',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: compact ? 10.5 : 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${game.revealIndex + 1}/${game.players.length}',
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: CuboProgressDots(
              total: game.players.length,
              current: game.revealIndex,
            ),
          ),
          SizedBox(height: compact ? 14 : 20),
          CuboCardSwitcher(
            child: CuboHeroCard(
              key: ValueKey('reveal_${player.id}_${game.revealRoleVisible}'),
              chip: game.revealRoleVisible
                  ? player.name
                  : '${game.revealIndex + 1}/${game.players.length}',
              chipIcon: Icons.person_rounded,
              padding: EdgeInsets.fromLTRB(
                compact ? 18 : 22,
                compact ? 16 : 20,
                compact ? 18 : 22,
                compact ? 22 : 30,
              ),
              child: game.revealRoleVisible
                  ? Column(
                key: const ValueKey('visible'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 74 : 88,
                    height: compact ? 74 : 88,
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                      boxShadow: CuboShadows.soft,
                    ),
                    child: Icon(
                      _roleIcon(player.role),
                      color: appWhite,
                      size: compact ? 38 : 46,
                    ),
                  ),
                  SizedBox(height: compact ? 14 : 18),
                  Text(
                    tr(player.role.label).toLowerCase(),
                    textAlign: TextAlign.center,
                    style: CuboText.title(
                      size: compact ? 34 : 42,
                      color: CuboColors.blueInk,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),
                  Text(
                    _roleDescription(player.role),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CuboColors.blueInk.withValues(alpha: 0.78),
                      fontSize: compact ? 13 : 14.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (player.role == BmRole.asesino) ...[
                    SizedBox(height: compact ? 14 : 18),
                    _secretInfoTile(
                      'Objetivo',
                      target?.name ?? 'Sin objetivo',
                      light: true,
                    ),
                    _secretInfoTile(
                      'Habitación',
                      player.currentRoom ?? '-',
                      light: true,
                    ),
                    _secretInfoTile(
                      'Objeto',
                      player.currentWeapon ?? '-',
                      light: true,
                    ),
                  ],
                ],
              )
                  : Column(
                key: const ValueKey('hidden'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: compact ? 72 : 84,
                    height: compact ? 72 : 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CuboColors.blueTint,
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: CuboColors.blue,
                      size: compact ? 36 : 42,
                    ),
                  ),
                  SizedBox(height: compact ? 16 : 20),
                  Text(
                    player.name.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: CuboText.title(
                      size: compact ? 36 : 44,
                      color: CuboColors.blueInk,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 16),
                  Text(
                    'Coge el móvil y toca la tarjeta para descubrir tu identidad.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CuboColors.blueInk.withValues(alpha: 0.72),
                      fontSize: compact ? 13 : 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: compact ? 18 : 24),
                  Material(
                    color: CuboColors.blue,
                    shape: const StadiumBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          game.revealRoleVisible = true;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 18 : 24,
                          vertical: compact ? 12 : 14,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              color: appWhite,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'REVELAR IDENTIDAD',
                              style: TextStyle(
                                color: appWhite,

                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: compact ? 10 : 14),
          if (game.revealRoleVisible)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(game.nextReveal),
                style: _mainButtonStyle(),
                icon: Icon(
                  game.isLastReveal
                      ? Icons.nightlife_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: compact ? 12 : 14,
                  ),
                  child: Text(
                    game.isLastReveal
                        ? 'EMPEZAR LA NOCHE'
                        : 'SIGUIENTE JUGADOR',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    final compact = _isCompactScreen;

    return SingleChildScrollView(
      key: const ValueKey('playing'),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'barcelona\nmedianoche',

          ),
          SizedBox(height: compact ? 12 : 18),
          _sectionTitle('estado de la noche'),
          const SizedBox(height: 10),
          ...game.players.map(_playerCard),
          SizedBox(height: compact ? 14 : 18),
          _sectionTitle('acciones'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  title: 'Asesinato',
                  subtitle: 'Confirma una misión en secreto.',
                  icon: Icons.local_fire_department_rounded,
                  color: accentRed,
                  onTap: _showKillDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  title: 'Detención',
                  subtitle: 'Un agente acusa con pruebas.',
                  icon: Icons.local_police_rounded,
                  color: accentBlue,
                  onTap: _showArrestDialog,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  title: 'Trato o robo',
                  subtitle: 'Mueve dinero o bienes.',
                  icon: Icons.handshake_rounded,
                  color: accentPurple,
                  onTap: _showTransferDialog,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  title: 'Subasta final',
                  subtitle: 'Comienza las pujas secretas.',
                  icon: Icons.diamond_rounded,
                  color: accentGold,
                  onTap: _confirmStartFinalAuction,
                  darkForeground: true,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 16 : 20),
          _sectionTitle('registro público'),
          const SizedBox(height: 10),
          _panel(
            child: game.log.isEmpty
                ? Text(
              'Todavía no ha ocurrido nada.',
              style: TextStyle(
                color: appWhite.withOpacity(0.70),
              ),
            )
                : Column(
              children: game.log
                  .take(14)
                  .map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle_rounded,
                          size: 8,
                          color: accentRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry,
                          style: TextStyle(
                            color: appWhite.withOpacity(0.84),
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuctionView() {
    final compact = _isCompactScreen;
    final lot = game.currentAuctionLot;
    final bidder = game.currentBidder;

    return SingleChildScrollView(
      key: ValueKey(
        'auction_${game.currentLotIndex}_${game.currentBidderIndex}_${game.auctionRoundResolved}',
      ),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'subasta\nfinal',
            subtitle: lot == null
                ? 'La subasta ha terminado.'
                : 'Lote ${game.currentLotIndex + 1} de ${game.finalAuctionLots.length} · las pujas son secretas.',
          ),
          const SizedBox(height: 18),
          if (lot != null)
            CuboCardSwitcher(
              child: CuboHeroCard(
                key: ValueKey('lot_${game.currentLotIndex}'),
                chip:
                    '${game.currentLotIndex + 1}/${game.finalAuctionLots.length}',
                chipIcon: Icons.diamond_rounded,
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentGold.withValues(alpha: 0.22),
                        border: Border.all(
                          color: accentGold,
                          width: 2.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.diamond_rounded,
                        color: CuboColors.blueInk,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr(lot.name).toLowerCase(),
                      textAlign: TextAlign.center,
                      style: CuboText.title(
                        size: 32,
                        color: CuboColors.blueInk,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Valor real: ${lot.value}€',
                      style: CuboText.label(size: 16),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          if (!game.auctionRoundResolved && bidder != null)
            _panel(
              child: Column(
                children: [
                  const Icon(
                    Icons.phone_android_rounded,
                    color: appWhite,
                    size: 34,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'pasa el móvil a\n${bidder.name.toLowerCase()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 30,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Disponible: ${bidder.money}€',
                    style: TextStyle(
                      color: appWhite.withOpacity(0.68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bidController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    style: const TextStyle(
                      color: appWhite,
                      fontWeight: FontWeight.w900,
                    ),
                    cursorColor: appWhite,
                    decoration: CuboInputs.decoration(
                      hintText: tr('0 = no pujar'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitAuctionBid,
                      style: _mainButtonStyle(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'GUARDAR PUJA Y OCULTAR',
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
          if (game.auctionRoundResolved)
            _panel(
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: accentGold,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.lastAuctionResult,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 21,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        bidController.clear();
                        setState(game.nextAuctionLotOrFinish);
                      },
                      style: _mainButtonStyle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          game.isLastAuctionLot
                              ? 'VER RESULTADO FINAL'
                              : 'SIGUIENTE LOTE',
                          style: const TextStyle(
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
      ),
    );
  }

  Widget _buildEndView() {
    final compact = _isCompactScreen;
    final ranking = game.ranking;
    final winner = ranking.isNotEmpty ? ranking.first : null;

    return SingleChildScrollView(
      key: const ValueKey('ended'),
      padding: EdgeInsets.fromLTRB(
        compact ? 13 : 18,
        compact ? 11 : 18,
        compact ? 13 : 18,
        compact ? 20 : 28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'resultado\nfinal',
            subtitle: 'La noche ha terminado. La fortuna ya tiene dueño.',
            showIllustration: true,
            illustrationPopIn: true,
          ),
          const SizedBox(height: 18),
          if (winner != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
              decoration: BoxDecoration(
                color: accentGold,
                borderRadius: CuboRadii.xlAll,
                border: Border.all(
                  color: appWhite,
                  width: 2.5,
                ),
                boxShadow: CuboShadows.soft,
              ),
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: appWhite,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: appBlue,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'GANA LA HERENCIA',
                    style: TextStyle(
                      color: appBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    winner.name.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: appBlue,
                      fontSize: 42,
                      height: 0.9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${winner.totalWealth}€ de fortuna total',
                    style: const TextStyle(
                      color: appBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _sectionTitle('clasificación'),
          const SizedBox(height: 10),
          _panel(
            child: Column(
              children: ranking.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: CuboDecorations.glass(
                    radius: CuboRadii.md,
                    selected: index == 0,
                    accent: accentGold,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0 ? accentGold : appWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                color: appWhite,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${player.role.label} · ${player.money}€ efectivo · ${player.goodsValue}€ bienes',
                              style: TextStyle(
                                color: appWhite.withOpacity(0.62),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${player.totalWealth}€',
                        style: const TextStyle(
                          color: accentGold,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (game.eliminatedPlayers.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('eliminados'),
            const SizedBox(height: 10),
            _panel(
              child: Column(
                children: game.eliminatedPlayers.map((player) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: appWhite.withOpacity(0.55),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${player.name} · ${player.role.label}',
                            style: TextStyle(
                              color: appWhite.withOpacity(0.62),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restartSamePlayers,
              style: _mainButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'REPETIR · MISMOS JUGADORES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _restartDifferentPlayers,
              style: _secondaryButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  'CAMBIAR JUGADORES',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: _secondaryButtonStyle(),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  'MENÚ PRINCIPAL',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(BmPlayer player) {
    final remaining = player.detentionRemaining;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: player.isAlive
          ? CuboDecorations.glass(radius: CuboRadii.md)
          : BoxDecoration(
              color: CuboColors.whiteA(0.04),
              borderRadius: CuboRadii.mdAll,
              border: Border.all(color: CuboColors.whiteA(0.14), width: 1.2),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _accentDot(
                !player.isAlive
                    ? CuboColors.whiteA(0.35)
                    : player.isDetained
                    ? accentBlue
                    : accentGreen,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: player.isAlive
                        ? appWhite
                        : appWhite.withOpacity(0.48),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _statusPill(player),
            ],
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniPill('${player.money}€ efectivo'),
              _miniPill('${player.goodsValue}€ bienes'),
              _miniPill('${player.totalWealth}€ total'),
            ],
          ),
          if (player.isDetained) ...[
            const SizedBox(height: 9),
            Text(
              'No puede asesinar durante ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          if (player.goods.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              player.goods.map((lot) => lot.name).join(' · '),
              style: TextStyle(
                color: appWhite.withOpacity(0.62),
                fontSize: 11.5,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(BmPlayer player) {
    String text;
    Color color;

    if (!player.isAlive) {
      text = 'Eliminado';
      color = appWhite.withOpacity(0.55);
    } else if (player.isDetained) {
      text = 'Detenido';
      color = accentBlue;
    } else {
      text = 'Activo';
      color = accentGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.55),
          width: 1.3,
        ),
      ),
      child: Text(
        tr(text).toUpperCase(),
        style: const TextStyle(
          color: appWhite,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool darkForeground = false,
  }) {
    final compact = _isCompactScreen;
    final foreground = darkForeground ? appBlue : appWhite;

    return AspectRatio(
      aspectRatio: compact ? 1.28 : 1.18,
      child: Material(
        color: color,
        shape: const RoundedRectangleBorder(borderRadius: CuboRadii.lgAll),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(compact ? 10 : 13),
            decoration: BoxDecoration(
              borderRadius: CuboRadii.lgAll,
              border: Border.all(
                color: CuboColors.whiteA(0.32),
                width: 1.6,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 46 : 54,
                  height: compact ? 46 : 54,
                  decoration: BoxDecoration(
                    color: darkForeground
                        ? appBlue.withOpacity(0.12)
                        : appWhite.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: foreground.withOpacity(0.55),
                      width: 1.8,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: foreground,
                    size: compact ? 25 : 29,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                SizedBox(
                  width: double.infinity,
                  child: _singleLineResponsiveText(
                    tr(title).toUpperCase(),
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: compact ? 11.5 : 13,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 4 : 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withOpacity(0.78),
                    fontSize: compact ? 9.5 : 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: CuboColors.whiteA(0.24),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: appWhite,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _miniPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CuboColors.whiteA(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: CuboColors.whiteA(0.18),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.82),
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  /// [light] es la variante para usar dentro de la tarjeta blanca.
  Widget _secretInfoTile(String label, String value, {bool light = false}) {
    final fg = light ? CuboColors.blueInk : appWhite;
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
        return accentRed;
      case BmRole.agente:
        return accentBlue;
      case BmRole.invitado:
        return accentGreen;
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

    game.setMissionOptions(
      roomNames: roomNames,
      weaponNames: weaponNames,
    );

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

  void _restoreDefaultMissionOptions() {
    setState(() {
      roomsController.text =
          BarcelonaMedianocheGame.defaultRooms.join('\n');
      weaponsController.text =
          BarcelonaMedianocheGame.defaultWeapons.join('\n');

      game.setMissionOptions(
        roomNames: BarcelonaMedianocheGame.defaultRooms,
        weaponNames: BarcelonaMedianocheGame.defaultWeapons,
      );
    });

    _snack('Escenario original restaurado.');
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

  Future<void> _showKillDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No quedan suficientes jugadores vivos.');
      return;
    }

    String actorId = alive.first.id;
    bool missionVisible = false;
    bool correctRoom = false;
    bool weaponPresent = false;
    bool noWitnesses = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final actor = game.findPlayerById(actorId)!;
            final target = game.findPlayerById(actor.currentTargetId);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: CuboDecorations.dialog(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.local_fire_department_rounded,
                        title: 'asesinato',
                      ),
                      const SizedBox(height: 14),
                      _dialogDropdown<String>(
                        label: 'JUGADOR QUE ACTÚA',
                        value: actorId,
                        items: alive
                            .map(
                              (player) => DropdownMenuItem(
                            value: player.id,
                            child: Text(player.name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            actorId = value;
                            missionVisible = false;
                            correctRoom = false;
                            weaponPresent = false;
                            noWitnesses = false;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setModalState(() {
                              missionVisible = !missionVisible;
                            });
                          },
                          style: _secondaryButtonStyle(),
                          icon: Icon(
                            missionVisible
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              missionVisible
                                  ? 'OCULTAR MISIÓN'
                                  : 'MOSTRAR MI MISIÓN',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (missionVisible) ...[
                        const SizedBox(height: 12),
                        if (actor.role != BmRole.asesino)
                          _dialogNotice(
                            'Este jugador no tiene una misión de asesinato.',
                            accentBlue,
                          )
                        else ...[
                          _secretInfoTile(
                            'Objetivo',
                            target?.name ?? 'Sin objetivo',
                          ),
                          _secretInfoTile(
                            'Habitación',
                            actor.currentRoom ?? '-',
                          ),
                          _secretInfoTile(
                            'Objeto',
                            actor.currentWeapon ?? '-',
                          ),
                          const SizedBox(height: 6),
                          _checkRow(
                            value: correctRoom,
                            text: 'Estamos en la habitación correcta',
                            onChanged: (value) {
                              setModalState(() => correctRoom = value);
                            },
                          ),
                          _checkRow(
                            value: weaponPresent,
                            text: 'El objeto asignado está presente',
                            onChanged: (value) {
                              setModalState(() => weaponPresent = value);
                            },
                          ),
                          _checkRow(
                            value: noWitnesses,
                            text: 'No hay ningún testigo vivo presente',
                            onChanged: (value) {
                              setModalState(() => noWitnesses = value);
                            },
                          ),
                        ],
                      ],
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: missionVisible &&
                              actor.role == BmRole.asesino &&
                              target != null
                              ? () {
                            final message = game.killTarget(
                              killerId: actor.id,
                              victimId: target.id,
                              correctRoom: correctRoom,
                              weaponPresent: weaponPresent,
                              noLivingWitnesses: noWitnesses,
                            );

                            final success =
                            message.contains('ha sido eliminado');

                            if (!success) {
                              _snack(message);
                              return;
                            }

                            Navigator.pop(dialogContext);
                            setState(() {});
                            _snack(message);
                          }
                              : null,
                          style: _dangerButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'CONFIRMAR ASESINATO',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: appWhite.withOpacity(0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showArrestDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No quedan suficientes jugadores vivos.');
      return;
    }

    String agentId = alive.first.id;
    String suspectId = alive.firstWhere((p) => p.id != agentId).id;
    bool hasClearProof = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final suspects = alive.where((p) => p.id != agentId).toList();

            if (!suspects.any((p) => p.id == suspectId)) {
              suspectId = suspects.first.id;
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: CuboDecorations.dialog(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.local_police_rounded,
                        title: 'detención',
                      ),
                      const SizedBox(height: 14),
                      _dialogDropdown<String>(
                        label: 'AGENTE QUE ACTÚA',
                        value: agentId,
                        items: alive
                            .map(
                              (player) => DropdownMenuItem(
                            value: player.id,
                            child: Text(player.name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            agentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogDropdown<String>(
                        label: 'SOSPECHOSO',
                        value: suspectId,
                        items: suspects
                            .map(
                              (player) => DropdownMenuItem(
                            value: player.id,
                            child: Text(player.name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => suspectId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      _checkRow(
                        value: hasClearProof,
                        text:
                        'He presenciado el crimen o tengo una prueba clara',
                        onChanged: (value) {
                          setModalState(() => hasClearProof = value);
                        },
                      ),
                      const SizedBox(height: 6),
                      _dialogNotice(
                        hasClearProof
                            ? 'Si el acusado es asesino: 10 minutos sin matar y hasta 40€ para el agente.'
                            : 'Sin prueba clara, la acusación se considerará falsa aunque el sospechoso sea asesino.',
                        hasClearProof ? accentBlue : accentRed,
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final agent = game.findPlayerById(agentId)!;

                            if (agent.role != BmRole.agente) {
                              _snack('Este jugador no es un agente.');
                              return;
                            }

                            final message = game.arrestPlayer(
                              agentId: agentId,
                              suspectId: suspectId,
                              hasClearProof: hasClearProof,
                            );

                            Navigator.pop(dialogContext);
                            setState(() {});
                            _snack(message);
                          },
                          style: _mainButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'DECLARAR DETENCIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: appWhite.withOpacity(0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showTransferDialog() async {
    final alive = game.alivePlayers;

    if (alive.length < 2) {
      _snack('No hay suficientes jugadores vivos para hacer un trato.');
      return;
    }

    String fromId = alive.first.id;
    String toId = alive.firstWhere((p) => p.id != fromId).id;
    bool transferGood = false;
    String? selectedLotId;
    final amountController = TextEditingController();
    final reasonController = TextEditingController(text: tr('Trato privado'));

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final sender = game.findPlayerById(fromId)!;
            final recipients = alive.where((p) => p.id != fromId).toList();

            if (!recipients.any((p) => p.id == toId)) {
              toId = recipients.first.id;
            }

            if (sender.goods.isNotEmpty &&
                !sender.goods.any((lot) => lot.id == selectedLotId)) {
              selectedLotId = sender.goods.first.id;
            }

            if (sender.goods.isEmpty) {
              selectedLotId = null;
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: CuboDecorations.dialog(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.handshake_rounded,
                        title: 'trato',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setModalState(() => transferGood = false);
                              },
                              style: transferGood
                                  ? _secondaryElevatedStyle()
                                  : _mainButtonStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'DINERO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setModalState(() => transferGood = true);
                              },
                              style: transferGood
                                  ? _mainButtonStyle()
                                  : _secondaryElevatedStyle(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'BIEN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _dialogDropdown<String>(
                        label: 'DE',
                        value: fromId,
                        items: alive
                            .map(
                              (player) => DropdownMenuItem(
                            value: player.id,
                            child: Text(player.name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            fromId = value;
                            selectedLotId = null;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _dialogDropdown<String>(
                        label: 'PARA',
                        value: toId,
                        items: recipients
                            .map(
                              (player) => DropdownMenuItem(
                            value: player.id,
                            child: Text(player.name),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() => toId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (!transferGood)
                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: appWhite,
                            fontWeight: FontWeight.w800,
                          ),
                          cursorColor: appWhite,
                          decoration: _dialogInputDecoration(
                            'Cantidad · disponible ${sender.money}€',
                          ),
                        )
                      else if (sender.goods.isEmpty)
                        _dialogNotice(
                          '${sender.name} no posee ningún bien.',
                          accentRed,
                        )
                      else
                        _dialogDropdown<String>(
                          label: 'BIEN',
                          value: selectedLotId!,
                          items: sender.goods
                              .map(
                                (lot) => DropdownMenuItem(
                              value: lot.id,
                              child: Text('${lot.name} · ${lot.value}€'),
                            ),
                          )
                              .toList(),
                          onChanged: (value) {
                            setModalState(() => selectedLotId = value);
                          },
                        ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: reasonController,
                        style: const TextStyle(
                          color: appWhite,
                          fontWeight: FontWeight.w700,
                        ),
                        cursorColor: appWhite,
                        decoration: _dialogInputDecoration(
                          'Motivo: trato, robo, deuda...',
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: transferGood && selectedLotId == null
                              ? null
                              : () {
                            final reason =
                            reasonController.text.trim().isEmpty
                                ? 'Trato privado'
                                : reasonController.text.trim();

                            final message = transferGood
                                ? game.transferGood(
                              fromPlayerId: fromId,
                              toPlayerId: toId,
                              lotId: selectedLotId!,
                              reason: reason,
                            )
                                : game.transferMoney(
                              fromPlayerId: fromId,
                              toPlayerId: toId,
                              amount: int.tryParse(
                                amountController.text.trim(),
                              ) ??
                                  0,
                              reason: reason,
                            );

                            final success =
                                message.contains('transfiere') ||
                                    message.contains('entrega');

                            if (!success) {
                              _snack(message);
                              return;
                            }

                            Navigator.pop(dialogContext);
                            setState(() {});
                            _snack(message);
                          },
                          style: _mainButtonStyle(),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'REGISTRAR CAMBIO',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'CANCELAR',
                          style: TextStyle(
                            color: appWhite.withOpacity(0.72),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    amountController.dispose();
    reasonController.dispose();
  }

  Future<void> _confirmStartFinalAuction() async {
    if (game.alivePlayers.isEmpty) {
      _snack('No queda ningún jugador vivo para participar.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dialogTitle(
                icon: Icons.diamond_rounded,
                title: 'subasta',
              ),
              const SizedBox(height: 14),
              Text(
                'La fase libre terminará y comenzarán 5 lotes con pujas secretas. Después se mostrará el ganador de la herencia.',
                style: TextStyle(
                  color: appWhite.withOpacity(0.76),
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: _mainButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'COMENZAR SUBASTA FINAL',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: _secondaryButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    'SEGUIR JUGANDO',
                    style: TextStyle(
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

    if (confirmed != true) return;

    setState(() {
      bidController.clear();
      game.startFinalAuction(lotCount: 5);
    });
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

  Widget _dialogTitle({
    required IconData icon,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CuboIconCircle(icon: icon, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  tr(title).toLowerCase(),
                  maxLines: 1,
                  softWrap: false,
                  style: CuboText.title(size: 32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const CuboPillBar(),
      ],
    );
  }

  Widget _dialogNotice(String text, Color color) {
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
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checkRow({
    required bool value,
    required String text,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: CuboRadii.mdAll,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: CuboColors.whiteA(value ? 0.14 : 0.06),
          borderRadius: CuboRadii.mdAll,
          border: Border.all(
            color: value
                ? CuboColors.whiteA(0.80)
                : CuboColors.whiteA(0.20),
            width: value ? 1.6 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: appWhite,
              checkColor: appBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration(String hint) {
    return CuboInputs.decoration(hintText: tr(hint));
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: appWhite.withOpacity(0.65),
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: CuboColors.whiteA(0.07),
            borderRadius: CuboRadii.inputAll,
            border: Border.all(
              color: CuboColors.whiteA(0.28),
              width: 1.2,
            ),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: appBlue,
            borderRadius: CuboRadii.mdAll,
            icon: const Icon(Icons.expand_more_rounded),
            style: const TextStyle(
              color: appWhite,
              fontWeight: FontWeight.w700,
            ),
            underline: const SizedBox.shrink(),
            iconEnabledColor: appWhite,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
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
