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
    Color color = const Color(0xFF8B5CF6),
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.white.withOpacity(0.22)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  Widget buildTopBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escala mental',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Adivina la posición correcta',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            onPressed: mostrarNormas,
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildFancyButton({
    required String text,
    required VoidCallback? onPressed,
    Color color = const Color(0xFF8B5CF6),
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: mainButtonStyle(color: color),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
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
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.68)),
        filled: true,
        fillColor: const Color(0xFF0F172A).withOpacity(0.74),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(
            color: Color(0xFF8B5CF6),
            width: 1.6,
          ),
        ),
      ),
    );
  }

  void mostrarNormas() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF151122),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cómo se juega',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Elegid una escala con dos extremos.\n\n'
                    'Jugador 1 ve una posición secreta y escribe una respuesta que encaje.\n\n'
                    'Jugador 2 lee la respuesta e intenta adivinar la posición.\n\n'
                    'Puntuación:\n'
                    'A 3 o menos = 4 puntos\n'
                    'A 8 o menos = 2 puntos\n'
                    'A 15 o menos = 1 punto',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              buildFancyButton(
                text: 'Cerrar',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarDialogoFinRonda() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF151122),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¿Qué hacemos ahora?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${escalaActual['izquierda']} ↔ ${escalaActual['derecha']}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              buildFancyButton(
                text: 'Seguir con esta escala',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  nuevaRondaMismaEscala();
                },
              ),
              const SizedBox(height: 10),
              buildFancyButton(
                text: 'Cambiar escala',
                color: const Color(0xFF2563EB),
                icon: Icons.swap_horiz_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  volverAElegirEscala();
                },
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
                      'Guardar escala',
                      style: TextStyle(fontWeight: FontWeight.w800),
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: SizedBox(
            height: 235,
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                escalaActual['izquierda']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: Text(
                escalaActual['derecha']!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (mostrarNumero && valor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Text(
              'Posición: $valor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 12,
                height: 1.25,
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
          buildGlassCard(
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFF2563EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Crea una escala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige dos extremos. Uno verá una posición secreta y el otro tendrá que adivinarla.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    buildInfoPill(
                      icon: Icons.visibility_rounded,
                      title: 'Mira',
                      text: 'Jugador 1 ve el número',
                    ),
                    const SizedBox(width: 10),
                    buildInfoPill(
                      icon: Icons.edit_rounded,
                      title: 'Escribe',
                      text: 'Da una pista',
                    ),
                    const SizedBox(width: 10),
                    buildInfoPill(
                      icon: Icons.track_changes_rounded,
                      title: 'Adivina',
                      text: 'Jugador 2 coloca la aguja',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          buildFancyButton(
            text: 'Usar escala aleatoria',
            icon: Icons.casino_rounded,
            color: const Color(0xFF2563EB),
            onPressed: usarEscalaAleatoria,
          ),
          const SizedBox(height: 18),
          buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Personalizada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ejemplo: “Comida buenísima” ↔ “Comida horrible”',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                buildCustomField(
                  controller: izquierdaController,
                  label: 'Extremo izquierdo',
                ),
                const SizedBox(height: 12),
                buildCustomField(
                  controller: derechaController,
                  label: 'Extremo derecho',
                ),
                const SizedBox(height: 18),
                buildFancyButton(
                  text: 'Usar esta escala',
                  icon: Icons.play_arrow_rounded,
                  onPressed: usarEscalaPersonalizada,
                ),
              ],
            ),
          ),
          if (escalasGuardadas.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Escalas guardadas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ...escalasGuardadas.map(
                  (escala) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () => usarEscalaGuardada(escala),
                  style: secondaryButtonStyle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      '${escala['izquierda']} ↔ ${escala['derecha']}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w800),
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
              const Text(
                'Jugador 1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mira la posición secreta y piensa una respuesta.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              buildMedidorSemicircular(
                valor: valorReal,
                mostrarNumero: true,
              ),
              const SizedBox(height: 18),
              Text(
                'Tu posición está ${interpretarLado(valorReal)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
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
              const Text(
                'Escribe tu pista',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No pongas un número. Escribe algo que encaje con la posición.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              buildMedidorSemicircular(
                valor: null,
                mostrarNumero: false,
              ),
              const SizedBox(height: 18),
              buildCustomField(
                controller: respuestaController,
                label: 'Tu respuesta',
                maxLines: 2,
              ),
            ],
          ),
        ),
        const Spacer(),
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
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF2563EB),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_android_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pasa el móvil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Ahora le toca al Jugador 2 adivinar la posición.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.76),
                  fontSize: 17,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
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
              const Text(
                'Jugador 2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Dónde crees que estaba la respuesta?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.70),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '"$respuestaJugador1"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              buildMedidorSemicircular(
                valor: valorAdivinado.round(),
                mostrarNumero: true,
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF8B5CF6),
                  inactiveTrackColor: Colors.white.withOpacity(0.15),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF8B5CF6).withOpacity(0.15),
                  trackHeight: 8,
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
        const Spacer(),
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
              const Text(
                'Resultado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              buildMedidorSemicircular(
                valor: null,
                mostrarNumero: false,
                valorSecundario: valorAdivinado.round(),
                mostrarZonasPuntuacion: true,
                centroZonas: valorReal,
              ),
              const SizedBox(height: 18),
              Text(
                '"$respuestaJugador1"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Real: $valorReal · Adivinada: ${valorAdivinado.round()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Diferencia: $diferencia',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFF2563EB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$puntos puntos',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        buildFancyButton(
          text: 'Terminar ronda',
          icon: Icons.flag_rounded,
          onPressed: mostrarDialogoFinRonda,
        ),
      ],
    );
  }

  Widget buildContenido() {
    switch (fase) {
      case 0:
        return buildPantallaElegirEscala();
      case 1:
        return buildPantallaInicioJugador1();
      case 2:
        return buildPantallaRespuesta();
      case 3:
        return buildPantallaPasarMovil();
      case 4:
        return buildPantallaAdivinar();
      case 5:
        return buildPantallaResultado();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF312E81),
                Color(0xFF08051A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -70,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.10),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      buildTopBar(),
                      const SizedBox(height: 18),
                      Expanded(child: buildContenido()),
                    ],
                  ),
                ),
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