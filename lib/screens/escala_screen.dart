import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/escala_data.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../widgets/escala_picker_sheet.dart';

class EscalaScreen extends StatefulWidget {
  const EscalaScreen({super.key});

  @override
  State<EscalaScreen> createState() => _EscalaScreenState();
}

class _EscalaScreenState extends State<EscalaScreen> {
  final math.Random random = math.Random();

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 || _isNarrowScreen;

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

  /// Última categoría filtrada en el selector (null = todas).
  String? categoriaSelector;

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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Escala guardada')));

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

  void usarEscalaElegida(Map<String, String> escala) {
    setState(() {
      escalaActual = escala;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rellena los dos extremos')));
      return;
    }

    setState(() {
      escalaActual = {'izquierda': izquierda, 'derecha': derecha};
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

  ButtonStyle mainButtonStyle({Color color = CuboColors.white}) {
    final foreground = color == CuboColors.blue || color == CuboColors.alert
        ? CuboColors.white
        : CuboColors.blueInk;

    // Botón principal: píldora blanca del sistema Cubo.
    if (color == CuboColors.white) {
      return CuboButtons.primary(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      );
    }

    // Botones de acento de cada fase: misma píldora con su color.
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: foreground,
      disabledBackgroundColor: color.withValues(alpha: 0.28),
      disabledForegroundColor: foreground.withValues(alpha: 0.45),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const StadiumBorder(),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return CuboButtons.secondary(
      padding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  static const List<String> _pasosFase = [
    'Jugador 1',
    'Escribe pista',
    'Jugador 2',
    'Resultado',
  ];

  static const List<IconData> _iconosFase = [
    Icons.visibility_rounded,
    Icons.edit_rounded,
    Icons.touch_app_rounded,
    Icons.emoji_events_rounded,
  ];

  Widget buildTopBar({required bool compact}) {
    final enJuego = fase > 0;
    final titleSize = enJuego
        ? (compact ? 28.0 : 34.0)
        : (compact ? 34.0 : 42.0);

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
            CuboCircleButton(
              icon: Icons.question_mark_rounded,
              size: compact ? 44 : 50,
              onTap: mostrarNormas,
            ),
          ],
        ),
        if (!enJuego) ...[
          SizedBox(height: compact ? 4 : 8),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: compact ? 12 : 20),
              child: CuboIllustration('escala', size: compact ? 76 : 108),
            ),
          ),
          SizedBox(height: compact ? 6 : 10),
        ] else
          SizedBox(height: compact ? 6 : 12),
        Padding(
          padding: EdgeInsets.only(right: compact ? 6 : 10),
          child: CuboSectionTitle(
            'escala mental',
            alignEnd: true,
            size: titleSize,
            gap: compact ? 8 : 10,
          ),
        ),
        if (enJuego) ...[
          SizedBox(height: compact ? 10 : 14),
          Row(
            children: [
              CuboProgressDots(total: 4, current: fase - 1),
              const Spacer(),
              Flexible(
                flex: 3,
                child: CuboStatusChip(
                  _pasosFase[fase - 1],
                  icon: _iconosFase[fase - 1],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _phaseColor() {
    switch (fase) {
      case 0:
        return CuboColors.chill;

      case 1:
      case 2:
        return CuboColors.fiesta;

      case 3:
        return CuboColors.white;

      case 4:
        return CuboColors.chill;

      default:
        return CuboColors.chill;
    }
  }

  Widget buildGlassCard({required Widget child, EdgeInsets? padding}) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    return Container(
      width: double.infinity,
      padding:
          padding ??
          EdgeInsets.all(
            veryNarrow
                ? 10
                : compact
                ? 13
                : 17,
          ),
      decoration: CuboDecorations.glass(),
      child: child,
    );
  }

  Widget buildFancyButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = CuboColors.white,
    IconData? icon,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    final foreground = color == CuboColors.blue || color == CuboColors.alert
        ? CuboColors.white
        : CuboColors.blueInk;

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

                SizedBox(width: veryNarrow ? 5 : 9),
              ],

              Expanded(
                child: _singleLineResponsiveText(
                  tr(text).toUpperCase(),
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
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: CuboColors.white,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: CuboColors.white,
      decoration: InputDecoration(
        labelText: tr(label),
        labelStyle: TextStyle(
          color: CuboColors.white.withValues(alpha: 0.62),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: icon == null
            ? null
            : Icon(
                icon,
                color: CuboColors.white.withValues(alpha: 0.7),
                size: 20,
              ),
        filled: true,
        fillColor: CuboColors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: CuboInputs.rounded(
          BorderSide(
            color: CuboColors.white.withValues(alpha: 0.28),
            width: 1.4,
          ),
        ),
        focusedBorder: CuboInputs.rounded(
          const BorderSide(color: CuboColors.white, width: 2),
        ),
      ),
    );
  }

  Widget rulesItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return CuboRulesItem(icon: icon, title: title, text: text);
  }

  void mostrarNormas() {
    showCuboDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CuboDialogHeader(),

                  const SizedBox(height: 18),

                  const Text(
                    'ESCALA MENTAL',
                    style: TextStyle(
                      color: CuboColors.white,
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
                    text: 'El jugador 1 ve una posición secreta entre 0 y 100.',
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
                      style: CuboButtons.primary(padding: EdgeInsets.zero),
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
    showCuboDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: CuboDecorations.dialog(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CuboDialogHeader(title: 'ronda', icon: Icons.flag_rounded),

              const SizedBox(height: 18),

              buildScaleEnds(),

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

  double _valorDesdePosicion(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height - 10);

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
      angle = dx < 0 ? math.pi : math.pi * 2;
    }

    final value = ((angle - math.pi) / math.pi) * 100;

    return value.clamp(0.0, 100.0);
  }

  /// Los dos extremos de la escala como píldoras con flecha.
  Widget buildScaleEnds() {
    final compact = _isCompactScreen;

    Widget extremo(String text, {required bool derecha}) {
      final icon = Icon(
        derecha ? Icons.east_rounded : Icons.west_rounded,
        color: CuboColors.white.withValues(alpha: 0.75),
        size: compact ? 15 : 17,
      );
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: CuboColors.white.withValues(alpha: 0.12),
            borderRadius: CuboRadii.inputAll,
            border: Border.all(color: CuboColors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              if (!derecha) ...[icon, const SizedBox(width: 6)],
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: derecha ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: CuboColors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 11.5 : 13,
                    height: 1.15,
                  ),
                ),
              ),
              if (derecha) ...[const SizedBox(width: 6), icon],
            ],
          ),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          extremo(escalaActual['izquierda']!, derecha: false),
          SizedBox(width: compact ? 8 : 10),
          extremo(escalaActual['derecha']!, derecha: true),
        ],
      ),
    );
  }

  Widget buildPositionPill(int valor) {
    final compact = _isCompactScreen;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 20,
        vertical: compact ? 7 : 9,
      ),
      decoration: BoxDecoration(
        color: CuboColors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: CuboShadows.soft,
      ),
      child: Text(
        'POSICIÓN $valor',
        maxLines: 1,
        style: TextStyle(
          color: CuboColors.blueInk,
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget buildMedidorSemicircular({
    int? valor,
    required bool mostrarNumero,
    int? valorSecundario,
    bool mostrarZonasPuntuacion = false,
    int? centroZonas,
    bool interactivo = false,
    int? marcaReal,
  }) {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    final gaugeHeight = veryNarrow
        ? 140.0
        : compact
        ? 165.0
        : 215.0;

    return Column(
      children: [
        SizedBox(
          height: gaugeHeight,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gaugeSize = Size(constraints.maxWidth, gaugeHeight);

              void actualizar(Offset position) {
                if (!interactivo) return;
                final nuevoValor = _valorDesdePosicion(position, gaugeSize);
                setState(() {
                  valorAdivinado = nuevoValor;
                });
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: interactivo
                    ? (details) => actualizar(details.localPosition)
                    : null,
                onPanStart: interactivo
                    ? (details) => actualizar(details.localPosition)
                    : null,
                onPanUpdate: interactivo
                    ? (details) => actualizar(details.localPosition)
                    : null,
                child: CustomPaint(
                  size: gaugeSize,
                  painter: NeedleGaugePainter(
                    valorPrincipal: valor?.toDouble(),
                    valorSecundario: valorSecundario?.toDouble(),
                    mostrarZonasPuntuacion: mostrarZonasPuntuacion,
                    centroZonas: (centroZonas ?? valor ?? valorSecundario ?? 50)
                        .toDouble(),
                    marcaReal: marcaReal?.toDouble(),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        buildScaleEnds(),
        if (interactivo) ...[
          SizedBox(height: compact ? 10 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swipe_rounded,
                color: CuboColors.white.withValues(alpha: 0.55),
                size: compact ? 15 : 17,
              ),
              const SizedBox(width: 6),
              Text(
                'ARRASTRA LA AGUJA',
                maxLines: 1,
                softWrap: false,
                style: CuboText.chip(
                  color: CuboColors.white.withValues(alpha: 0.55),
                  size: compact ? 10 : 11,
                ),
              ),
            ],
          ),
        ],
        if (mostrarNumero && valor != null) ...[
          SizedBox(height: compact ? 10 : 14),
          buildPositionPill(valor),
        ],
      ],
    );
  }

  /// Abre el selector de escalas por categoría y empieza con la elegida.
  Future<void> abrirSelectorEscalas() async {
    final elegida = await mostrarSelectorEscalas(
      context,
      categoriaInicial: categoriaSelector,
      onCategoriaCambiada: (c) => categoriaSelector = c,
    );
    if (!mounted || elegida == null) return;
    usarEscalaElegida(elegida);
  }

  Widget buildRandomScaleCard() => buildOptionCard(
    title: 'Escala aleatoria',
    subtitle: 'Una escala sorpresa de la app',
    icon: Icons.casino_rounded,
    trailingIcon: Icons.play_arrow_rounded,
    onTap: usarEscalaAleatoria,
    light: true,
  );

  Widget buildPickScaleCard() => buildOptionCard(
    title: 'Elegir escala',
    subtitle: 'Filtra por categoría y escoge',
    icon: Icons.format_list_bulleted_rounded,
    trailingIcon: Icons.chevron_right_rounded,
    onTap: abrirSelectorEscalas,
    light: false,
  );

  /// Tarjeta de opción: blanca ([light]) o de cristal sobre el azul.
  Widget buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required IconData trailingIcon,
    required VoidCallback onTap,
    required bool light,
  }) {
    final compact = _isCompactScreen;
    final iconBox = compact ? 50.0 : 58.0;
    final ink = light ? CuboColors.blueInk : CuboColors.white;

    return CuboPressable(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: light
            ? CuboDecorations.whiteCard()
            : CuboDecorations.glass(radius: CuboRadii.lg),
        child: Row(
          children: [
            Container(
              width: iconBox,
              height: iconBox,
              decoration: BoxDecoration(
                color: light
                    ? CuboColors.blueTint
                    : CuboColors.white.withValues(alpha: 0.14),
                borderRadius: CuboRadii.mdAll,
              ),
              child: Icon(
                icon,
                color: light ? CuboColors.blue : CuboColors.white,
                size: compact ? 28 : 32,
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CuboText.label(size: compact ? 18 : 20, color: ink),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink.withValues(alpha: 0.65),
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: light ? CuboColors.blue : CuboColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                trailingIcon,
                color: light ? CuboColors.white : CuboColors.blue,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDividerText(String text) {
    Widget linea() => Expanded(
      child: Container(
        height: 1.5,
        decoration: BoxDecoration(
          color: CuboColors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );

    return Row(
      children: [
        linea(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(
              color: CuboColors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        linea(),
      ],
    );
  }

  Widget buildSavedScaleTile(Map<String, String> escala, int index) {
    final compact = _isCompactScreen;
    final style = TextStyle(
      color: CuboColors.white,
      fontSize: compact ? 12 : 13,
      height: 1.15,
      fontWeight: FontWeight.w800,
    );

    return CuboEntrance(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CuboPressable(
          onTap: () => usarEscalaGuardada(escala),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: CuboDecorations.glass(radius: CuboRadii.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    escala['izquierda']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    color: CuboColors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    escala['derecha']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: style,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: CuboColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: CuboColors.blue,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPantallaElegirEscala() {
    final compact = _isCompactScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: compact ? 8 : 14),
        CuboEntrance(child: buildRandomScaleCard()),
        SizedBox(height: compact ? 10 : 12),
        CuboEntrance(index: 1, child: buildPickScaleCard()),
        SizedBox(height: compact ? 14 : 20),
        CuboEntrance(index: 1, child: buildDividerText('o crea la tuya')),
        SizedBox(height: compact ? 14 : 20),
        CuboEntrance(
          index: 2,
          child: buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CuboIconCircle(
                      icon: Icons.tune_rounded,
                      size: compact ? 34 : 38,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Escala personalizada',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CuboText.label(
                          size: compact ? 17 : 19,
                          color: CuboColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ejemplo: “Comida buenísima” ↔ “Comida horrible”',
                  style: TextStyle(
                    color: CuboColors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                buildCustomField(
                  controller: izquierdaController,
                  label: 'Extremo izquierdo',
                  icon: Icons.west_rounded,
                ),
                const SizedBox(height: 10),
                buildCustomField(
                  controller: derechaController,
                  label: 'Extremo derecho',
                  icon: Icons.east_rounded,
                ),
                const SizedBox(height: 14),
                buildFancyButton(
                  text: 'Usar esta escala',
                  icon: Icons.play_arrow_rounded,
                  onPressed: usarEscalaPersonalizada,
                ),
              ],
            ),
          ),
        ),
        if (escalasGuardadas.isNotEmpty) ...[
          SizedBox(height: compact ? 16 : 22),
          Row(
            children: [
              const Icon(
                Icons.bookmark_rounded,
                color: CuboColors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Guardadas',
                style: CuboText.label(size: 16, color: CuboColors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < escalasGuardadas.length; i++)
            buildSavedScaleTile(escalasGuardadas[i], i + 3),
        ],
      ],
    );
  }

  Widget buildPantallaInicioJugador1() {
    final compact = _isCompactScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              const CuboStatusChip(
                'Que no mire el jugador 2',
                icon: Icons.visibility_off_rounded,
              ),
              SizedBox(height: compact ? 10 : 14),
              Text(
                'Mira la posición secreta y piensa una respuesta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              buildMedidorSemicircular(valor: valorReal, mostrarNumero: true),
              SizedBox(height: compact ? 10 : 14),
              Text(
                'Tu posición está ${interpretarLado(valorReal)}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 16 : 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        buildFancyButton(
          text: 'Continuar',
          icon: Icons.arrow_forward_rounded,
          onPressed: pasarAEscribirRespuesta,
        ),
      ],
    );
  }

  Widget buildPantallaRespuesta() {
    final compact = _isCompactScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CuboIconCircle(
                    icon: Icons.lightbulb_rounded,
                    size: compact ? 34 : 38,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Escribe una pista que encaje con la posición o déjala vacía.',
                      style: TextStyle(
                        color: CuboColors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 14 : 18),
              buildScaleEnds(),
              SizedBox(height: compact ? 14 : 18),
              buildCustomField(
                controller: respuestaController,
                label: 'Tu respuesta',
                maxLines: 2,
                icon: Icons.edit_rounded,
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        buildFancyButton(
          text: 'Confirmar respuesta',
          icon: Icons.check_rounded,
          onPressed: confirmarRespuesta,
        ),
      ],
    );
  }

  Widget buildPantallaAdivinar() {
    final compact = _isCompactScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              Text(
                '¿Dónde crees que estaba la respuesta?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: compact ? 10 : 14),
              CuboCardSwitcher(
                child: CuboHeroCard(
                  key: ValueKey('pista-$valorReal-$respuestaJugador1'),
                  chip: 'Jugador 1',
                  chipIcon: Icons.lightbulb_rounded,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Text(
                    respuestaJugador1.isEmpty
                        ? 'SIN PISTA'
                        : '"$respuestaJugador1"',
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CuboColors.blueInk,
                      fontSize: compact ? 21 : 25,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              buildMedidorSemicircular(
                valor: valorAdivinado.round(),
                mostrarNumero: true,
                interactivo: true,
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        buildFancyButton(
          text: 'Confirmar',
          icon: Icons.check_circle_rounded,
          onPressed: confirmarAdivinanza,
        ),
      ],
    );
  }

  Widget buildStatTile(String label, String value, IconData icon) {
    final compact = _isCompactScreen;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: compact ? 10 : 12,
          horizontal: 6,
        ),
        decoration: CuboDecorations.glass(radius: CuboRadii.md),
        child: Column(
          children: [
            Icon(
              icon,
              color: CuboColors.white.withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 20 : 24,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                tr(label).toUpperCase(),
                maxLines: 1,
                style: CuboText.chip(
                  color: CuboColors.white.withValues(alpha: 0.7),
                  size: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPantallaResultado() {
    final compact = _isCompactScreen;
    final diferencia = calcularDiferencia();
    final puntos = calcularPuntos();
    final Color resultColor;
    final IconData resultIcon;
    final String resultMessage;

    switch (puntos) {
      case 4:
        resultColor = CuboColors.fiesta;
        resultIcon = Icons.emoji_events_rounded;
        resultMessage = '¡CLAVADO!';
        break;

      case 2:
        resultColor = CuboColors.chill;
        resultIcon = Icons.track_changes_rounded;
        resultMessage = '¡MUY CERCA!';
        break;

      case 1:
        resultColor = CuboColors.white;
        resultIcon = Icons.near_me_rounded;
        resultMessage = 'CASI';
        break;

      default:
        resultColor = CuboColors.alert;
        resultIcon = Icons.refresh_rounded;
        resultMessage = 'LEJOS';
    }

    final resultInk = Color.lerp(resultColor, Colors.black, 0.35)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildGlassCard(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  compact ? 14 : 18,
                  18,
                  compact ? 14 : 18,
                ),
                decoration: CuboDecorations.whiteCard(radius: CuboRadii.xl),
                child: Row(
                  children: [
                    CuboIllustration(
                      'escala',
                      onBlue: false,
                      size: compact ? 64 : 80,
                      popIn: true,
                    ),
                    SizedBox(width: compact ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: resultColor.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(resultIcon, color: resultInk, size: 15),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    resultMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CuboText.chip(
                                      color: resultInk,
                                      size: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: _singleLineResponsiveText(
                              '$puntos ${puntos == 1 ? 'PUNTO' : 'PUNTOS'}',
                              alignment: Alignment.centerLeft,
                              style: TextStyle(
                                color: CuboColors.blueInk,
                                fontSize: compact ? 28 : 34,
                                height: 1,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 14 : 18),
              buildMedidorSemicircular(
                valor: null,
                mostrarNumero: false,
                valorSecundario: valorAdivinado.round(),
                mostrarZonasPuntuacion: true,
                centroZonas: valorReal,
                marcaReal: valorReal,
              ),
              SizedBox(height: compact ? 12 : 16),
              Row(
                children: [
                  buildStatTile('Real', '$valorReal', Icons.flag_rounded),
                  const SizedBox(width: 8),
                  buildStatTile(
                    'Adivinada',
                    '${valorAdivinado.round()}',
                    Icons.touch_app_rounded,
                  ),
                  const SizedBox(width: 8),
                  buildStatTile(
                    'Diferencia',
                    '$diferencia',
                    Icons.straighten_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        buildFancyButton(
          text: 'Terminar ronda',
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
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
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
          child: SlideTransition(position: slide, child: child),
        );
      },

      child: Align(
        key: ValueKey(fase),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: SizedBox(width: double.infinity, child: contenido),
        ),
      ),
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
                  compact ? 10 : 16,
                ),
                child: Column(
                  children: [
                    buildTopBar(compact: compact),

                    SizedBox(height: compact ? 7 : 10),

                    Expanded(child: buildContenido()),
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

class NeedleGaugePainter extends CustomPainter {
  final double? valorPrincipal;
  final double? valorSecundario;
  final bool mostrarZonasPuntuacion;
  final double centroZonas;

  /// Marca blanca en el borde con la posición real (pantalla de resultado).
  final double? marcaReal;

  NeedleGaugePainter({
    required this.valorPrincipal,
    this.valorSecundario,
    required this.mostrarZonasPuntuacion,
    required this.centroZonas,
    this.marcaReal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // El centro debe coincidir con _valorDesdePosicion.
    final center = Offset(size.width / 2, size.height - 10);
    final outerRadius = math.min(size.width / 2 - 14, size.height - 14);
    final innerRadius = outerRadius * 0.42;

    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    // Pista translúcida con un brillo arriba.
    final track = _ringPath(outerRect, innerRect, math.pi, math.pi);
    canvas.drawPath(
      track,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.10),
          ],
        ).createShader(outerRect),
    );

    if (mostrarZonasPuntuacion) {
      const zonas = [
        (-15.0, -9.0, Color(0xFFFFE45E), '1'),
        (-8.0, -4.0, Color(0xFFFFB84D), '2'),
        (-3.0, 3.0, Color(0xFFFF7A3D), '4'),
        (4.0, 8.0, Color(0xFFFFB84D), '2'),
        (9.0, 15.0, Color(0xFFFFE45E), '1'),
      ];
      for (final zona in zonas) {
        drawZonaRellenaConTexto(
          canvas,
          center,
          outerRadius,
          innerRadius,
          centroZonas + zona.$1,
          centroZonas + zona.$2,
          zona.$3,
          zona.$4,
        );
      }
    }

    // Marcas cada 5, más largas cada 10.
    for (var v = 0; v <= 100; v += 5) {
      final major = v % 10 == 0;
      final angle = valueToAngle(v.toDouble());
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (outerRadius - (major ? 13 : 8)),
        center + dir * (outerRadius - 4),
        Paint()
          ..color = Colors.white.withValues(alpha: major ? 0.75 : 0.4)
          ..strokeWidth = major ? 2.2 : 1.4
          ..strokeCap = StrokeCap.round,
      );
    }

    // Contorno.
    final borde = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawArc(outerRect, math.pi, math.pi, false, borde);
    canvas.drawArc(innerRect, math.pi, math.pi, false, borde);

    if (marcaReal != null) {
      _drawMarcaReal(canvas, center, outerRadius, marcaReal!);
    }

    if (valorPrincipal != null) {
      drawNeedle(canvas, center, outerRadius, valorPrincipal!);
    }
    if (valorSecundario != null) {
      drawNeedle(canvas, center, outerRadius, valorSecundario!);
    }

    // Eje central.
    canvas.drawCircle(
      center + const Offset(0, 2),
      19,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(center, 18, Paint()..color = CuboColors.white);
    canvas.drawCircle(center, 8, Paint()..color = CuboColors.blue);
  }

  Path _ringPath(
    Rect outerRect,
    Rect innerRect,
    double startAngle,
    double sweepAngle,
  ) {
    return Path()
      ..arcTo(outerRect, startAngle, sweepAngle, false)
      ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
      ..close();
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

    canvas.drawPath(
      _ringPath(outerRect, innerRect, inicio, sweep),
      Paint()..color = color,
    );

    final angleMedio = inicio + sweep / 2;
    final textRadius = (outerRadius + innerRadius) / 2;
    final textOffset =
        center +
        Offset(math.cos(angleMedio), math.sin(angleMedio)) * textRadius;

    final textPainter = TextPainter(
      text: TextSpan(
        text: tr(texto),
        style: const TextStyle(
          color: CuboColors.blueInk,
          fontFamily: CuboText.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawMarcaReal(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double valor,
  ) {
    final angle = valueToAngle(valor);
    final dir = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-dir.dy, dir.dx);
    final punta = center + dir * (outerRadius + 1);
    final base = center + dir * (outerRadius + 11);
    final path = Path()
      ..moveTo(punta.dx, punta.dy)
      ..lineTo((base + normal * 7).dx, (base + normal * 7).dy)
      ..lineTo((base - normal * 7).dx, (base - normal * 7).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = CuboColors.white);
  }

  /// Aguja blanca afilada con sombra suave.
  void drawNeedle(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double valor,
  ) {
    final angle = valueToAngle(valor);
    final dir = Offset(math.cos(angle), math.sin(angle));
    final normal = Offset(-dir.dy, dir.dx);
    final tip = center + dir * (outerRadius - 6);
    final baseLeft = center + normal * 6;
    final baseRight = center - normal * 6;

    final path = Path()
      ..moveTo(baseLeft.dx, baseLeft.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(baseRight.dx, baseRight.dy)
      ..close();

    canvas.drawShadow(path, Colors.black, 4, false);
    canvas.drawPath(path, Paint()..color = CuboColors.white);
  }

  double valueToAngle(double value) {
    return math.pi + (math.pi * (value / 100));
  }

  @override
  bool shouldRepaint(covariant NeedleGaugePainter oldDelegate) {
    return oldDelegate.valorPrincipal != valorPrincipal ||
        oldDelegate.valorSecundario != valorSecundario ||
        oldDelegate.mostrarZonasPuntuacion != mostrarZonasPuntuacion ||
        oldDelegate.centroZonas != centroZonas ||
        oldDelegate.marcaReal != marcaReal;
  }
}
