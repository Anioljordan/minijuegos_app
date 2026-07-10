import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/escala_data.dart';

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
      mostrarNormas();
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
    if (texto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe una respuesta')),
      );
      return;
    }

    setState(() {
      respuestaJugador1 = texto;
      respuestaController.clear();
      fase = 3;
    });
  }

  void pasarAJugador2() {
    setState(() {
      fase = 4;
    });
  }

  void confirmarAdivinanza() {
    setState(() {
      fase = 5;
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
            height: 86,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'escala\nmental',
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
                  top: 74,
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
      ],
    );
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

  Widget buildFancyButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = appWhite,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonStyle(color: color),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: appBlue,
                  size: 22,
                ),
                const SizedBox(width: 9),
              ],

              Expanded(
                child: Text(
                  text.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              if (icon != null)
                const SizedBox(width: 31),
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

  Widget buildMedidorSemicircular({
    int? valor,
    required bool mostrarNumero,
    int? valorSecundario,
    bool mostrarZonasPuntuacion = false,
    int? centroZonas,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: appWhite.withOpacity(0.08),
            border: Border.all(
              color: appWhite.withOpacity(0.28),
              width: 1.4,
            ),
          ),
          child: SizedBox(
            height: 210,
            width: double.infinity,
            child: CustomPaint(
              painter: NeedleGaugePainter(
                valorPrincipal: valor?.toDouble(),
                valorSecundario: valorSecundario?.toDouble(),
                mostrarZonasPuntuacion: mostrarZonasPuntuacion,
                centroZonas:
                (centroZonas ?? valor ?? valorSecundario ?? 50).toDouble(),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: Text(
                escalaActual['izquierda']!,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                escalaActual['derecha']!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        if (mostrarNumero && valor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: appWhite.withOpacity(0.08),
              border: Border.all(
                color: appWhite.withOpacity(0.26),
                width: 1.4,
              ),
            ),
            child: Text(
              'POSICIÓN: $valor',
              style: const TextStyle(
                color: appWhite,
                fontSize: 14,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: appWhite.withOpacity(0.08),
          border: Border.all(
            color: appWhite.withOpacity(0.26),
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: appWhite, size: 23),
            const SizedBox(height: 7),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: appWhite,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: appWhite.withOpacity(0.65),
                fontSize: 10.5,
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
          sectionTitle('Crea una escala'),

          const SizedBox(height: 8),

          Text(
            'Elige una escala aleatoria o crea una personalizada.',
            style: TextStyle(
              color: appWhite.withOpacity(0.70),
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),


          const SizedBox(height: 14),
          buildFancyButton(
            text: 'Usar escala aleatoria',
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
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
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
                'No pongas un número. Escribe algo que encaje con la posición.',
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
          icon: Icons.check_rounded,
          onPressed: confirmarRespuesta,
        ),
      ],
    );
  }

  Widget buildPantallaPasarMovil() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildGlassCard(
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
                  size: 39,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'pasa\nel móvil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite,
                  fontSize: 38,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.9,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Ahora le toca al Jugador 2 adivinar la posición.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.76),
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Estoy listo',
          icon: Icons.visibility_rounded,
          onPressed: pasarAJugador2,
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
                  '"$respuestaJugador1"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              buildMedidorSemicircular(
                valor: valorAdivinado.round(),
                mostrarNumero: true,
              ),

              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: appWhite,
                  inactiveTrackColor: appWhite.withOpacity(0.18),
                  thumbColor: appWhite,
                  overlayColor: appWhite.withOpacity(0.12),
                  trackHeight: 7,
                ),
                child: Slider(
                  value: valorAdivinado,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: valorAdivinado.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      valorAdivinado = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        buildFancyButton(
          text: 'Confirmar',
          icon: Icons.check_circle_rounded,
          onPressed: confirmarAdivinanza,
        ),
      ],
    );
  }

  Widget buildPantallaResultado() {
    final diferencia = calcularDiferencia();
    final puntos = calcularPuntos();

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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: appWhite.withOpacity(0.08),
                  border: Border.all(
                    color: appWhite.withOpacity(0.28),
                    width: 1.4,
                  ),
                ),
                child: Text(
                  '"$respuestaJugador1"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 24,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'REAL: $valorReal · ADIVINADA: ${valorAdivinado.round()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'DIFERENCIA: $diferencia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: appWhite.withOpacity(0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: appWhite,
                ),
                child: Text(
                  '$puntos PUNTOS',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appBlue,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

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
        contenido = buildPantallaPasarMovil();
        break;

      case 4:
        contenido = buildPantallaAdivinar();
        break;

      case 5:
        contenido = buildPantallaResultado();
        break;

      default:
        contenido = const SizedBox.shrink();
    }

    // La configuración ya tiene su propio scroll.
    if (fase == 0) {
      return contenido;
    }

    // El resto de pantallas pueden desplazarse
    // si el móvil es demasiado pequeño.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: contenido,
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



              const SizedBox(height: 14),

              Expanded(
                child: buildContenido(),
              ),
            ],
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