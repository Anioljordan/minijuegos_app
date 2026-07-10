import 'dart:async';
import 'package:flutter/material.dart';
import '../data/barcelonamedianoche_data.dart';

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

  final TextEditingController namesController = TextEditingController(
    text: 'Aniol\nMartina\nAlex\nJúlia\nMarc\nPaula',
  );

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
      _showRulesDialog();
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

  ButtonStyle _mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle _dangerButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: accentRed,
      foregroundColor: appWhite,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  ButtonStyle _secondaryButtonStyle() {
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

  Widget _screenHeader({
    required String title,
    String? subtitle,
    VoidCallback? extraAction,
    IconData? extraIcon,
    VoidCallback? onBack,
  }) {
    final visualTitle = title.toLowerCase();
    final multiline = visualTitle.contains('\n');
    final titleHeight = multiline ? 94.0 : 58.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(
              onTap: onBack ?? () => Navigator.pop(context),
              child: const Text(
                '8',
                style: TextStyle(
                  color: appWhite,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Row(
              children: [
                if (extraAction != null && extraIcon != null) ...[
                  _circleButton(
                    onTap: extraAction,
                    child: Icon(
                      extraIcon,
                      color: appWhite,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                _circleButton(
                  onTap: _showRulesDialog,
                  child: const Icon(
                    Icons.question_mark_rounded,
                    color: appWhite,
                    size: 27,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: titleHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    visualTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 40,
                      height: 0.88,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Positioned(
                  top: multiline ? 82 : 50,
                  left: 0,
                  right: -18,
                  child: Container(
                    height: 3,
                    color: appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.06),
        border: Border(
          left: BorderSide(
            color: color,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.36),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.76),
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _panel({
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

  Widget _sectionTitle(String text) {
    return Text(
      text.toLowerCase(),
      style: const TextStyle(
        color: appWhite,
        fontSize: 28,
        height: 0.95,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
      ),
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
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.78),
              width: 2.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
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
                    'BARCELONA, MEDIANOCHE',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
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
                    icon: Icons.payments_outlined,
                    title: 'Cuando alguien muere',
                    text:
                    'La víctima entrega todo su dinero al atacante. Queda eliminada: puede hablar y negociar, pero ya no actúa, puja ni puede ganar.',
                  ),
                  _rulesItem(
                    icon: Icons.local_police_outlined,
                    title: 'Agentes',
                    text:
                    'Un agente puede declarar una detención si ha presenciado el crimen o tiene una prueba clara.',
                  ),
                  _rulesItem(
                    icon: Icons.timer_outlined,
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
                    icon: Icons.handshake_outlined,
                    title: 'Tratos y robos',
                    text:
                    'Se permiten alianzas, intercambios y robos acordados por la mesa. Registra en la app cualquier cambio de dinero o bienes.',
                  ),
                  _rulesItem(
                    icon: Icons.diamond_outlined,
                    title: 'Subasta final',
                    text:
                    'Al terminar la noche se subastan 5 lotes. Las pujas son secretas y solo participan los jugadores vivos.',
                  ),
                  _rulesItem(
                    icon: Icons.emoji_events_outlined,
                    title: 'Quién gana',
                    text:
                    'Gana el superviviente con mayor fortuna total: dinero restante + valor de los bienes adquiridos.',
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: _mainButtonStyle(),
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
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'barcelona\nmedianoche',
            subtitle:
            'Una subasta, identidades secretas y una herencia que solo puede ganar un superviviente.',
          ),
          const SizedBox(height: 18),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('la invitación'),
                const SizedBox(height: 12),
                Text(
                  'Habéis sido convocados a una subasta privada. Algunos han venido por dinero. Otros por venganza. Y entre vosotros hay asesinos y agentes encubiertos.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.78),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('escenario'),
                const SizedBox(height: 12),
                Text(
                  'Personaliza los lugares y los objetos que pueden aparecer en las misiones de los asesinos. Escribe una opción por línea.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.68),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'HABITACIONES DISPONIBLES',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: roomsController,
                  minLines: 4,
                  maxLines: 8,
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: _setupInputDecoration(
                    'Biblioteca\nSalón\nJardín\nBodega',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'OBJETOS DEL CRIMEN',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.70),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: weaponsController,
                  minLines: 4,
                  maxLines: 8,
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: _setupInputDecoration(
                    'Copa\nAbrecartas\nCandelabro\nBufanda',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _restoreDefaultMissionOptions,
                    style: _secondaryButtonStyle(),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'RESTAURAR ESCENARIO ORIGINAL',
                        textAlign: TextAlign.center,
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
          ),
          const SizedBox(height: 14),
          _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('jugadores'),
                const SizedBox(height: 12),
                Text(
                  'Un nombre por línea. Mínimo 4 jugadores.',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.68),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: namesController,
                  maxLines: 8,
                  style: const TextStyle(
                    color: appWhite,
                    fontWeight: FontWeight.w700,
                  ),
                  cursorColor: appWhite,
                  decoration: InputDecoration(
                    hintText: 'Aniol\nMartina\nAlex\nJúlia',
                    hintStyle: TextStyle(
                      color: appWhite.withOpacity(0.38),
                    ),
                    filled: true,
                    fillColor: appWhite.withOpacity(0.07),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: appWhite.withOpacity(0.28),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: appWhite.withOpacity(0.28),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                        color: appWhite,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _preparePlayers,
                    style: _secondaryButtonStyle(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        'PREPARAR JUGADORES',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
                if (game.players.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: game.players
                        .map((player) => _chip(player.name))
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: game.canStart ? _startGame : null,
                      style: _mainButtonStyle(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          game.canStart
                              ? 'COMENZAR REPARTO SECRETO'
                              : 'FALTAN JUGADORES',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _infoBar(
            text:
            'Recomendado: 5–10 jugadores y una partida de 30–60 minutos antes de iniciar la subasta final.',
            color: accentGold,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealView() {
    final player = game.revealedPlayer;
    final target = game.findPlayerById(player.currentTargetId);

    return SingleChildScrollView(
      key: ValueKey('reveal_${player.id}'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'reparto\nsecreto',
            subtitle: 'Solo debe mirar la persona cuyo nombre aparece.',
          ),
          const SizedBox(height: 18),
          _panel(
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
                    Icons.phone_android_rounded,
                    color: appWhite,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  player.name.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 38,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      game.revealRoleVisible = !game.revealRoleVisible;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: appWhite.withOpacity(0.08),
                      border: Border.all(
                        color: appWhite.withOpacity(0.28),
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          game.revealRoleVisible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: appWhite,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          game.revealRoleVisible
                              ? player.role.label.toLowerCase()
                              : 'toca para revelar',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: appWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (game.revealRoleVisible) ...[
                          const SizedBox(height: 12),
                          Text(
                            _roleDescription(player.role),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: appWhite.withOpacity(0.76),
                              fontSize: 13.5,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (player.role == BmRole.asesino) ...[
                            const SizedBox(height: 16),
                            _secretInfoTile(
                              'Objetivo',
                              target?.name ?? 'Sin objetivo',
                            ),
                            _secretInfoTile(
                              'Habitación',
                              player.currentRoom ?? '-',
                            ),
                            _secretInfoTile(
                              'Objeto',
                              player.currentWeapon ?? '-',
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => setState(game.nextReveal),
                    style: _mainButtonStyle(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return SingleChildScrollView(
      key: const ValueKey('playing'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'barcelona\nmedianoche',
            subtitle:
            'La mesa es pública. Las identidades y misiones deben seguir siendo secretas.',
          ),
          const SizedBox(height: 18),
          _sectionTitle('estado de la noche'),
          const SizedBox(height: 10),
          ...game.players.map(_playerCard),
          const SizedBox(height: 18),
          _sectionTitle('acciones'),
          const SizedBox(height: 10),
          _actionButton(
            title: 'Registrar asesinato',
            subtitle:
            'El jugador que actúa coge el móvil y confirma su misión en secreto.',
            icon: Icons.local_fire_department_outlined,
            color: accentRed,
            onTap: _showKillDialog,
          ),
          _actionButton(
            title: 'Registrar detención',
            subtitle:
            'Un agente declara una detención con prueba clara o como acusación arriesgada.',
            icon: Icons.local_police_outlined,
            color: accentBlue,
            onTap: _showArrestDialog,
          ),
          _actionButton(
            title: 'Registrar trato o robo',
            subtitle:
            'Actualiza dinero o bienes después de una alianza, intercambio o robo.',
            icon: Icons.handshake_outlined,
            color: accentPurple,
            onTap: _showTransferDialog,
          ),
          _actionButton(
            title: 'Comenzar subasta final',
            subtitle:
            'Termina la fase libre y empieza la puja secreta de 5 lotes.',
            icon: Icons.diamond_outlined,
            color: accentGold,
            onTap: _confirmStartFinalAuction,
          ),
          const SizedBox(height: 18),
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
                          Icons.circle,
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
    final lot = game.currentAuctionLot;
    final bidder = game.currentBidder;

    return SingleChildScrollView(
      key: ValueKey(
        'auction_${game.currentLotIndex}_${game.currentBidderIndex}_${game.auctionRoundResolved}',
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
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
            _panel(
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appWhite.withOpacity(0.85),
                        width: 2.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.diamond_outlined,
                      color: appWhite,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lot.name.toLowerCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 32,
                      height: 0.95,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Valor real: ${lot.value}€',
                    style: const TextStyle(
                      color: accentGold,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
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
                    decoration: InputDecoration(
                      hintText: '0 = no pujar',
                      hintStyle: TextStyle(
                        color: appWhite.withOpacity(0.40),
                      ),
                      filled: true,
                      fillColor: appWhite.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: appWhite.withOpacity(0.28),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: appWhite.withOpacity(0.28),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: appWhite,
                          width: 2,
                        ),
                      ),
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
                    Icons.emoji_events_outlined,
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
    final ranking = game.ranking;
    final winner = ranking.isNotEmpty ? ranking.first : null;

    return SingleChildScrollView(
      key: const ValueKey('ended'),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _screenHeader(
            title: 'resultado\nfinal',
            subtitle: 'La noche ha terminado. La fortuna ya tiene dueño.',
          ),
          const SizedBox(height: 18),
          if (winner != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
              decoration: BoxDecoration(
                color: accentGold,
                border: Border.all(
                  color: appWhite,
                  width: 2.5,
                ),
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
                  decoration: BoxDecoration(
                    color: appWhite.withOpacity(0.07),
                    border: Border(
                      left: BorderSide(
                        color: index == 0 ? accentGold : appWhite,
                        width: 5,
                      ),
                      bottom: BorderSide(
                        color: appWhite.withOpacity(0.24),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: appWhite,
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
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border(
          left: BorderSide(
            color: !player.isAlive
                ? appWhite.withOpacity(0.35)
                : player.isDetained
                ? accentBlue
                : accentGreen,
            width: 5,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.26),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        border: Border.all(
          color: color.withOpacity(0.55),
          width: 1.3,
        ),
      ),
      child: Text(
        text.toUpperCase(),
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.08),
          border: Border(
            left: BorderSide(
              color: color,
              width: 6,
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
            Icon(
              icon,
              color: appWhite,
              size: 27,
            ),
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
                      letterSpacing: 0.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.66),
                      fontSize: 12.2,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: appWhite.withOpacity(0.70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.24),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.18),
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

  Widget _secretInfoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
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
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.38),
      ),
      filled: true,
      fillColor: appWhite.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
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

  void _preparePlayers() {
    if (!_applyMissionConfiguration()) return;

    final names = namesController.text.split('\n');
    game.setPlayersFromNames(names);

    if (game.players.length < 4) {
      setState(() {});
      _snack('Se necesitan al menos 4 jugadores.');
      return;
    }

    if (game.hasDuplicateNames) {
      setState(() {});
      _snack('Usa nombres distintos para evitar confusiones.');
      return;
    }

    setState(() {});
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
                decoration: BoxDecoration(
                  color: appBlue,
                  border: Border.all(
                    color: appWhite.withOpacity(0.78),
                    width: 2.2,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.local_fire_department_outlined,
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
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
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
                decoration: BoxDecoration(
                  color: appBlue,
                  border: Border.all(
                    color: appWhite.withOpacity(0.78),
                    width: 2.2,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.local_police_outlined,
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
    final reasonController = TextEditingController(text: 'Trato privado');

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
                decoration: BoxDecoration(
                  color: appBlue,
                  border: Border.all(
                    color: appWhite.withOpacity(0.78),
                    width: 2.2,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _dialogTitle(
                        icon: Icons.handshake_outlined,
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
                                  ? _secondaryButtonStyle()
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
                                  : _secondaryButtonStyle(),
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
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite.withOpacity(0.78),
              width: 2.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dialogTitle(
                icon: Icons.diamond_outlined,
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
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: appWhite.withOpacity(0.82),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: appWhite,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title.toLowerCase(),
            style: const TextStyle(
              color: appWhite,
              fontSize: 32,
              height: 0.95,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dialogNotice(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.07),
        border: Border(
          left: BorderSide(
            color: color,
            width: 5,
          ),
          bottom: BorderSide(
            color: appWhite.withOpacity(0.24),
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.78),
          fontSize: 12.5,
          height: 1.3,
          fontWeight: FontWeight.w700,
        ),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.06),
          border: Border.all(
            color: value
                ? appWhite.withOpacity(0.70)
                : appWhite.withOpacity(0.20),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: appWhite,
              checkColor: appBlue,
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
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.42),
      ),
      filled: true,
      fillColor: appWhite.withOpacity(0.07),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: appWhite.withOpacity(0.28),
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.07),
            border: Border.all(
              color: appWhite.withOpacity(0.28),
            ),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: appBlue,
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
      backgroundColor: appBlue,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildCurrentPhase(),
        ),
      ),
    );
  }
}
