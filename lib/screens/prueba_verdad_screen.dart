import 'dart:math';
import 'package:flutter/material.dart';
import '../data/prueba_verdad_data.dart';
import '../widgets/app_logo_button.dart';

class PruebaVerdadScreen extends StatefulWidget {
  const PruebaVerdadScreen({super.key});

  @override
  State<PruebaVerdadScreen> createState() => _PruebaVerdadScreenState();
}

class _PruebaVerdadScreenState extends State<PruebaVerdadScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPink = Color(0xFFFF4D6D);
  static const Color accentYellow = Color(0xFFFFD166);

  String textoActual = 'Elige Prueba o Verdad';
  String tipoActual = '';

  List<String> verdadesDisponibles = [];
  List<String> verdadesUsadas = [];
  List<String> pruebasDisponibles = [];
  List<String> pruebasUsadas = [];

  @override
  void initState() {
    super.initState();
    reiniciarBarajas();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

    });
  }

  int get totalCartas => preguntasVerdad.length + pruebas.length;

  int get cartasRestantes =>
      verdadesDisponibles.length + pruebasDisponibles.length;

  double get progresoRestante {
    if (totalCartas == 0) return 0;
    return (cartasRestantes / totalCartas).clamp(0.0, 1.0);
  }

  Color get cardAccent {
    if (tipoActual == 'VERDAD') return accentGreen;
    if (tipoActual == 'PRUEBA') return accentOrange;
    return accentPink;
  }

  IconData get cardIcon {
    if (tipoActual == 'VERDAD') return Icons.question_answer_rounded;
    if (tipoActual == 'PRUEBA') {
      return Icons.local_fire_department_rounded;
    }
    return Icons.compare_arrows_rounded;
  }

  void reiniciarBarajas() {
    verdadesDisponibles = List<String>.from(preguntasVerdad)..shuffle(random);
    verdadesUsadas = [];

    pruebasDisponibles = List<String>.from(pruebas)..shuffle(random);
    pruebasUsadas = [];
  }

  String generarCastigo() {
    final tragos = random.nextInt(5) + 1;
    return 'Si no lo haces, bebe $tragos ${tragos == 1 ? 'trago' : 'tragos'}.';
  }

  void sacarVerdad() {
    if (verdadesDisponibles.isEmpty) {
      verdadesDisponibles = List<String>.from(verdadesUsadas)..shuffle(random);
      verdadesUsadas.clear();
    }

    if (verdadesDisponibles.isEmpty) return;

    final verdad = verdadesDisponibles.removeLast();

    setState(() {
      tipoActual = 'VERDAD';
      textoActual = '$verdad\n\n${generarCastigo()}';
      verdadesUsadas.add(verdad);
    });
  }

  void sacarPrueba() {
    if (pruebasDisponibles.isEmpty) {
      pruebasDisponibles = List<String>.from(pruebasUsadas)..shuffle(random);
      pruebasUsadas.clear();
    }

    if (pruebasDisponibles.isEmpty) return;

    final prueba = pruebasDisponibles.removeLast();

    setState(() {
      tipoActual = 'PRUEBA';
      textoActual = '$prueba\n\n${generarCastigo()}';
      pruebasUsadas.add(prueba);
    });
  }

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
    final compact = MediaQuery.of(context).size.height < 740;
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
                      'prueba o verdad',
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 42,
                        height: 2.60,
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
          Icon(icon, color: appWhite, size: 22),
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
                    'PRUEBA O VERDAD',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  rulesItem(
                    icon: Icons.question_answer_rounded,
                    title: 'Verdad',
                    text: 'Responde sinceramente a la pregunta que aparezca.',
                  ),
                  rulesItem(
                    icon: Icons.local_fire_department_rounded,
                    title: 'Prueba',
                    text: 'Haz el reto que aparezca en pantalla.',
                  ),
                  rulesItem(
                    icon: Icons.local_bar_rounded,
                    title: 'Si te niegas',
                    text: 'Bebe los tragos que indique la carta.',
                  ),
                  rulesItem(
                    icon: Icons.shuffle_rounded,
                    title: 'Sin repetir',
                    text: 'Cada baraja se mezcla de nuevo cuando se termina.',
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

  Widget buildCard() {
    final Color foreground = tipoActual == 'PRUEBA' ? appBlue : appWhite;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: appWhite,
                    width: 3,
                  ),
                ),
                child: Icon(
                  cardIcon,
                  color: appWhite,
                  size: 50,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: tipoActual.isEmpty
                      ? appWhite.withOpacity(0.12)
                      : cardAccent,
                  border: Border.all(
                    color: appWhite.withOpacity(0.26),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  tipoActual.isEmpty ? 'ELIGE' : tipoActual,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(animation);

                  return SlideTransition(
                    position: slide,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  textoActual,
                  key: ValueKey(textoActual),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 31,
                    height: 1.14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgressInfo() {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'RESTANTES',
              style: TextStyle(
                color: appWhite.withOpacity(0.76),
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
            const Spacer(),
            Text(
              '$cartasRestantes / $totalCartas',
              style: const TextStyle(
                color: appWhite,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Verdades ${verdadesDisponibles.length} · Pruebas ${pruebasDisponibles.length}',
            style: TextStyle(
              color: appWhite.withOpacity(0.62),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 9),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: progresoRestante),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Container(
              height: 14,
              decoration: BoxDecoration(
                color: appWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: appWhite.withOpacity(0.34),
                  width: 1.2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(accentYellow),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildChoiceButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color foregroundColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.35,
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appWhite.withOpacity(0.28),
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: foregroundColor,
                    size: 42,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactHeight = constraints.maxHeight < 700;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                compactHeight ? 12 : 18,
                18,
                compactHeight ? 10 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(),
                  SizedBox(height: compactHeight ? 8 : 14),
                  Expanded(child: buildCard()),
                  SizedBox(height: compactHeight ? 9 : 14),
                  buildProgressInfo(),
                  SizedBox(height: compactHeight ? 9 : 14),
                  Row(
                    children: [
                      buildChoiceButton(
                        label: 'PRUEBA',
                        icon: Icons.local_fire_department_rounded,
                        backgroundColor: appBlue,
                        foregroundColor: appWhite,
                        onTap: sacarPrueba,
                      ),
                      const SizedBox(width: 12),
                      buildChoiceButton(
                        label: 'VERDAD',
                        icon: Icons.question_answer_rounded,
                        backgroundColor: appWhite,
                        foregroundColor: appBlue,
                        onTap: sacarVerdad,
                      ),

                    ],
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
