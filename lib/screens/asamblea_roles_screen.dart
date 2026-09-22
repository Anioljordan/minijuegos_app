import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'asamblea_setup_screen.dart';
import 'asamblea_board_screen.dart';
import '../widgets/asamblea_rules_dialog.dart';
import '../widgets/app_logo_button.dart';

class AsambleaRolesScreen extends StatefulWidget {
  final List<AsambleaPlayer> players;

  const AsambleaRolesScreen({
    super.key,
    required this.players,
  });

  @override
  State<AsambleaRolesScreen> createState() => _AsambleaRolesScreenState();
}

class _AsambleaRolesScreenState extends State<AsambleaRolesScreen> {
  int currentIndex = 0;

  double secretCardDragOffset = 0;

  static const double maxRevealOffset = 260;

  // NUEVO:
  // Nos permite saber dónde está realmente la tarjeta
  // aunque visualmente esté desplazada fuera del panel.
  final GlobalKey _secretCardKey = GlobalKey();

  // NUEVO:
  // Mientras este valor sea true, el arrastre exterior
  // seguirá funcionando aunque la tarjeta deje de estar
  // completamente abierta durante el movimiento.
  bool _draggingRaisedSecretCard = false;
  bool _roleHasBeenRevealed = false;
  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color leftBlue = Color(0xFF60A5FA);
  static const Color rightRed = Color(0xFFE63946);
  static const Color leaderGold = Color(0xFFFFD166);

  double get secretRevealProgress {
    return (-secretCardDragOffset / maxRevealOffset).clamp(0.0, 1.0);
  }

  bool get roleVisibleEnough {
    return secretRevealProgress >= 0.88;
  }

