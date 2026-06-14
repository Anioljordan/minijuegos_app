import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/barcelonamedianoche_data.dart';

class BarcelonaMedianocheScreen extends StatefulWidget {
  const BarcelonaMedianocheScreen({super.key});

  @override
  State<BarcelonaMedianocheScreen> createState() => _BarcelonaMedianocheScreenState();
}

class _BarcelonaMedianocheScreenState extends State<BarcelonaMedianocheScreen>
    with SingleTickerProviderStateMixin {
  final BarcelonaMedianocheGame game = BarcelonaMedianocheGame();
  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentGold = Color(0xFFFFD166);
  static const Color accentBlue = Color(0xFF60A5FA);
  final TextEditingController namesController = TextEditingController(
    text: 'Aniol\nMartina\nAlex\nJúlia\nMarc\nPaula',
  );

  late final AnimationController _bgController;
  Widget _topCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onPressed,
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
        child: Icon(
          icon,
          color: appWhite,
          size: 27,
        ),
      ),
    );
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

  Widget _rulesItem({
    required IconData icon,
    required String title,
    required String text,
    required Color color,
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
                    'BARCELONA, MEDIANOCHE',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  _rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'Preparad la noche',
                    text:
                    'Escribe los nombres de los jugadores. Se necesitan mínimo 4 jugadores.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.visibility_off_rounded,
                    title: 'Roles secretos',
                    text:
                    'Cada jugador mira su rol en secreto: Asesino, Agente o Invitado.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Asesinos',
                    text:
                    'Los asesinos reciben víctima, habitación y arma. Deben eliminar sin ser descubiertos.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.gavel_rounded,
                    title: 'Agentes',
                    text:
                    'Los agentes pueden detener sospechosos si tienen pruebas claras.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.diamond_rounded,
                    title: 'Subastas',
                    text:
                    'Durante la partida podéis abrir subastas para ganar bienes y aumentar riqueza.',
                    color: appWhite,
                  ),

                  _rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Victoria',
                    text:
                    'Al terminar la noche, gana quien tenga más riqueza total entre dinero y bienes.',
                    color: appWhite,
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

  Widget _miniHeader(String title) {
    return _screenHeader(
      title: title.toLowerCase(),
      subtitle: null,
    );
  }
  Widget _screenHeader({
    required String title,
    String? subtitle,
    VoidCallback? extraAction,
    IconData? extraIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(
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
            height: title.contains('\n') ? 94 : 58,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    title,
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
                  top: title.contains('\n') ? 82 : 50,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: appWhite.withOpacity(0.06),
              border: Border(
                left: const BorderSide(
                  color: accentRed,
                  width: 6,
                ),
                bottom: BorderSide(
                  color: appWhite.withOpacity(0.36),
                  width: 2,
                ),
              ),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                color: appWhite.withOpacity(0.76),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ],
    );
  }
  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showRulesDialog();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    namesController.dispose();
    super.dispose();
  }


  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final value = _bgController.value;
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB91C1C),
                    Color(0xFF7F1D1D),
                    Color(0xFF2A0F14),
                    Color(0xFF090909),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -120,
              left: -60,
              right: -60,
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB43C4B).withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60 + (value * 30),
              left: -60,
              right: -60,
              child: _fogLayer(220, 0.07),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _GrainPainter(opacity: 0.05 + (value * 0.03)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _fogLayer(double height, double opacity) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(opacity),
              Colors.white.withOpacity(0.0),
            ],
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
      case BmPhase.ended:
        return _buildEndView();
    }
  }

  Widget _buildSetupView() {
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _titleBlock(),
          const SizedBox(height: 22),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jugadores',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Escribe un nombre por línea. Mínimo 4 jugadores.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namesController,
                  maxLines: 10,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.06),
                    hintText: 'Aniol\nMartina\nAlex\nJúlia',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Color(0xFFB43C4B)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _preparePlayers,
                    style: _mainButtonStyle(),
                    child: const Text('Preparar partida'),
                  ),
                ),
                const SizedBox(height: 12),
                if (game.players.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: game.players
                        .map((p) => _chip(p.name, Icons.person_outline))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: game.canStart ? _startGame : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8D7B0),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        game.canStart
                            ? 'Comenzar reparto secreto'
                            : 'Faltan jugadores',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _glassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Reglas rápidas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _RuleLine('Los asesinos reciben una víctima, habitación y arma.'),
                _RuleLine('Los agentes pueden detener si han presenciado el crimen o tienen pruebas claras.'),
                _RuleLine('Si acusan mal, pagan 40€ al acusado.'),
                _RuleLine('La víctima entrega su dinero al atacante.'),
                _RuleLine('El jugador con más riqueza total gana la herencia.'),
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

    return SingleChildScrollView(
      key: ValueKey('reveal_${player.id}'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),

          _miniHeader('Reparto secreto'),

          const SizedBox(height: 22),

          Text(
            'Pasa el móvil a ${player.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Solo esa persona debe mirar esta pantalla.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.72)),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => game.revealRoleVisible = !game.revealRoleVisible),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: game.revealRoleVisible
                      ? [const Color(0xFF321218), const Color(0xFF140A0D)]
                      : [const Color(0xFF101214), const Color(0xFF0C0D0F)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB43C4B).withOpacity(0.18),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    game.revealRoleVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFE8D7B0),
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    game.revealRoleVisible ? player.role.label : 'Toca para revelar tu identidad',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (game.revealRoleVisible) ...[
                    Text(
                      _roleDescription(player.role),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    if (player.role == BmRole.asesino) ...[
                      const SizedBox(height: 16),
                      _secretInfoTile('Objetivo', target?.name ?? 'Sin objetivo'),
                      _secretInfoTile('Habitación', player.currentRoom ?? '-'),
                      _secretInfoTile('Arma', player.currentWeapon ?? '-'),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(game.nextReveal);
              },
              style: _mainButtonStyle(),
              child: Text(game.isLastReveal ? 'Empezar la noche' : 'Siguiente jugador'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView() {
    return SingleChildScrollView(
      key: const ValueKey('playing'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _titleBlock(compact: true)),
              IconButton(
                onPressed: () => setState(game.finishGame),
                icon: const Icon(Icons.flag_outlined, color: Color(0xFFE8D7B0)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle('Estado de los jugadores'),
          const SizedBox(height: 10),
          ...game.players.map(_playerCard),
          const SizedBox(height: 18),
          _sectionTitle('Acciones'),
          const SizedBox(height: 10),
          _actionButton(
            title: 'Registrar asesinato',
            subtitle: 'Un asesino elimina a su objetivo y roba su dinero.',
            icon: Icons.local_fire_department_outlined,
            onTap: _showKillDialog,
          ),
          _actionButton(
            title: 'Registrar detención',
            subtitle: 'Un agente acusa a un sospechoso. Puede acertar o fallar.',
            icon: Icons.gavel_outlined,
            onTap: _showArrestDialog,
          ),
          _actionButton(
            title: 'Abrir subasta',
            subtitle: 'Saca un lote y deja registrar pujas en secreto.',
            icon: Icons.diamond_outlined,
            onTap: _showAuctionDialog,
          ),
          const SizedBox(height: 18),
          _sectionTitle('Registro de la noche'),
          const SizedBox(height: 10),
          _glassCard(
            child: game.log.isEmpty
                ? Text(
              'Todavía no ha ocurrido nada.',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            )
                : Column(
              children: game.log
                  .take(12)
                  .map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFFB43C4B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: Colors.white,
                            height: 1.35,
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

  Widget _buildEndView() {
    final ranking = game.ranking;
    return SingleChildScrollView(
      key: const ValueKey('ended'),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          _miniHeader('Resultado final'),

          const SizedBox(height: 22),

          const Icon(
            Icons.emoji_events_outlined,
            color: Color(0xFFE8D7B0),
            size: 44,
          ),
          const SizedBox(height: 12),
          const Text(
            'La herencia tiene dueño',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El más rico se queda con la noche.',
            style: TextStyle(color: Colors.white.withOpacity(0.72)),
          ),
          const SizedBox(height: 22),
          _glassCard(
            child: Column(
              children: ranking.asMap().entries.map((entry) {
                final index = entry.key;
                final player = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: index == 0
                            ? const Color(0xFFE8D7B0)
                            : Colors.white.withOpacity(0.08),
                        foregroundColor: index == 0 ? Colors.black : Colors.white,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${player.role.label} · ${player.isAlive ? 'Vivo' : 'Eliminado'}',
                              style: TextStyle(color: Colors.white.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${player.totalWealth}€',
                            style: const TextStyle(
                              color: Color(0xFFE8D7B0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${player.money}€ cash · ${player.goodsValue}€ bienes',
                            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetAll,
              style: _mainButtonStyle(),
              child: const Text('Nueva partida'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _playerCard(BmPlayer player) {
    final target = game.findPlayerById(player.currentTargetId);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _statusPill(player),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _miniPill(player.role.label),
                _miniPill('Dinero ${player.money}€'),
                _miniPill('Bienes ${player.goodsValue}€'),
                _miniPill('Total ${player.totalWealth}€'),
              ],
            ),
            if (player.role == BmRole.asesino && player.isAlive) ...[
              const SizedBox(height: 12),
              Text(
                'Misión actual: ${target?.name ?? 'Sin objetivo'} · ${player.currentRoom ?? '-'} · ${player.currentWeapon ?? '-'}',
                style: TextStyle(color: Colors.white.withOpacity(0.72), height: 1.35),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusPill(BmPlayer player) {
    String text;
    Color color;

    if (!player.isAlive) {
      text = 'Eliminado';
      color = appWhite.withOpacity(0.55);
    } else if (player.isArrested) {
      text = 'Detenido';
      color = accentBlue;
    } else {
      text = 'Activo';
      color = accentRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        border: Border.all(
          color: color.withOpacity(0.50),
          width: 1.4,
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: appWhite,
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _titleBlock({bool compact = false}) {
    return _screenHeader(
      title: 'barcelona\nmedianoche',
      subtitle: compact
          ? null
          : 'Subastas, traición, asesinatos y fortuna bajo la misma lámpara.',
    );
  }
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.26),
          width: 1.3,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: appWhite),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: appWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),
        border: Border.all(
          color: appWhite.withOpacity(0.20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: appWhite.withOpacity(0.85),
          fontWeight: FontWeight.w700,
        ),
      ),
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

  Widget _actionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.08),
            border: Border(
              left: const BorderSide(
                color: accentRed,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.68),
                        height: 1.25,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: appWhite.withOpacity(0.75),
              ),
            ],
          ),
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
              fontSize: 11,
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
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  String _roleDescription(BmRole role) {
    switch (role) {
      case BmRole.asesino:
        return 'Debes eliminar a tu objetivo en secreto para aumentar tu fortuna y acercarte a la herencia.';
      case BmRole.agente:
        return 'Tu misión es vigilar la velada y detener a los asesinos sin acusar a inocentes.';
      case BmRole.invitado:
        return 'Sobrevive, negocia, puja y evita convertirte en la próxima víctima.';
    }
  }

  void _preparePlayers() {
    final names = namesController.text.split('\n');
    setState(() => game.setPlayersFromNames(names));
  }

  void _startGame() {
    setState(game.startGame);
  }

  void _resetAll() {
    setState(() {
      game.phase = BmPhase.setup;
      game.players.clear();
      game.log.clear();
      game.revealIndex = 0;
      game.revealRoleVisible = false;
      game.currentLot = null;
      game.currentBids.clear();
    });
  }

  Future<void> _showKillDialog() async {
    final killers = game.players.where((p) => p.role == BmRole.asesino && p.canAct).toList();
    final victims = game.players.where((p) => p.isAlive).toList();

    if (killers.isEmpty || victims.length < 2) {
      _snack('No hay asesinos disponibles o no quedan suficientes jugadores vivos.');
      return;
    }

    String killerId = killers.first.id;
    String victimId = victims.firstWhere((p) => p.id != killerId).id;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredVictims = victims.where((p) => p.id != killerId).toList();
            if (!filteredVictims.any((v) => v.id == victimId)) {
              victimId = filteredVictims.first.id;
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registrar asesinato',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _darkDropdown(
                    label: 'Asesino',
                    value: killerId,
                    items: killers
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) => setModalState(() => killerId = value!),
                  ),
                  const SizedBox(height: 12),
                  _darkDropdown(
                    label: 'Víctima',
                    value: victimId,
                    items: filteredVictims
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) => setModalState(() => victimId = value!),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final message = game.killTarget(killerId: killerId, victimId: victimId);
                        Navigator.pop(context);
                        setState(() {});
                        _snack(message);
                      },
                      style: _mainButtonStyle(),
                      child: const Text('Confirmar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showArrestDialog() async {
    final agents = game.players.where((p) => p.role == BmRole.agente && p.canAct).toList();
    final suspects = game.players.where((p) => p.isAlive).toList();

    if (agents.isEmpty || suspects.length < 2) {
      _snack('No hay agentes disponibles o no quedan suficientes sospechosos vivos.');
      return;
    }

    String agentId = agents.first.id;
    String suspectId = suspects.firstWhere((p) => p.id != agentId).id;
    bool witnessed = true;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredSuspects = suspects.where((p) => p.id != agentId).toList();
            if (!filteredSuspects.any((v) => v.id == suspectId)) {
              suspectId = filteredSuspects.first.id;
            }
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registrar detención',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _darkDropdown(
                    label: 'Agente',
                    value: agentId,
                    items: agents
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) => setModalState(() => agentId = value!),
                  ),
                  const SizedBox(height: 12),
                  _darkDropdown(
                    label: 'Sospechoso',
                    value: suspectId,
                    items: filteredSuspects
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (value) => setModalState(() => suspectId = value!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: witnessed,
                    onChanged: (v) => setModalState(() => witnessed = v),
                    title: const Text('La acusación tiene pruebas claras', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      witnessed ? 'Si el sospechoso es asesino, será detenido.' : 'La acusación contará como falsa.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    activeColor: const Color(0xFFB43C4B),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final message = game.arrestPlayer(
                          agentId: agentId,
                          suspectId: suspectId,
                          witnessed: witnessed,
                        );
                        Navigator.pop(context);
                        setState(() {});
                        _snack(message);
                      },
                      style: _mainButtonStyle(),
                      child: const Text('Confirmar detención'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAuctionDialog() async {
    final lot = game.drawAuctionLot();
    final bidders = game.players.where((p) => p.isAlive).toList();
    final controllers = {for (final p in bidders) p.id: TextEditingController()};

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subasta: ${lot.name}',
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valor del lote: ${lot.value}€',
                      style: const TextStyle(color: Color(0xFFE8D7B0)),
                    ),
                    const SizedBox(height: 16),
                    ...bidders.map(
                          (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: controllers[player.id],
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: '${player.name} · ${player.money}€ disponibles',
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          for (final player in bidders) {
                            final raw = controllers[player.id]!.text.trim();
                            final amount = int.tryParse(raw);
                            if (amount != null) {
                              game.placeBid(playerId: player.id, amount: amount);
                            }
                          }
                          final message = game.resolveAuction();
                          Navigator.pop(context);
                          setState(() {});
                          _snack(message);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB43C4B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: const Text('Cerrar subasta'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Widget _darkDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.72))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A1D),
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white70,
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
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildCurrentPhase(),
        ),
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  final String text;

  const _RuleLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(
              Icons.circle,
              size: 8,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.78),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double opacity;

  _GrainPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity);
    const step = 16.0;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final radius = ((x * y) % 5) / 10 + 0.2;
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}