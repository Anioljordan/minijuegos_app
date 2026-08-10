import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../widgets/app_logo_button.dart';

class MonedaScreen extends StatefulWidget {
  const MonedaScreen({super.key});

  @override
  State<MonedaScreen> createState() =>
      _CaraCruzScreenState();
}

class _CaraCruzScreenState extends State<MonedaScreen>
    with SingleTickerProviderStateMixin {
  final math.Random _random = math.Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentYellow = Color(0xFFFFD166);

  late final AnimationController _controller;
  late Animation<double> _coinAnimation;

  double _currentAngle = 0;

  String _result = '';
  bool _isFlipping = false;

  bool get _isNarrowScreen =>
      MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen =>
      MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 ||
          _isNarrowScreen;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _coinAnimation = AlwaysStoppedAnimation(
      _currentAngle,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _singleLineResponsiveText(
      String text, {
        required TextStyle style,
        Alignment alignment = Alignment.center,
      }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: style,
      ),
    );
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      disabledBackgroundColor:
      appWhite.withOpacity(0.25),
      disabledForegroundColor:
      appBlue.withOpacity(0.45),
      elevation: 0,
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
    final compact =
        MediaQuery.of(context).size.height < 740;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () => Navigator.pop(context),
            ),

            circleButton(
              onTap: mostrarNormas,
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
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'moneda',
                      maxLines: 1,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 48,
                        height: 1.90,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 82,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    color:
                    appWhite.withOpacity(0.58),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: _singleLineResponsiveText(
                    title.toUpperCase(),
                    alignment: Alignment.centerLeft,
                    style: const TextStyle(
                      color: appWhite,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
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

  void mostrarNormas() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) {
        final size = MediaQuery.sizeOf(context);
        final narrow = size.width < 380;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: narrow ? 14 : 22,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              narrow ? 16 : 20,
              20,
              narrow ? 16 : 20,
              18,
            ),
            decoration: BoxDecoration(
              color: appBlue,
              border: Border.all(
                color: appWhite.withOpacity(0.75),
                width: 2.2,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.78,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: narrow ? 46 : 52,
                          height: narrow ? 46 : 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                              appWhite.withOpacity(0.85),
                              width: 2.1,
                            ),
                          ),
                          child: Icon(
                            Icons.question_mark_rounded,
                            color: appWhite,
                            size: narrow ? 25 : 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: _singleLineResponsiveText(
                            'normas',
                            alignment:
                            Alignment.centerLeft,
                            style: TextStyle(
                              color: appWhite,
                              fontSize:
                              narrow ? 32 : 38,
                              height: 0.9,
                              fontWeight:
                              FontWeight.w900,
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

                    SizedBox(
                      width: double.infinity,
                      child: _singleLineResponsiveText(
                        'CARA O CRUZ',
                        alignment: Alignment.centerLeft,
                        style: const TextStyle(
                          color: appWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    rulesItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Haz una pregunta',
                      text:
                      'La persona que tiene la moneda hace una pregunta al grupo, por ejemplo: “¿Quién crees que es el más inteligente?”.',
                    ),

                    rulesItem(
                      icon: Icons.forward_rounded,
                      title: 'Pasa la moneda',
                      text:
                      'La persona a la que se le hace la pregunta pasa la moneda a quien crea que es la respuesta.',
                    ),

                    rulesItem(
                      icon: Icons.paid_rounded,
                      title: 'Lanza la moneda',
                      text:
                      'Después de elegir a la persona, se lanza la moneda para decidir si la respuesta se dice o no.',
                    ),

                    rulesItem(
                      icon: Icons.visibility_rounded,
                      title: 'Si sale cara',
                      text:
                      'La respuesta se dice en voz alta y todo el grupo sabrá a quién ha elegido.',
                    ),

                    rulesItem(
                      icon: Icons.visibility_off_rounded,
                      title: 'Si sale cruz',
                      text:
                      'La respuesta no se dice. Solo la sabrán la persona que ha preguntado y la persona que ha respondido.',
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(context),
                        style: mainButtonStyle(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'ENTENDIDO',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
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
        );
      },
    );
  }

  Future<void> lanzarMoneda() async {
    if (_isFlipping) return;

    final bool cara = _random.nextBool();

    final bool currentlyShowingCara =
        math.cos(_currentAngle) >= 0;

    final bool needsHalfTurn =
        cara != currentlyShowingCara;

    final extraRotation =
        (math.pi * 8) +
            (needsHalfTurn ? math.pi : 0);

    final targetAngle =
        _currentAngle + extraRotation;

    setState(() {
      _isFlipping = true;
      _result = '';
    });

    _coinAnimation = Tween<double>(
      begin: _currentAngle,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.reset();

    await _controller.forward();

    if (!mounted) return;

    setState(() {
      _currentAngle = targetAngle;
      _result = cara ? 'CARA' : 'CRUZ';
      _isFlipping = false;
    });
  }

  Widget _coinFace({
    required bool cara,
    required double size,
  }) {
    final borderWidth = size < 180 ? 4.0 : 5.0;
    final ringInset = size < 180 ? 10.0 : 13.0;
    final innerInset = size < 180 ? 22.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4B0),
            Color(0xFFFFD166),
            Color(0xFFE3A72F),
            Color(0xFFFFE08A),
          ],
          stops: [0.0, 0.28, 0.72, 1.0],
        ),
        border: Border.all(
          color: const Color(0xFFFFF7D6),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFFFD166).withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(ringInset),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB27A18),
                    width: 2.2,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFE590),
                      Color(0xFFF2BA49),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(innerInset),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.2, -0.3),
                    radius: 0.95,
                    colors: [
                      Color(0xFFFFF7C8),
                      Color(0xFFFFD86A),
                      Color(0xFFE0A22D),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFB27A18),
                    width: 1.8,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: size * 0.16,
            left: size * 0.18,
            right: size * 0.18,
            child: Container(
              height: size * 0.10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.65),
                    Colors.white.withOpacity(0.10),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.34,
                  height: size * 0.34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF3BF).withOpacity(0.35),
                    border: Border.all(
                      color: const Color(0xFFB27A18).withOpacity(0.65),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    cara
                        ? Icons.record_voice_over_rounded
                        : Icons.visibility_off_rounded,
                    color: appBlue.withOpacity(0.92),
                    size: size * 0.16,
                  ),
                ),

                SizedBox(height: size * 0.045),

                Text(
                  cara ? 'CARA' : 'CRUZ',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appBlue.withOpacity(0.95),
                    fontSize: size * 0.115,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                  ),
                ),

                SizedBox(height: size * 0.018),

                Text(
                  cara ? 'SE DICE' : 'SECRETO',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appBlue.withOpacity(0.68),
                    fontSize: size * 0.055,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCoin() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxAllowed =
        _isVeryNarrowScreen ? 190.0 : 235.0;

        final size = math.min(
          constraints.maxWidth * 0.72,
          maxAllowed,
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final angle = _controller.isAnimating
                ? _coinAnimation.value
                : _currentAngle;

            final showingCara =
                math.cos(angle) >= 0;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..rotateY(
                    showingCara ? 0 : math.pi,
                  ),
                child: _coinFace(
                  cara: showingCara,
                  size: size,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildGameArea({
    required bool compact,
  }) {
    return Expanded(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: _isVeryNarrowScreen ? 6 : 12,
            vertical: compact ? 12 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildCoin(),

              SizedBox(
                height: compact ? 22 : 30,
              ),

              AnimatedSwitcher(
                duration:
                const Duration(milliseconds: 220),
                child: _isFlipping
                    ? SizedBox(
                  key: const ValueKey('flipping'),
                  width: double.infinity,
                  child: _singleLineResponsiveText(
                    'LANZANDO...',
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: appWhite.withOpacity(0.65),
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                )
                    : _result.isEmpty
                    ? Column(
                  key: const ValueKey('empty'),
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: _singleLineResponsiveText(
                        'HAZ UNA PREGUNTA Y PASA LA MONEDA',
                        alignment: Alignment.center,
                        style: TextStyle(
                          color: appWhite.withOpacity(0.65),
                          fontSize: compact ? 11.5 : 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cara = se dice · Cruz = secreto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.52),
                        fontSize: compact ? 11 : 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
                    : Column(
                  key: ValueKey(_result),
                  children: [
                    Text(
                      'HA SALIDO',
                      style: TextStyle(
                        color: appWhite.withOpacity(0.62),
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      child: _singleLineResponsiveText(
                        _result,
                        alignment: Alignment.center,
                        style: TextStyle(
                          color: accentYellow,
                          fontSize: compact ? 40 : 50,
                          height: 0.9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _result == 'CARA'
                          ? 'La respuesta se dice'
                          : 'La respuesta queda en secreto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appWhite.withOpacity(0.72),
                        fontSize: compact ? 12 : 13,
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

  Widget buildThrowButton({
    required bool compact,
  }) {
    return SizedBox(
      width: double.infinity,
      height: compact ? 58 : 66,
      child: ElevatedButton(
        onPressed:
        _isFlipping ? null : lanzarMoneda,
        style: mainButtonStyle(),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal:
            _isVeryNarrowScreen ? 8 : 16,
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.casino_rounded,
                size: compact ? 22 : 26,
              ),

              SizedBox(
                width:
                _isVeryNarrowScreen ? 6 : 9,
              ),

              Expanded(
                child: _singleLineResponsiveText(
                  _isFlipping
                      ? 'LANZANDO'
                      : 'LANZAR MONEDA',
                  alignment: Alignment.center,
                  style: TextStyle(
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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
            final narrow =
                constraints.maxWidth < 380;

            final veryNarrow =
                constraints.maxWidth < 340;

            final compact =
                constraints.maxHeight < 740 ||
                    narrow;

            final horizontalPadding =
            veryNarrow
                ? 8.0
                : compact
                ? 12.0
                : 18.0;

            final verticalPadding =
            compact ? 10.0 : 18.0;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                compact ? 10 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(),

                  SizedBox(
                    height: compact ? 8 : 14,
                  ),

                  buildGameArea(
                    compact: compact,
                  ),

                  SizedBox(
                    height: compact ? 8 : 12,
                  ),

                  buildThrowButton(
                    compact: compact,
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