import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';

class PiccoloScreen extends StatefulWidget {
  const PiccoloScreen({super.key});

  @override
  State<PiccoloScreen> createState() => _PiccoloScreenState();
}

class _PiccoloScreenState extends State<PiccoloScreen> {
  final Random random = Random();

  static const String storageKey = 'piccolo_frases_personalizadas';

  final TextEditingController fraseController = TextEditingController();

  List<String> frases = [];
  List<String> frasesDisponibles = [];
  List<String> frasesUsadas = [];

  String fraseActualBase = '';
  String fraseActual = '';

  bool cargando = true;
  bool configurando = false;

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 || _isNarrowScreen;

  @override
  void initState() {
    super.initState();
    cargarFrases();
  }

  @override
  void dispose() {
    fraseController.dispose();
    super.dispose();
  }

  Widget _singleLineResponsiveText(
    String text, {
    required TextStyle style,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, maxLines: 1, softWrap: false, style: style),
    );
  }

  Future<void> cargarFrases() async {
    final prefs = await SharedPreferences.getInstance();

    final guardadas = prefs.getStringList(storageKey) ?? [];

    if (!mounted) return;

    final lista = List<String>.from(guardadas);

    final baraja = List<String>.from(lista)..shuffle(random);

    String actualBase = '';
    String actual = '';

    if (baraja.isNotEmpty) {
      actualBase = baraja.removeLast();
      actual = actualBase;
    }

    setState(() {
      frases = lista;
      frasesDisponibles = baraja;

      frasesUsadas = actualBase.isEmpty ? [] : [actualBase];

      fraseActualBase = actualBase;
      fraseActual = actual;

      cargando = false;
      configurando = false;
    });
  }

  Future<void> guardarFrases() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(storageKey, frases);
  }

  void mostrarMensaje(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CuboColors.blue,
        ),
      );
  }

  String normalizarFrase(String texto) {
    String frase = texto.trim();

    if (frase.isEmpty) {
      return '';
    }

    if (!frase.endsWith('.') && !frase.endsWith('?') && !frase.endsWith('!')) {
      frase = '$frase.';
    }

    return frase;
  }

  String limpiarPrefijoImportado(String texto) {
    String limpio = texto.trim();

    limpio = limpio.replaceFirst(RegExp(r'^\s*\d+\s*[\.\)\-:]\s*'), '');

    limpio = limpio.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '');

    return limpio.trim();
  }

  Future<void> agregarFrase() async {
    final nueva = normalizarFrase(fraseController.text);

    if (nueva.isEmpty) {
      mostrarMensaje('Escribe una frase.');
      return;
    }

    final repetida = frases.any(
      (frase) => frase.toLowerCase() == nueva.toLowerCase(),
    );

    if (repetida) {
      mostrarMensaje('Esta frase ya está añadida.');
      return;
    }

    setState(() {
      frases.add(nueva);

      if (nueva != fraseActualBase) {
        frasesDisponibles.add(nueva);
        frasesDisponibles.shuffle(random);
      }

      fraseController.clear();
    });

    await guardarFrases();
  }

  Future<int> importarFrasesDesdeTexto(String texto) async {
    final lineas = texto
        .split(RegExp(r'\r?\n'))
        .map(limpiarPrefijoImportado)
        .where((linea) => linea.trim().isNotEmpty)
        .toList();

    if (lineas.isEmpty) {
      return 0;
    }

    final existentes = frases
        .map((frase) => frase.toLowerCase().trim())
        .toSet();

    final nuevas = <String>[];

    for (final linea in lineas) {
      final frase = normalizarFrase(linea);

      if (frase.isEmpty) continue;

      final clave = frase.toLowerCase().trim();

      if (!existentes.contains(clave)) {
        existentes.add(clave);
        nuevas.add(frase);
      }
    }

    if (nuevas.isEmpty) {
      return 0;
    }

    setState(() {
      frases.addAll(nuevas);

      frasesDisponibles.addAll(
        nuevas.where((frase) => frase != fraseActualBase),
      );

      frasesDisponibles.shuffle(random);
    });

    await guardarFrases();

    return nuevas.length;
  }

  Future<void> eliminarFrase(int index) async {
    if (index < 0 || index >= frases.length) {
      return;
    }

    final eliminada = frases[index];

    setState(() {
      frases.removeAt(index);

      frasesDisponibles.removeWhere((frase) => frase == eliminada);

      frasesUsadas.removeWhere((frase) => frase == eliminada);

      if (fraseActualBase == eliminada) {
        fraseActualBase = '';
        fraseActual = '';
      }
    });

    await guardarFrases();
  }

  void siguienteFrase() {
    if (frases.isEmpty) {
      mostrarMensaje('Añade frases con el botón de editar.');
      return;
    }

    if (frasesDisponibles.isEmpty) {
      frasesDisponibles = List<String>.from(frases)..shuffle(random);

      frasesUsadas.clear();

      if (frasesDisponibles.length > 1 && fraseActualBase.isNotEmpty) {
        frasesDisponibles.remove(fraseActualBase);
      }
    }

    if (frasesDisponibles.isEmpty) {
      final base = frases.first;

      setState(() {
        fraseActualBase = base;
        fraseActual = base;
        frasesUsadas = [base];
      });

      return;
    }

    final base = frasesDisponibles.removeLast();

    setState(() {
      fraseActualBase = base;
      fraseActual = base;
      frasesUsadas.add(base);
    });
  }

  void volverAEditar() {
    setState(() {
      configurando = true;
    });
  }

  void volverAlJuego() {
    if (frases.isEmpty) {
      setState(() {
        fraseActualBase = '';
        fraseActual = '';
        frasesDisponibles = [];
        frasesUsadas = [];
        configurando = false;
      });

      return;
    }

    final actualSigueExistiendo =
        fraseActualBase.isNotEmpty && frases.contains(fraseActualBase);

    if (!actualSigueExistiendo) {
      final baraja = List<String>.from(frases)..shuffle(random);

      final primera = baraja.removeLast();

      setState(() {
        fraseActualBase = primera;
        fraseActual = primera;

        frasesDisponibles = baraja;
        frasesUsadas = [primera];

        configurando = false;
      });

      return;
    }

    setState(() {
      configurando = false;
    });
  }

  int get totalFrases => frases.length;

  double get progresoRestante {
    if (totalFrases == 0) {
      return 0;
    }

    return (frasesDisponibles.length / totalFrases).clamp(0.0, 1.0);
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: null);
  }

  Widget buildTopBar() {
    if (!configurando) {
      return CuboGameHeader(
        onRules: mostrarNormas,
        status: CuboStatusChip('señala al mas...', dot: CuboColors.fiesta),
      );
    }

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

            CuboCircleButton(
              icon: Icons.question_mark_rounded,
              onTap: mostrarNormas,
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (configurando) ...[
                CuboIllustration('senala', size: compact ? 72 : 100),
                const SizedBox(height: 8),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'señala al mas...',
                  maxLines: 1,
                  style: CuboText.title(size: 42),
                ),
              ),
              const SizedBox(height: 12),
              const CuboPillBar(width: 44, color: CuboColors.fiesta),
            ],
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
                    'SEÑALA AL MÁS PROBABLE',
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 14),

                  rulesItem(
                    icon: Icons.edit_rounded,
                    title: 'Tus frases',
                    text: 'Crea tus propias frases desde el botón de editar.',
                  ),

                  rulesItem(
                    icon: Icons.content_paste_rounded,
                    title: 'Importar lista',
                    text:
                        'Puedes pegar una lista completa con cientos de frases y añadirlas todas de golpe.',
                  ),

                  rulesItem(
                    icon: Icons.record_voice_over_rounded,
                    title: 'Lee la frase',
                    text:
                        'Un jugador lee la frase en voz alta para todo el grupo.',
                  ),

                  rulesItem(
                    icon: Icons.touch_app_rounded,
                    title: 'Todos señalan',
                    text:
                        'Todos señalan a la persona que encaja mejor con la frase.',
                  ),

                  rulesItem(
                    icon: Icons.groups_rounded,
                    title: 'El más señalado',
                    text: 'La persona con más votos tendra castigo.',
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
                          maxLines: 1,
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

  InputDecoration inputDecoration() {
    return InputDecoration(
      hintText: tr('Ej: ¿Quién acabaría antes en la cárcel?'),
      hintStyle: TextStyle(
        color: CuboColors.white.withValues(alpha: 0.42),
        fontSize: 13,
      ),
      filled: true,
      fillColor: CuboColors.white.withValues(alpha: 0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: CuboInputs.rounded(
        BorderSide(color: CuboColors.whiteA(0.28), width: 1.4),
      ),
      focusedBorder: CuboInputs.rounded(
        const BorderSide(color: CuboColors.fiesta, width: 2),
      ),
    );
  }

  Widget buildFraseTile({
    required String frase,
    required int index,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.fromLTRB(
        compact ? 9 : 11,
        compact ? 7 : 8,
        4,
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
              color: CuboColors.fiesta.withValues(alpha: 0.14),
              border: Border.all(
                color: CuboColors.fiesta.withValues(alpha: 0.70),
                width: 1.6,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              frase,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: CuboColors.white,
                fontSize: compact ? 12.5 : 14,
                height: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            tooltip: tr('Eliminar frase'),
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: EdgeInsets.zero,
            onPressed: () => eliminarFrase(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: CuboColors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> mostrarImportarFrases() async {
    final controller = TextEditingController();

    final screenSize = MediaQuery.sizeOf(context);

    final resultado = await showCuboDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: _isVeryNarrowScreen ? 10 : 18,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              _isVeryNarrowScreen ? 14 : 18,
              18,
              _isVeryNarrowScreen ? 14 : 18,
              16,
            ),
            decoration: CuboDecorations.dialog(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CuboColors.fiesta.withValues(alpha: 0.14),
                          border: Border.all(
                            color: CuboColors.fiesta,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.content_paste_rounded,
                          color: CuboColors.fiesta,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: _singleLineResponsiveText(
                          'IMPORTAR LISTA',
                          style: const TextStyle(
                            color: CuboColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: CuboColors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: CuboPillBar(),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    'Pega todas tus frases aquí. Pon una frase en cada línea.',
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.75),
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'También puedes pegar listas numeradas: 1. ..., 2. ..., 3. ...',
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.50),
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: min(360.0, screenSize.height * 0.42),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        color: CuboColors.white,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: CuboColors.white,
                      decoration: InputDecoration(
                        hintText: tr(
                          '¿Quién es más probable que...?\nSeñala a quien...\n¿Quién acabaría antes...?',
                        ),
                        hintStyle: TextStyle(
                          color: CuboColors.white.withValues(alpha: 0.30),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        filled: true,
                        fillColor: CuboColors.white.withValues(alpha: 0.07),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: CuboInputs.rounded(
                          BorderSide(
                            color: CuboColors.whiteA(0.28),
                            width: 1.4,
                          ),
                        ),
                        focusedBorder: CuboInputs.rounded(
                          const BorderSide(color: CuboColors.fiesta, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cantidad = await importarFrasesDesdeTexto(
                          controller.text,
                        );

                        if (!dialogContext.mounted) {
                          return;
                        }

                        Navigator.pop(dialogContext, cantidad);
                      },
                      style: mainButtonStyle(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.playlist_add_rounded),

                          const SizedBox(width: 8),

                          Expanded(
                            child: _singleLineResponsiveText(
                              'IMPORTAR FRASES',
                              alignment: Alignment.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
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

    controller.dispose();

    if (!mounted || resultado == null) {
      return;
    }

    if (resultado == 0) {
      mostrarMensaje('No se ha añadido ninguna frase nueva.');
    } else {
      mostrarMensaje(
        '$resultado ${resultado == 1 ? 'frase importada' : 'frases importadas'}.',
      );
    }
  }

  Widget buildConfiguracion() {
    final compact = _isCompactScreen;

    final veryNarrow = _isVeryNarrowScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: compact ? 40 : 46,
              height: compact ? 40 : 46,
              decoration: BoxDecoration(
                color: CuboColors.fiesta.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CuboColors.fiesta.withValues(alpha: 0.70),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.ads_click_rounded,
                color: CuboColors.fiesta,
                size: compact ? 22 : 25,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _singleLineResponsiveText(
                'TUS FRASES',
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 16 : 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CuboColors.whiteA(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: CuboColors.whiteA(0.28)),
              ),
              child: Text(
                '${frases.length}',
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 12 : 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 12 : 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: fraseController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => agregarFrase(),
                maxLines: 1,
                style: const TextStyle(
                  color: CuboColors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: CuboColors.white,
                decoration: inputDecoration(),
              ),
            ),

            SizedBox(width: veryNarrow ? 6 : 9),

            SizedBox(
              width: veryNarrow
                  ? 46
                  : compact
                  ? 50
                  : 54,
              height: veryNarrow
                  ? 48
                  : compact
                  ? 50
                  : 54,
              child: ElevatedButton(
                onPressed: agregarFrase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CuboColors.fiesta,
                  foregroundColor: CuboColors.blueInk,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: CuboRadii.inputAll,
                  ),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: compact ? 42 : 46,
          child: OutlinedButton(
            onPressed: mostrarImportarFrases,
            style: CuboButtons.secondary(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.content_paste_rounded, size: compact ? 18 : 20),

                const SizedBox(width: 7),

                Expanded(
                  child: _singleLineResponsiveText(
                    'IMPORTAR LISTA',
                    alignment: Alignment.center,
                    style: TextStyle(
                      color: CuboColors.white,
                      fontSize: compact ? 11.5 : 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: compact ? 12 : 16),

        Row(
          children: [
            Expanded(
              child: _singleLineResponsiveText(
                'LISTA DE FRASES',
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.70),
                  fontSize: compact ? 10.5 : 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${frases.length}',
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.62),
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Expanded(
          child: frases.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          color: CuboColors.white.withValues(alpha: 0.38),
                          size: 52,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          'Todavía no has añadido ninguna frase',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white.withValues(alpha: 0.68),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Añade una frase o importa una lista completa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: CuboColors.white.withValues(alpha: 0.44),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: compact ? 8 : 12),
                  itemCount: frases.length,
                  itemBuilder: (context, index) {
                    return buildFraseTile(
                      frase: frases[index],
                      index: index,
                      compact: compact,
                    );
                  },
                ),
        ),

        SizedBox(height: compact ? 8 : 12),

        SizedBox(
          width: double.infinity,
          height: compact ? 56 : 62,
          child: ElevatedButton(
            onPressed: volverAlJuego,
            style: mainButtonStyle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, size: compact ? 21 : 24),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _singleLineResponsiveText(
                      'VOLVER AL JUEGO',
                      alignment: Alignment.center,
                      style: TextStyle(
                        fontSize: compact ? 13 : 15,
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
      ],
    );
  }

  Widget buildPhraseCard() {
    final cardKey = fraseActual.isEmpty ? 'sin_frases' : fraseActual;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CuboCardStack(
        child: CuboPlayCard(
          key: ValueKey(cardKey),
          chip: 'SEÑALA AL MÁS PROBABLE',
          chipIcon: Icons.ads_click_rounded,
          maxFontSize: _isCompactScreen ? 27 : 31,
          text: fraseActual.isEmpty
              ? 'Añade tus frases para empezar'
              : fraseActual,
          hint: fraseActual.isEmpty
              ? 'Pulsa el lápiz para crear o importar tu lista'
              : null,
        ),
      ),
    );
  }

  Widget buildProgressInfo() {
    return CuboProgressPill(
      label: 'FRASES RESTANTES',
      valueText: '${frasesDisponibles.length} / $totalFrases',
      value: progresoRestante,
    );
  }

  Widget buildJuego() {
    final gap = _isCompactScreen ? 12.0 : 18.0;

    return Column(
      children: [
        Expanded(child: buildPhraseCard()),
        SizedBox(height: gap),
        buildProgressInfo(),
        SizedBox(height: gap),
        CuboActionBar(
          height: _isCompactScreen ? 60 : 68,
          secondaryIcon: Icons.edit_rounded,
          onSecondary: volverAEditar,
          onPrimary: siguienteFrase,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: CuboColors.blue,
        body: Center(child: CircularProgressIndicator(color: CuboColors.white)),
      );
    }

    return Scaffold(
      backgroundColor: CuboColors.blue,
      body: CuboGameBackground(
        accent: CuboColors.fiesta,
        halo: CuboHalo.topRight,
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
                    buildTopBar(),

                    SizedBox(height: compact ? 8 : 14),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        child: configurando
                            ? KeyedSubtree(
                                key: const ValueKey('config'),
                                child: buildConfiguracion(),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('game'),
                                child: buildJuego(),
                              ),
                      ),
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