  String _roleTitle(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Izquierda';

      case AsambleaRole.derecha:
        return 'Derecha';

      case AsambleaRole.liderOculto:
        return 'Dictador';

      default:
        return '';
    }
  }

  String _roleDescription(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return 'Tu objetivo es aprobar 5 leyes de izquierda o eliminar al Líder Oculto.';

      case AsambleaRole.derecha:
        return 'Tu objetivo es aprobar 6 leyes de derecha o ayudar al Líder Oculto a llegar al poder.';

      case AsambleaRole.liderOculto:
        return 'Eres el Dictador. Debes llegar al poder sin que te descubran.';

      default:
        return '';
    }
  }

  Color _roleColor(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return leftBlue;

      case AsambleaRole.derecha:
        return rightRed;

      case AsambleaRole.liderOculto:
        return leaderGold;

      default:
        return appWhite;
    }
  }

  IconData _roleIcon(AsambleaRole? role) {
    switch (role) {
      case AsambleaRole.izquierda:
        return Icons.shield_outlined;

      case AsambleaRole.derecha:
        return Icons.gavel_outlined;

      case AsambleaRole.liderOculto:
        return Icons.visibility_off_outlined;

      default:
        return Icons.help_outline;
    }
  }

  // =========================================================
  // ARRASTRE DE LA TARJETA
  // =========================================================

  void _updateSecretCardDrag(DragUpdateDetails details) {
    setState(() {
      secretCardDragOffset =
          (secretCardDragOffset + details.delta.dy).clamp(
            -maxRevealOffset,
            0.0,
          );

      // Una vez revelado el rol, el botón queda habilitado.
      if (secretRevealProgress >= 0.88) {
        _roleHasBeenRevealed = true;
      }
    });
  }

  void _finishSecretCardDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    setState(() {
      // Swipe claro hacia arriba.
      if (velocity < -500) {
        secretCardDragOffset = -maxRevealOffset;
        return;
      }

      // Swipe claro hacia abajo.
      if (velocity > 500) {
        secretCardDragOffset = 0;
        return;
      }

      // Si no ha habido mucha velocidad,
      // usamos la mitad de la tarjeta para decidir.
      if (secretCardDragOffset <= -(maxRevealOffset / 2)) {
        secretCardDragOffset = -maxRevealOffset;
      } else {
        secretCardDragOffset = 0;
      }
    });
  }

  // Comprueba si el dedo ha empezado realmente
  // encima de la tarjeta desplazada.
  bool _isPointInsideSecretCard(Offset globalPosition) {
    final cardContext = _secretCardKey.currentContext;

    if (cardContext == null) {
      return false;
    }

    final renderObject = cardContext.findRenderObject();

    if (renderObject is! RenderBox) {
      return false;
    }

    final topLeft = renderObject.localToGlobal(
      Offset.zero,
    );

    final bottomRight = renderObject.localToGlobal(
      Offset(
        renderObject.size.width,
        renderObject.size.height,
      ),
    );

    final cardRect = Rect.fromPoints(
      topLeft,
      bottomRight,
    );

    return cardRect.contains(globalPosition);
  }

  void _globalSecretDragStart(
      DragStartDetails details,
      ) {
    // Solo necesitamos este detector especial cuando
    // la tarjeta ya está arriba.
    if (!roleVisibleEnough) {
      _draggingRaisedSecretCard = false;
      return;
    }

    _draggingRaisedSecretCard =
        _isPointInsideSecretCard(
          details.globalPosition,
        );
  }

  void _globalSecretDragUpdate(
      DragUpdateDetails details,
      ) {
    if (!_draggingRaisedSecretCard) {
      return;
    }

    _updateSecretCardDrag(details);
  }

  void _globalSecretDragEnd(
      DragEndDetails details,
      ) {
    if (!_draggingRaisedSecretCard) {
      return;
    }

    // Primero indicamos que ha terminado el gesto.
    // Después _finishSecretCardDrag hace setState(),
    // así el siguiente build ya verá false.
    _draggingRaisedSecretCard = false;

    _finishSecretCardDrag(details);
  }

  void _globalSecretDragCancel() {
    if (!_draggingRaisedSecretCard) {
      return;
    }

    setState(() {
      _draggingRaisedSecretCard = false;

      // Si se cancela el gesto, tampoco dejamos
      // la tarjeta a medio camino.
      if (secretCardDragOffset <=
          -(maxRevealOffset / 2)) {
        secretCardDragOffset =
        -maxRevealOffset;
      } else {
        secretCardDragOffset = 0;
      }
    });
  }

  // =========================================================

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
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget buildTopBar({
    required bool compact,
  }) {
    final titleSize =
    compact ? 34.0 : 42.0;

    final titleHeight =
    compact ? 70.0 : 92.0;

    final lineTop =
    compact ? 40.0 : 60.0;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () =>
                  Navigator.pop(context),
            ),

            Row(
              children: [
                circleButton(
                  compact: compact,
                  onTap: () =>
                      showAsambleaRulesDialog(
                        context,
                      ),
                  child: Icon(
                    Icons.question_mark_rounded,
                    color: appWhite,
                    size:
                    compact ? 23 : 27,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(
          height: compact ? 14 : 24,
        ),

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
                    alignment:
                    Alignment.topRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                      Alignment.topRight,
                      child: Text(
                        'reparto de roles',
                        maxLines: 1,
                        textAlign:
                        TextAlign.right,
                        style: TextStyle(
                          color: appWhite,
                          fontSize:
                          titleSize,
                          height: 1.9,
                          fontWeight:
                          FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: lineTop,
                  left:
                  compact ? -13 : -18,
                  right: 0,
                  child: Container(
                    height: 3,
                    color: appWhite
                        .withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecretRoleContent({
    required AsambleaPlayer player,
    required AsambleaRole? role,
    required bool compact,
  }) {
    final roleColor =
    _roleColor(role);

    final progress =
        secretRevealProgress;

    return AnimatedOpacity(
      duration:
      const Duration(milliseconds: 110),
      opacity:
      0.08 + (progress * 0.92),
      child: Transform.scale(
        scale:
        0.96 + (progress * 0.04),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: compact ? 78 : 98,
              height: compact ? 78 : 98,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: roleColor
                    .withOpacity(0.18),
                border: Border.all(
                  color: roleColor,
                  width: 2.7,
                ),
              ),
              child: Icon(
                _roleIcon(role),
                color: roleColor,
                size: compact ? 40 : 50,
              ),
            ),

            SizedBox(
              height: compact ? 16 : 22,
            ),

            Text(
              'TU ROL',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: appWhite
                    .withOpacity(0.62),
                fontSize:
                compact ? 10.5 : 12,
                fontWeight:
                FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),

            const SizedBox(height: 9),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr(
                  _roleTitle(role),
                ).toLowerCase(),
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize:
                  compact ? 35 : 44,
                  height: 0.94,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),

            SizedBox(
              height: compact ? 14 : 18,
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                compact ? 12 : 15,
              ),
              decoration: BoxDecoration(
                color: appWhite
                    .withOpacity(0.08),
                border: Border(
                  left: BorderSide(
                    color: roleColor,
                    width: 6,
                  ),
                  bottom: BorderSide(
                    color: appWhite
                        .withOpacity(0.28),
                    width: 2,
                  ),
                  top: BorderSide(
                    color: appWhite
                        .withOpacity(0.16),
                  ),
                  right: BorderSide(
                    color: appWhite
                        .withOpacity(0.16),
                  ),
                ),
              ),
              child: Text(
                _roleDescription(role),
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: appWhite
                      .withOpacity(0.82),
                  fontSize:
                  compact ? 13 : 14,
                  height: 1.35,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            SizedBox(
              height: compact ? 12 : 16,
            ),

            Text(
              'Baja la tarjeta para ocultarlo antes de pasar el móvil.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: appWhite
                    .withOpacity(0.52),
                fontSize:
                compact ? 11.5 : 12.5,
                height: 1.25,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretCover({
    required AsambleaPlayer player,
    required AsambleaRole? role,
    required bool compact,
  }) {
    final progress = secretRevealProgress;

    // La tarjeta cerrada SIEMPRE tiene el mismo color.
    const cardColor = appWhite;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
      offset: Offset(
        0,
        -0.88 * progress,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: _updateSecretCardDrag,
        onVerticalDragEnd: _finishSecretCardDrag,
        child: Container(
          key: _secretCardKey,
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 22,
            vertical: compact ? 18 : 24,
          ),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: cardColor.withOpacity(0.88),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.withOpacity(0.16),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 78 : 96,
                height: compact ? 78 : 96,
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: cardColor.withOpacity(0.88),
                    width: 2.6,
                  ),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: cardColor,
                  size: compact ? 39 : 48,
                ),
              ),

              SizedBox(
                height: compact ? 18 : 24,
              ),

              Text(
                'TARJETA SECRETA',
                style: TextStyle(
                  color: appWhite.withOpacity(0.58),
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 9),

              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player.name.toLowerCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appWhite,
                    fontSize: compact ? 40 : 52,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
              ),

              SizedBox(
                height: compact ? 20 : 26,
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 12 : 15,
                  vertical: compact ? 12 : 14,
                ),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.26),
                    width: 1.4,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: appWhite.withOpacity(0.88),
                      size: compact ? 30 : 34,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'ARRASTRA DESDE AQUÍ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: compact ? 13 : 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'sube para revelar · baja para ocultar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.62),
                        fontSize: compact ? 11.5 : 12.5,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMainCard(
      AsambleaPlayer player,
      AsambleaRole? role, {
        required bool compact,
      }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.08),

        // Siempre blanco/neutro.
        border: Border.all(
          color: appWhite.withOpacity(0.32),
          width: 1.6,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 18 : 24,
                vertical: compact ? 18 : 28,
              ),
              child: SizedBox(
                height: compact ? 430 : 500,
                child: _buildSecretRoleContent(
                  player: player,
                  role: role,
                  compact: compact,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: _buildSecretCover(
              player: player,
              role: role,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (!_roleHasBeenRevealed) {
      return;
    }

    if (currentIndex < widget.players.length - 1) {
      setState(() {
        currentIndex++;

        secretCardDragOffset = 0;
        _draggingRaisedSecretCard = false;

        // El siguiente jugador todavía no ha visto su rol.
        _roleHasBeenRevealed = false;
      });

      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AsambleaBoardScreen(
          players: widget.players,
        ),
      ),
    );
  }

  Widget _buildNextButton({
    required bool compact,
    required AsambleaRole? role,
  }) {
    // Ya no depende de que la tarjeta esté actualmente levantada.
    // Solo importa que el jugador haya revelado su rol al menos una vez.
    final enabled = _roleHasBeenRevealed;

    final color = enabled
        ? appWhite
        : appWhite.withOpacity(0.16);

    final foreground = enabled
        ? appBlue
        : appWhite.withOpacity(0.50);

    final icon = !enabled
        ? Icons.keyboard_double_arrow_up_rounded
        : currentIndex == widget.players.length - 1
        ? Icons.play_arrow_rounded
        : Icons.arrow_forward_rounded;

    final label = !enabled
        ? 'ARRASTRA LA TARJETA'
        : currentIndex == widget.players.length - 1
        ? 'EMPEZAR PARTIDA'
        : 'SIGUIENTE JUGADOR';

    return SizedBox(
      width: double.infinity,
      height: compact ? 70 : 82,
      child: Material(
        color: color,
        child: InkWell(
          onTap: enabled ? _nextStep : null,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: appWhite.withOpacity(
                  enabled ? 0.30 : 0.16,
                ),
                width: 2.3,
              ),
              boxShadow: enabled
                  ? [
                BoxShadow(
                  color: appWhite.withOpacity(0.16),
                  blurRadius: 17,
                  offset: const Offset(0, 8),
                ),
              ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: foreground,
                  size: compact ? 31 : 37,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foreground,
                      fontSize: compact ? 13.5 : 15.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player =
    widget.players[currentIndex];

    final role =
        player.role;

    // Mientras la tarjeta esté suficientemente abierta
    // O mientras YA estemos arrastrando desde fuera del panel,
    // mantenemos el detector global activo.
    //
    // Esto es lo que evita que deje de responder
    // al bajar los primeros 20-30 px.
    final globalDragEnabled =
        roleVisibleEnough ||
            _draggingRaisedSecretCard;

    return Scaffold(
      backgroundColor: appBlue,

      body: GestureDetector(
        behavior:
        HitTestBehavior.translucent,

        onVerticalDragStart:
        globalDragEnabled
            ? _globalSecretDragStart
            : null,

        onVerticalDragUpdate:
        globalDragEnabled
            ? _globalSecretDragUpdate
            : null,

        onVerticalDragEnd:
        globalDragEnabled
            ? _globalSecretDragEnd
            : null,

        onVerticalDragCancel:
        globalDragEnabled
            ? _globalSecretDragCancel
            : null,

        child: SafeArea(
          child: LayoutBuilder(
            builder:
                (context, constraints) {
              final compact =
                  constraints.maxHeight <
                      740;

              final horizontalPadding =
              compact ? 13.0 : 18.0;

              final verticalPadding =
              compact ? 11.0 : 18.0;

              return Padding(
                padding:
                EdgeInsets.fromLTRB(
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
                      height:
                      compact ? 10 : 16,
                    ),

                    Expanded(
                      child:
                      buildMainCard(
                        player,
                        role,
                        compact: compact,
                      ),
                    ),

                    SizedBox(
                      height:
                      compact ? 10 : 14,
                    ),

                    _buildNextButton(
                      compact: compact,
                      role: role,
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