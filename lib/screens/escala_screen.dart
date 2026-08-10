import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/escala_data.dart';
import '../widgets/app_logo_button.dart';

class EscalaScreen extends StatefulWidget {
  const EscalaScreen({super.key});

  @override
  State<EscalaScreen> createState() => _EscalaScreenState();
}

class _EscalaScreenState extends State<EscalaScreen> {
  final math.Random random = math.Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentRed = Color(0xFFE63946);

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
        Alignment alignment = Alignment.center,
      }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }

  final TextEditingController izquierdaController = TextEditingController();
  final TextEditingController derechaController = TextEditingController();
  final TextEditingController respuestaController = TextEditingController();

  late Map<String, String> escalaActual;

  List<Map<String, String>> escalasGuardadas = [];

  int valorReal = 50;
  double valorAdivinado = 50;
  String respuestaJugador1 = '';

  bool escalaActualEsPersonalizada = false;

  int fase = 0;

  @override
  void initState() {
    super.initState();
    inicializarPantalla();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
    });
  }

  @override
  void dispose() {
    izquierdaController.dispose();
    derechaController.dispose();
    respuestaController.dispose();
    super.dispose();
  }

  Future<void> inicializarPantalla() async {
    await cargarEscalasGuardadas();

    escalaActual = escalasJuego[random.nextInt(escalasJuego.length)];
    valorReal = random.nextInt(101);
    valorAdivinado = 50;
    respuestaJugador1 = '';
    izquierdaController.clear();
    derechaController.clear();
    respuestaController.clear();
    escalaActualEsPersonalizada = false;
    fase = 0;

    if (mounted) setState(() {});
  }

  Future<void> cargarEscalasGuardadas() async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('escalas_guardadas') ?? [];

    escalasGuardadas = lista.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return {
        'izquierda': decoded['izquierda'] as String,
        'derecha': decoded['derecha'] as String,
      };
    }).toList();
  }

  Future<void> guardarEscalaActual() async {
    if (!escalaActualEsPersonalizada) return;

    final yaExiste = escalasGuardadas.any(
          (e) =>
      e['izquierda'] == escalaActual['izquierda'] &&
          e['derecha'] == escalaActual['derecha'],
    );

    if (yaExiste) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta escala ya está guardada')),
      );
      return;
    }

    escalasGuardadas.add({
      'izquierda': escalaActual['izquierda']!,
      'derecha': escalaActual['derecha']!,
    });

    final prefs = await SharedPreferences.getInstance();
    final encoded = escalasGuardadas.map((e) => jsonEncode(e)).toList();

    await prefs.setStringList('escalas_guardadas', encoded);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Escala guardada')),
    );

    setState(() {});
  }

  void nuevaRondaMismaEscala() {
    setState(() {
      valorReal = random.nextInt(101);
      valorAdivinado = 50;
      respuestaJugador1 = '';
      respuestaController.clear();
      fase = 1;
    });
  }

  void volverAElegirEscala() {
    setState(() {
      valorReal = random.nextInt(101);
      valorAdivinado = 50;
      respuestaJugador1 = '';
      respuestaController.clear();
      izquierdaController.clear();
      derechaController.clear();
      fase = 0;
    });
  }

  void usarEscalaAleatoria() {
    setState(() {
      escalaActual = escalasJuego[random.nextInt(escalasJuego.length)];
      escalaActualEsPersonalizada = false;
      valorReal = random.nextInt(101);
      valorAdivinado = 50;
      respuestaJugador1 = '';
      respuestaController.clear();
      fase = 1;
    });
  }

  void usarEscalaPersonalizada() {
    final izquierda = izquierdaController.text.trim();
    final derecha = derechaController.text.trim();

    if (izquierda.isEmpty || derecha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena los dos extremos')),
      );
      return;
    }

    setState(() {
      escalaActual = {
        'izquierda': izquierda,
        'derecha': derecha,
      };
      escalaActualEsPersonalizada = true;
      valorReal = random.nextInt(101);
      valorAdivinado = 50;
      respuestaJugador1 = '';
      respuestaController.clear();
      fase = 1;
    });
  }

  void usarEscalaGuardada(Map<String, String> escala) {
    setState(() {
      escalaActual = escala;
      escalaActualEsPersonalizada = true;
      valorReal = random.nextInt(101);
      valorAdivinado = 50;
      respuestaJugador1 = '';
      respuestaController.clear();
      fase = 1;
    });
  }

  void pasarAEscribirRespuesta() {
    setState(() {
      fase = 2;
    });
  }

  void confirmarRespuesta() {
    final texto = respuestaController.text.trim();

    setState(() {
      // Puede quedar vacío.
      respuestaJugador1 = texto;
      respuestaController.clear();

      // Va directamente a la pantalla de adivinar.
      fase = 3;
    });
  }



  void confirmarAdivinanza() {
    setState(() {
      fase = 4;
    });
  }

  int calcularDiferencia() {
    return (valorReal - valorAdivinado.round()).abs();
  }

  int calcularPuntos() {
    final d = calcularDiferencia();

    if (d <= 3) return 4;
    if (d <= 8) return 2;
    if (d <= 15) return 1;
    return 0;
  }

  String interpretarLado(int valor) {
    if (valor < 20) return 'muy hacia la izquierda';
    if (valor < 40) return 'tirando a la izquierda';
    if (valor <= 60) return 'bastante al centro';
    if (valor <= 80) return 'tirando a la derecha';
    return 'muy hacia la derecha';
  }
  ButtonStyle mainButtonStyle({
    Color color = appWhite,
  }) {
    final foreground = color == appWhite || color == accentYellow
        ? appBlue
        : appWhite;

    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: foreground,
      disabledBackgroundColor: color.withOpacity(0.28),
      disabledForegroundColor: foreground.withOpacity(0.45),
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
        child: Center(child: child),
      ),
    );
  }

  Widget buildTopBar({required bool compact}) {
    final titleSize = compact ? 34.0 : 42.0;
    final titleHeight = compact ? 48.0 : 58.0;

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
              onTap: mostrarNormas,
              child: Icon(
                Icons.question_mark_rounded,
                color: appWhite,
                size: compact ? 23 : 27,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 14 : 24),

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
                Align(
                  alignment: Alignment.topRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topRight,
                    child: Text(
                      'escala mental',
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: appWhite,
                        fontSize: titleSize,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: compact ? -13 : -18,
                  right: 0,
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



  Color _phaseColor() {
    switch (fase) {
      case 0:
        return accentPurple;

      case 1:
      case 2:
        return accentYellow;

      case 3:
        return accentGreen;

      case 4:
        return accentRed;

      default:
        return accentPurple;
    }
  }



  Widget buildInfoBar({
    required String text,
    Color color = accentPurple,
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

  Widget buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.all(
            veryNarrow
                ? 10
                : compact
                ? 13
                : 17,
          ),
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

  Widget buildFancyButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = appWhite,
    IconData? icon,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    final foreground =
    color == appWhite || color == accentYellow
        ? appBlue
        : appWhite;

    return SizedBox(
      width: double.infinity,
      height: compact ? 54 : 62,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonStyle(color: color),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: veryNarrow
                ? 7
                : compact
                ? 11
                : 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: foreground,
                  size: veryNarrow
                      ? 19
                      : compact
                      ? 21
                      : 24,
                ),

                SizedBox(
                  width: veryNarrow ? 5 : 9,
                ),
              ],

              Expanded(
                child: _singleLineResponsiveText(
                  text.toUpperCase(),
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: compact ? 12.5 : 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCustomField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: appWhite,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: appWhite,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: appWhite.withOpacity(0.62),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: appWhite.withOpacity(0.07),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      ),
    );
  }

  Widget sectionTitle(String text) {
    final compact = _isCompactScreen;

    return SizedBox(
      width: double.infinity,
      child: _singleLineResponsiveText(
        text.toLowerCase(),
        alignment: Alignment.center,
        style: TextStyle(
          color: appWhite,
          fontSize: compact ? 25 : 30,
          height: 0.95,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.7,
        ),
      ),
    );
  }
  Widget rulesItem({
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

  void mostrarNormas() {
    showDialog(
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
                    'ESCALA MENTAL',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.swap_horiz_rounded,
                    title: 'Elegid escala',
                    text:
                    'La escala tiene dos extremos. Por ejemplo: comida buenísima y comida horrible.',
                  ),

                  rulesItem(
                    icon: Icons.visibility_rounded,
                    title: 'Jugador 1 mira',
                    text:
                    'El jugador 1 ve una posición secreta entre 0 y 100.',
                  ),

                  rulesItem(
                    icon: Icons.edit_rounded,
                    title: 'Escribe pista',
                    text:
                    'Jugador 1 escribe una respuesta sin decir ningún número.',
                  ),

                  rulesItem(
                    icon: Icons.track_changes_rounded,
                    title: 'Jugador 2 adivina',
                    text:
                    'Jugador 2 coloca la aguja donde cree que estaba la posición.',
                  ),

                  rulesItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Puntuación',
                    text:
                    'Diferencia de 3 o menos = 4 puntos. De 8 o menos = 2. De 15 o menos = 1.',
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: mainButtonStyle(),
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

  void mostrarDialogoFinRonda() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                      Icons.flag_rounded,
                      color: appWhite,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'ronda',
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

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.26),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  '${escalaActual['izquierda']} ↔ ${escalaActual['derecha']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.82),
                    fontSize: 14,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              buildFancyButton(
                text: 'Seguir con esta escala',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  nuevaRondaMismaEscala();
                },
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  volverAElegirEscala();
                },
                style: secondaryButtonStyle(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'CAMBIAR ESCALA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),

              if (escalaActualEsPersonalizada) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await guardarEscalaActual();
                    if (!mounted) return;
                    mostrarDialogoFinRonda();
                  },
                  style: secondaryButtonStyle(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'GUARDAR ESCALA',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _valorDesdePosicion(
      Offset position,
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height - 10,
    );

    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    double angle = math.atan2(dy, dx);

    // atan2 devuelve valores negativos en la parte superior.
    // Los convertimos al rango 0 -> 2π.
    if (angle < 0) {
      angle += math.pi * 2;
    }

    // Nuestro medidor va desde:
    // izquierda = π
    // derecha   = 2π
    //
    // Si el dedo baja por debajo del semicírculo,
    // lo llevamos al extremo más cercano.
    if (angle < math.pi) {
      angle = dx < 0
          ? math.pi
          : math.pi * 2;
    }

    final value =
        ((angle - math.pi) / math.pi) * 100;

    return value.clamp(0.0, 100.0);
  }

  Widget buildMedidorSemicircular({
    int? valor,
    required bool mostrarNumero,
    int? valorSecundario,
    bool mostrarZonasPuntuacion = false,
    int? centroZonas,
    bool interactivo = false,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    final gaugeHeight = veryNarrow
        ? 145.0
        : compact
        ? 168.0
        : 225.0;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 5 : 8,
            compact ? 8 : 12,
            compact ? 5 : 8,
            compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.075),
            border: Border.all(
              color: appWhite.withOpacity(0.32),
              width: 1.6,
            ),
          ),
          child: SizedBox(
            height: gaugeHeight,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gaugeSize = Size(
                  constraints.maxWidth,
                  gaugeHeight,
                );

                void actualizar(Offset position) {
                  if (!interactivo) return;

                  final nuevoValor =
                  _valorDesdePosicion(
                    position,
                    gaugeSize,
                  );

                  setState(() {
                    valorAdivinado =
                        nuevoValor;
                  });
                }

                return GestureDetector(
                  behavior:
                  HitTestBehavior.opaque,

                  onTapDown: interactivo
                      ? (details) {
                    actualizar(
                      details.localPosition,
                    );
                  }
                      : null,

                  onPanStart: interactivo
                      ? (details) {
                    actualizar(
                      details.localPosition,
                    );
                  }
                      : null,

                  onPanUpdate: interactivo
                      ? (details) {
                    actualizar(
                      details.localPosition,
                    );
                  }
                      : null,

                  child: CustomPaint(
                    size: gaugeSize,
                    painter:
                    NeedleGaugePainter(
                      valorPrincipal:
                      valor?.toDouble(),
                      valorSecundario:
                      valorSecundario
                          ?.toDouble(),
                      mostrarZonasPuntuacion:
                      mostrarZonasPuntuacion,
                      centroZonas:
                      (centroZonas ??
                          valor ??
                          valorSecundario ??
                          50)
                          .toDouble(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 11),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                escalaActual['izquierda']!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 11.5 : 13.5,
                  height: 1.1,
                ),
              ),
            ),
            SizedBox(width: compact ? 14 : 20),
            Expanded(
              child: Text(
                escalaActual['derecha']!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 11.5 : 13.5,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 7 : 9),

        if (interactivo) ...[
          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_rounded,
                color:
                appWhite.withOpacity(0.48),
                size: compact ? 15 : 17,
              ),

              const SizedBox(width: 6),

              Text(
                'ARRASTRA LA AGUJA',
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color:
                  appWhite.withOpacity(0.48),
                  fontSize:
                  compact ? 10 : 11,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),

          SizedBox(
            height: compact ? 7 : 9,
          ),
        ],

        if (mostrarNumero && valor != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 7 : 9,
            ),
            decoration: BoxDecoration(
              color: accentYellow,
              border: Border.all(
                color: appWhite.withOpacity(0.55),
                width: 1.5,
              ),
            ),
            child: _singleLineResponsiveText(
              'POSICIÓN $valor',
              alignment: Alignment.center,
              style: TextStyle(
                color: appBlue,
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildInfoPill({
    required IconData icon,
    required String title,
    required String text,
  }) {
    final compact = _isCompactScreen;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 9 : 11,
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
              icon,
              color: appWhite,
              size: compact ? 21 : 23,
            ),

            const SizedBox(height: 7),

            SizedBox(
              width: double.infinity,
              child: _singleLineResponsiveText(
                title.toUpperCase(),
                alignment: Alignment.center,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            const SizedBox(height: 4),

            Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: appWhite.withOpacity(0.65),
                fontSize: compact ? 9.5 : 10.5,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPantallaElegirEscala() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          buildFancyButton(
            text: 'Usar escala aleatoria',
            color: appWhite,
            icon: Icons.casino_rounded,
            onPressed: usarEscalaAleatoria,
          ),

          const SizedBox(height: 14),

          buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                sectionTitle('Personalizada'),

                const SizedBox(height: 8),

                Text(
                  'Ejemplo: “Comida buenísima” ↔ “Comida horrible”',
                  style: TextStyle(
                    color: appWhite.withOpacity(0.65),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                buildCustomField(
                  controller: izquierdaController,
                  label: 'Extremo izquierdo',
                ),

                const SizedBox(height: 12),

                buildCustomField(
                  controller: derechaController,
                  label: 'Extremo derecho',
                ),

                const SizedBox(height: 16),

                buildFancyButton(
                  text: 'Usar esta escala',
                  color: appBlue,
                  icon: Icons.play_arrow_rounded,
                  onPressed: usarEscalaPersonalizada,
                ),
              ],
            ),
          ),

          if (escalasGuardadas.isNotEmpty) ...[
            const SizedBox(height: 16),
            sectionTitle('Guardadas'),
            const SizedBox(height: 10),
            ...escalasGuardadas.map(
                  (escala) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () => usarEscalaGuardada(escala),
                  style: secondaryButtonStyle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      '${escala['izquierda']} ↔ ${escala['derecha']}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _isCompactScreen ? 11.5 : 13,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildPantallaInicioJugador1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              sectionTitle('Jugador 1'),

              const SizedBox(height: 8),

              Text(
                'Mira la posición secreta y piensa una respuesta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              buildMedidorSemicircular(
                valor: valorReal,
                mostrarNumero: true,
              ),

              const SizedBox(height: 14),

              Text(
                'Tu posición está ${interpretarLado(valorReal)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: appWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Continuar',
          color: accentYellow,
          icon: Icons.arrow_forward_rounded,
          onPressed: pasarAEscribirRespuesta,
        ),
      ],
    );
  }

  Widget buildPantallaRespuesta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              sectionTitle('Escribe pista'),

              const SizedBox(height: 8),

              Text(
                'Escribe una pista que encaje con la posición o déjala vacía.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              buildMedidorSemicircular(
                valor: null,
                mostrarNumero: false,
              ),

              const SizedBox(height: 16),

              buildCustomField(
                controller: respuestaController,
                label: 'Tu respuesta',
                maxLines: 2,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Confirmar respuesta',
          color: accentYellow,
          icon: Icons.check_rounded,
          onPressed: confirmarRespuesta,
        ),
      ],
    );
  }

  Widget buildPantallaAdivinar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              sectionTitle('Jugador 2'),

              const SizedBox(height: 8),

              Text(
                '¿Dónde crees que estaba la respuesta?',
                style: TextStyle(
                  color: appWhite.withOpacity(0.70),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.28),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  respuestaJugador1.isEmpty
                      ? 'SIN PISTA'
                      : '"$respuestaJugador1"',
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: appWhite,
                    fontSize: _isCompactScreen ? 21 : 25,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              buildMedidorSemicircular(
                valor: valorAdivinado.round(),
                mostrarNumero: true,
                interactivo: true,
              ),

            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Confirmar',
          color: accentGreen,
          icon: Icons.check_circle_rounded,
          onPressed: confirmarAdivinanza,
        ),
      ],
    );
  }

  Widget buildPantallaResultado() {
    final diferencia = calcularDiferencia();
    final puntos = calcularPuntos();
    final Color resultColor;
    final IconData resultIcon;
    final String resultMessage;

    switch (puntos) {
      case 4:
        resultColor = accentGreen;
        resultIcon = Icons.emoji_events_rounded;
        resultMessage = '¡CLAVADO!';
        break;

      case 2:
        resultColor = accentYellow;
        resultIcon = Icons.track_changes_rounded;
        resultMessage = '¡MUY CERCA!';
        break;

      case 1:
        resultColor = const Color(0xFFFFB86C);
        resultIcon = Icons.near_me_rounded;
        resultMessage = 'CASI';
        break;

      default:
        resultColor = accentRed;
        resultIcon = Icons.refresh_rounded;
        resultMessage = 'LEJOS';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              sectionTitle('Resultado'),

              const SizedBox(height: 16),

              buildMedidorSemicircular(
                valor: null,
                mostrarNumero: false,
                valorSecundario: valorAdivinado.round(),
                mostrarZonasPuntuacion: true,
                centroZonas: valorReal,
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: resultColor,
                  border: Border.all(
                    color: appWhite.withOpacity(0.72),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appWhite.withOpacity(0.18),
                        border: Border.all(
                          color: appWhite.withOpacity(0.55),
                          width: 1.6,
                        ),
                      ),
                      child: Icon(
                        resultIcon,
                        color: puntos == 2 ? appBlue : appWhite,
                        size: 27,
                      ),
                    ),

                    SizedBox(
                      width: _isVeryNarrowScreen ? 42 : 48,
                      height: _isVeryNarrowScreen ? 42 : 48,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: _singleLineResponsiveText(
                              resultMessage,
                              alignment: Alignment.centerLeft,
                              style: TextStyle(
                                color: puntos == 2
                                    ? appBlue
                                    : appWhite,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 3),

                          SizedBox(
                            width: double.infinity,
                            child: _singleLineResponsiveText(
                              '$puntos ${puntos == 1 ? 'PUNTO' : 'PUNTOS'}',
                              alignment: Alignment.centerLeft,
                              style: TextStyle(
                                color: puntos == 2
                                    ? appBlue
                                    : appWhite,
                                fontSize: _isCompactScreen ? 23 : 27,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: _singleLineResponsiveText(
                  'REAL: $valorReal · ADIVINADA: ${valorAdivinado.round()}',
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              SizedBox(
                width: double.infinity,
                child: _singleLineResponsiveText(
                  'DIFERENCIA: $diferencia',
                  alignment: Alignment.center,
                  style: TextStyle(
                    color: appWhite.withOpacity(0.82),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),


            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Terminar ronda',
          color: accentRed,
          icon: Icons.flag_rounded,
          onPressed: mostrarDialogoFinRonda,
        ),
      ],
    );
  }

  Widget buildContenido() {
    Widget contenido;

    switch (fase) {
      case 0:
        contenido = buildPantallaElegirEscala();
        break;

      case 1:
        contenido = buildPantallaInicioJugador1();
        break;

      case 2:
        contenido = buildPantallaRespuesta();
        break;

      case 3:
        contenido = buildPantallaAdivinar();
        break;

      case 4:
        contenido = buildPantallaResultado();
        break;

      default:
        contenido = buildPantallaElegirEscala();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,

      // Evita que AnimatedSwitcher centre el contenido verticalmente.
      layoutBuilder: (
          Widget? currentChild,
          List<Widget> previousChildren,
          ) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },

      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slide,
            child: child,
          ),
        );
      },

      child: Align(
        key: ValueKey(fase),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: SizedBox(
            width: double.infinity,
            child: contenido,
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

            final horizontalPadding = veryNarrow
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
                  buildTopBar(
                    compact: compact,
                  ),

                  SizedBox(
                    height: compact ? 7 : 10,
                  ),

                  Expanded(
                    child: buildContenido(),
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

class NeedleGaugePainter extends CustomPainter {
  final double? valorPrincipal;
  final double? valorSecundario;
  final bool mostrarZonasPuntuacion;
  final double centroZonas;

  NeedleGaugePainter({
    required this.valorPrincipal,
    this.valorSecundario,
    required this.mostrarZonasPuntuacion,
    required this.centroZonas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final outerRadius = math.min(size.width / 2 - 14, size.height - 14);
    final innerRadius = outerRadius * 0.42;

    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    drawFilledRingSegment(
      canvas,
      outerRect,
      innerRect,
      math.pi,
      math.pi,
      const Color(0xFFC8FFF8),
    );

    if (mostrarZonasPuntuacion) {
      drawZonaRellenaConTexto(
        canvas,
        center,
        outerRadius,
        innerRadius,
        centroZonas - 15,
        centroZonas - 9,
        const Color(0xFFFFE45E),
        '1',
      );

      drawZonaRellenaConTexto(
        canvas,
        center,
        outerRadius,
        innerRadius,
        centroZonas - 8,
        centroZonas - 4,
        const Color(0xFFFFB84D),
        '2',
      );

      drawZonaRellenaConTexto(
        canvas,
        center,
        outerRadius,
        innerRadius,
        centroZonas - 3,
        centroZonas + 3,
        const Color(0xFFFF7A3D),
        '4',
      );

      drawZonaRellenaConTexto(
        canvas,
        center,
        outerRadius,
        innerRadius,
        centroZonas + 4,
        centroZonas + 8,
        const Color(0xFFFFB84D),
        '2',
      );

      drawZonaRellenaConTexto(
        canvas,
        center,
        outerRadius,
        innerRadius,
        centroZonas + 9,
        centroZonas + 15,
        const Color(0xFFFFE45E),
        '1',
      );
    }

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.12);

    canvas.drawArc(outerRect, math.pi, math.pi, false, borderPaint);
    canvas.drawArc(innerRect, math.pi, math.pi, false, borderPaint);

    if (valorPrincipal != null) {
      drawNeedle(
        canvas,
        center,
        outerRadius,
        valorPrincipal!,
        const Color(0xFFE11D48),
        5,
      );
    }

    if (valorSecundario != null) {
      drawNeedle(
        canvas,
        center,
        outerRadius,
        valorSecundario!,
        const Color(0xFFE11D48),
        5,
      );
    }

    final centroPaint = Paint()
      ..color = const Color(0xFFC21F3A)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 22, centroPaint);

    final bordeCentroPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 22, bordeCentroPaint);
  }

  void drawFilledRingSegment(
      Canvas canvas,
      Rect outerRect,
      Rect innerRect,
      double startAngle,
      double sweepAngle,
      Color color,
      ) {
    final path = Path()
      ..arcTo(outerRect, startAngle, sweepAngle, false)
      ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(path, paint);
  }

  void drawZonaRellenaConTexto(
      Canvas canvas,
      Offset center,
      double outerRadius,
      double innerRadius,
      double fromValue,
      double toValue,
      Color color,
      String texto,
      ) {
    final inicio = valueToAngle(fromValue.clamp(0, 100));
    final fin = valueToAngle(toValue.clamp(0, 100));
    final sweep = fin - inicio == 0 ? 0.02 : fin - inicio;

    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final path = Path()
      ..arcTo(outerRect, inicio, sweep, false)
      ..arcTo(innerRect, inicio + sweep, -sweep, false)
      ..close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(path, paint);

    final angleMedio = inicio + sweep / 2;
    final textRadius = (outerRadius + innerRadius) / 2;

    final textOffset = Offset(
      center.dx + math.cos(angleMedio) * textRadius,
      center.dy + math.sin(angleMedio) * textRadius,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: texto,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        textOffset.dx - textPainter.width / 2,
        textOffset.dy - textPainter.height / 2,
      ),
    );
  }

  void drawNeedle(
      Canvas canvas,
      Offset center,
      double outerRadius,
      double valor,
      Color color,
      double strokeWidth,
      ) {
    final angle = valueToAngle(valor);
    final needleLength = outerRadius - 20;

    final end = Offset(
      center.dx + math.cos(angle) * needleLength,
      center.dy + math.sin(angle) * needleLength,
    );

    final glowPaint = Paint()
      ..color = color.withOpacity(0.22)
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round;

    final needlePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, end, glowPaint);
    canvas.drawLine(center, end, needlePaint);

  }

  double valueToAngle(double value) {
    return math.pi + (math.pi * (value / 100));
  }

  @override
  bool shouldRepaint(covariant NeedleGaugePainter oldDelegate) {
    return oldDelegate.valorPrincipal != valorPrincipal ||
        oldDelegate.valorSecundario != valorSecundario ||
        oldDelegate.mostrarZonasPuntuacion != mostrarZonasPuntuacion ||
        oldDelegate.centroZonas != centroZonas;
  }
}