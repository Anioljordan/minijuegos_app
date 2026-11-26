import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_game_widgets.dart';
import '../data/prueba_verdad_data.dart' as datos;
import '../core/default_lists.dart';

class PruebaVerdadScreen extends StatefulWidget {
  const PruebaVerdadScreen({super.key});

  @override
  State<PruebaVerdadScreen> createState() => _PruebaVerdadScreenState();
}

class _PruebaVerdadScreenState extends State<PruebaVerdadScreen> {
  final Random random = Random();

  static const String storageVerdades = 'prueba_verdad_verdades_personalizadas';

  static const String storagePruebas = 'prueba_verdad_pruebas_personalizadas';

  final TextEditingController textoController = TextEditingController();

  List<String> verdades = [];
  List<String> pruebas = [];

  List<String> verdadesDisponibles = [];
  List<String> verdadesUsadas = [];

  List<String> pruebasDisponibles = [];
  List<String> pruebasUsadas = [];

  String textoActual = 'Elige Prueba o Verdad';
  String cartaActualBase = '';
  String tipoActual = '';

  bool cargando = true;
  bool configurando = false;

  // Qué lista estamos editando
  String tipoEditor = 'VERDAD';

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 || _isNarrowScreen;

  List<String> get listaEditor => tipoEditor == 'VERDAD' ? verdades : pruebas;

  Color get editorAccent =>
      tipoEditor == 'VERDAD' ? CuboColors.chill : CuboColors.fiesta;

  String get editorSingular => tipoEditor == 'VERDAD' ? 'verdad' : 'prueba';

  String get editorPlural => tipoEditor == 'VERDAD' ? 'verdades' : 'pruebas';

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  @override
  void dispose() {
    textoController.dispose();
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

  Future<void> cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();

    final verdadesGuardadas =
        await loadListWithDefaults(prefs, storageVerdades, datos.preguntasVerdad);

    final pruebasGuardadas =
        await loadListWithDefaults(prefs, storagePruebas, datos.pruebas);

    if (!mounted) return;

    final barajaVerdades = List<String>.from(verdadesGuardadas)
      ..shuffle(random);

    final barajaPruebas = List<String>.from(pruebasGuardadas)..shuffle(random);

    setState(() {
      verdades = List<String>.from(verdadesGuardadas);

      pruebas = List<String>.from(pruebasGuardadas);

      verdadesDisponibles = barajaVerdades;

      pruebasDisponibles = barajaPruebas;

      verdadesUsadas = [];
      pruebasUsadas = [];

      cargando = false;
      configurando = false;
    });
  }

  Future<void> guardarVerdades() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(storageVerdades, verdades);
  }

  Future<void> guardarPruebas() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(storagePruebas, pruebas);
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: CuboColors.blue,
        ),
      );
  }

  String normalizarTexto(String texto) {
    String limpio = texto.trim();

    if (limpio.isEmpty) {
      return '';
    }

    if (!limpio.endsWith('.') &&
        !limpio.endsWith('?') &&
        !limpio.endsWith('!')) {
      limpio = '$limpio.';
    }

    return limpio;
  }

  String limpiarPrefijoImportado(String texto) {
    String limpio = texto.trim();

    limpio = limpio.replaceFirst(RegExp(r'^\s*\d+\s*[\.\)\-:]\s*'), '');

    limpio = limpio.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '');

    return limpio.trim();
  }

  Future<void> agregarTexto() async {
    final nuevo = normalizarTexto(textoController.text);

    if (nuevo.isEmpty) {
      mostrarMensaje('Escribe una $editorSingular.');
      return;
    }

    final repetido = listaEditor.any(
      (texto) => texto.toLowerCase() == nuevo.toLowerCase(),
    );

    if (repetido) {
      mostrarMensaje('Esta $editorSingular ya está añadida.');
      return;
    }

    setState(() {
      if (tipoEditor == 'VERDAD') {
        verdades.add(nuevo);
        verdadesDisponibles.add(nuevo);
        verdadesDisponibles.shuffle(random);
      } else {
        pruebas.add(nuevo);
        pruebasDisponibles.add(nuevo);
        pruebasDisponibles.shuffle(random);
      }

      textoController.clear();
    });

    if (tipoEditor == 'VERDAD') {
      await guardarVerdades();
    } else {
      await guardarPruebas();
    }
  }

  Future<int> importarDesdeTexto(String texto) async {
    final lineas = texto
        .split(RegExp(r'\r?\n'))
        .map(limpiarPrefijoImportado)
        .where((linea) => linea.trim().isNotEmpty)
        .toList();

    if (lineas.isEmpty) {
      return 0;
    }

    final existentes = listaEditor
        .map((texto) => texto.toLowerCase().trim())
        .toSet();

    final nuevas = <String>[];

    for (final linea in lineas) {
      final normalizada = normalizarTexto(linea);

      if (normalizada.isEmpty) continue;

      final clave = normalizada.toLowerCase().trim();

      if (!existentes.contains(clave)) {
        existentes.add(clave);
        nuevas.add(normalizada);
      }
    }

    if (nuevas.isEmpty) {
      return 0;
    }

    setState(() {
      if (tipoEditor == 'VERDAD') {
        verdades.addAll(nuevas);
        verdadesDisponibles.addAll(nuevas);
        verdadesDisponibles.shuffle(random);
      } else {
        pruebas.addAll(nuevas);
        pruebasDisponibles.addAll(nuevas);
        pruebasDisponibles.shuffle(random);
      }
    });

    if (tipoEditor == 'VERDAD') {
      await guardarVerdades();
    } else {
      await guardarPruebas();
    }

    return nuevas.length;
  }

  Future<void> eliminarTexto(int index) async {
    if (index < 0 || index >= listaEditor.length) {
      return;
    }

    final eliminado = listaEditor[index];

    setState(() {
      if (tipoEditor == 'VERDAD') {
        verdades.removeAt(index);

        verdadesDisponibles.removeWhere((e) => e == eliminado);

        verdadesUsadas.removeWhere((e) => e == eliminado);
      } else {
        pruebas.removeAt(index);

        pruebasDisponibles.removeWhere((e) => e == eliminado);

        pruebasUsadas.removeWhere((e) => e == eliminado);
      }

      if (cartaActualBase == eliminado && tipoActual == tipoEditor) {
        cartaActualBase = '';
        tipoActual = '';
        textoActual = 'Elige Prueba o Verdad';
      }
    });

    if (tipoEditor == 'VERDAD') {
      await guardarVerdades();
    } else {
      await guardarPruebas();
    }
  }

  void sacarVerdad() {
    if (verdades.isEmpty) {
      mostrarMensaje('Añade verdades desde el botón de editar.');
      return;
    }

    if (verdadesDisponibles.isEmpty) {
      verdadesDisponibles = List<String>.from(verdades)..shuffle(random);

      verdadesUsadas.clear();

      if (verdadesDisponibles.length > 1 && tipoActual == 'VERDAD') {
        verdadesDisponibles.remove(cartaActualBase);
      }
    }

    if (verdadesDisponibles.isEmpty) {
      return;
    }

    final verdad = verdadesDisponibles.removeLast();

    setState(() {
      tipoActual = 'VERDAD';
      cartaActualBase = verdad;
      textoActual = verdad;

      verdadesUsadas.add(verdad);
    });
  }

  void sacarPrueba() {
    if (pruebas.isEmpty) {
      mostrarMensaje('Añade pruebas desde el botón de editar.');
      return;
    }

    if (pruebasDisponibles.isEmpty) {
      pruebasDisponibles = List<String>.from(pruebas)..shuffle(random);

      pruebasUsadas.clear();

      if (pruebasDisponibles.length > 1 && tipoActual == 'PRUEBA') {
        pruebasDisponibles.remove(cartaActualBase);
      }
    }

    if (pruebasDisponibles.isEmpty) {
      return;
    }

    final prueba = pruebasDisponibles.removeLast();

    setState(() {
      tipoActual = 'PRUEBA';
      cartaActualBase = prueba;
      textoActual = prueba;

      pruebasUsadas.add(prueba);
    });
  }

  void abrirEditor() {
    setState(() {
      configurando = true;
    });
  }

  void volverAlJuego() {
    setState(() {
      configurando = false;
    });
  }

  int get totalCartas => verdades.length + pruebas.length;

  int get cartasRestantes =>
      verdadesDisponibles.length + pruebasDisponibles.length;

  double get progresoRestante {
    if (totalCartas == 0) {
      return 0;
    }

    return (cartasRestantes / totalCartas).clamp(0.0, 1.0);
  }

  Color get cardAccent {
    if (tipoActual == 'VERDAD') {
      return CuboColors.chill;
    }

    if (tipoActual == 'PRUEBA') {
      return CuboColors.fiesta;
    }

    return CuboColors.blueLight;
  }

  IconData get cardIcon {
    if (tipoActual == 'VERDAD') {
      return Icons.question_answer_rounded;
    }

    if (tipoActual == 'PRUEBA') {
      return Icons.local_fire_department_rounded;
    }

    return Icons.compare_arrows_rounded;
  }

  ButtonStyle mainButtonStyle() =>
      CuboButtons.primary(padding: EdgeInsets.zero);

  Widget buildTopBar() {
    if (!configurando) {
      return CuboGameHeader(
        onRules: mostrarNormas,
        status: CuboStatusChip('prueba o verdad', dot: CuboColors.fiesta),
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
              size: compact ? 44 : 50,
              onTap: mostrarNormas,
            ),
          ],
        ),

        SizedBox(height: compact ? 10 : 16),

        CuboGameTitle(
          'prueba o verdad',
          side: CuboTitleSide.fiesta,
          illustration: 'prueba_verdad',
          compact: compact,
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
                    'PRUEBA O VERDAD',
                    style: TextStyle(
                      color: CuboColors.white,
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
                    icon: Icons.edit_rounded,
                    title: 'Tus cartas',
                    text:
                        'Puedes crear tus propias verdades y pruebas desde el pequeño botón de editar.',
                  ),

                  rulesItem(
                    icon: Icons.content_paste_rounded,
                    title: 'Importar',
                    text:
                        'Puedes pegar listas completas con cientos de pruebas o verdades.',
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
      hintText: tr(
        tipoEditor == 'VERDAD'
            ? 'Ej: ¿Cuál ha sido tu peor cita?'
            : 'Ej: Imita a alguien del grupo',
      ),
      hintStyle: TextStyle(
        color: CuboColors.white.withValues(alpha: 0.42),
        fontSize: 13,
      ),
      filled: true,
      fillColor: CuboColors.white.withValues(alpha: 0.07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: CuboInputs.rounded(
        BorderSide(color: CuboColors.white.withValues(alpha: 0.28), width: 1.4),
      ),
      focusedBorder: CuboInputs.rounded(
        BorderSide(color: editorAccent, width: 2),
      ),
    );
  }

  Widget buildEditorTabs() {
    return Row(
      children: [
        Expanded(
          child: _editorTab(
            title: 'VERDADES',
            selected: tipoEditor == 'VERDAD',
            color: CuboColors.chill,
            onTap: () {
              setState(() {
                tipoEditor = 'VERDAD';
                textoController.clear();
              });
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _editorTab(
            title: 'PRUEBAS',
            selected: tipoEditor == 'PRUEBA',
            color: CuboColors.fiesta,
            onTap: () {
              setState(() {
                tipoEditor = 'PRUEBA';
                textoController.clear();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _editorTab({
    required String title,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? color : CuboColors.white.withValues(alpha: 0.07),
      borderRadius: CuboRadii.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 43,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: CuboRadii.mdAll,
            border: Border.all(
              color: selected
                  ? color
                  : CuboColors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _singleLineResponsiveText(
            title,
            alignment: Alignment.center,
            style: TextStyle(
              color: selected
                  ? (title == 'PRUEBAS' ? CuboColors.blue : CuboColors.white)
                  : CuboColors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextoTile({
    required String texto,
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
              color: editorAccent.withValues(alpha: 0.16),
              border: Border.all(color: editorAccent, width: 1.6),
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
              texto,
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
            tooltip: tr('Eliminar'),
            onPressed: () => eliminarTexto(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: CuboColors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> mostrarImportarLista() async {
    final controller = TextEditingController();

    final size = MediaQuery.sizeOf(context);

    final tipo = tipoEditor;

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
                          color: editorAccent.withValues(alpha: 0.14),
                          border: Border.all(color: editorAccent, width: 2),
                        ),
                        child: Icon(
                          Icons.content_paste_rounded,
                          color: editorAccent,
                          size: 24,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: _singleLineResponsiveText(
                          'IMPORTAR ${tipo == 'VERDAD' ? 'VERDADES' : 'PRUEBAS'}',
                          style: const TextStyle(
                            color: CuboColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
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
                    'Pega una ${tipo == 'VERDAD' ? 'verdad' : 'prueba'} en cada línea.',
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.75),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'También puedes pegar listas numeradas: 1. ..., 2. ..., 3. ...',
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.50),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: min(360.0, size.height * 0.42),
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
                          tipo == 'VERDAD'
                              ? '¿Cuál es...?\n¿Alguna vez...?\n¿Quién del grupo...?'
                              : 'Haz...\nImita...\nDeja que alguien...',
                        ),
                        hintStyle: TextStyle(
                          color: CuboColors.white.withValues(alpha: 0.30),
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: CuboColors.white.withValues(alpha: 0.07),
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: CuboInputs.rounded(
                          BorderSide(
                            color: CuboColors.white.withValues(alpha: 0.25),
                            width: 1.4,
                          ),
                        ),
                        focusedBorder: CuboInputs.rounded(
                          BorderSide(color: editorAccent, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        final cantidad = await importarDesdeTexto(
                          controller.text,
                        );

                        if (!dialogContext.mounted) {
                          return;
                        }

                        Navigator.pop(dialogContext, cantidad);
                      },
                      style: mainButtonStyle(),
                      child: _singleLineResponsiveText(
                        'IMPORTAR LISTA',
                        alignment: Alignment.center,
                        style: const TextStyle(
                          fontSize: 14,
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
      },
    );

    controller.dispose();

    if (!mounted || resultado == null) {
      return;
    }

    if (resultado == 0) {
      mostrarMensaje('No se ha añadido ninguna carta nueva.');
    } else {
      mostrarMensaje(
        '$resultado ${resultado == 1 ? 'carta importada' : 'cartas importadas'}.',
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
            Icon(
              Icons.edit_note_rounded,
              color: editorAccent,
              size: compact ? 28 : 32,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: _singleLineResponsiveText(
                'TUS CARTAS',
                style: TextStyle(
                  color: CuboColors.white,
                  fontSize: compact ? 16 : 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            Text(
              '${verdades.length + pruebas.length}',
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.65),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        SizedBox(height: compact ? 10 : 14),

        buildEditorTabs(),

        SizedBox(height: compact ? 10 : 14),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textoController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => agregarTexto(),
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
                onPressed: agregarTexto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: editorAccent,
                  foregroundColor: tipoEditor == 'PRUEBA'
                      ? CuboColors.blue
                      : CuboColors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: CuboRadii.mdAll,
                  ),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: compact ? 42 : 46,
          child: OutlinedButton(
            onPressed: mostrarImportarLista,
            style: CuboButtons.secondary(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              children: [
                const Icon(Icons.content_paste_rounded),
                const SizedBox(width: 7),
                Expanded(
                  child: _singleLineResponsiveText(
                    'IMPORTAR ${tipoEditor == 'VERDAD' ? 'VERDADES' : 'PRUEBAS'}',
                    alignment: Alignment.center,
                    style: const TextStyle(
                      color: CuboColors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
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
                tipoEditor == 'VERDAD'
                    ? 'LISTA DE VERDADES'
                    : 'LISTA DE PRUEBAS',
                style: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.70),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            Text(
              '${listaEditor.length}',
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.62),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Expanded(
          child: listaEditor.isEmpty
              ? Center(
                  child: Text(
                    'Todavía no has añadido ${tipoEditor == 'VERDAD' ? 'verdades' : 'pruebas'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CuboColors.white.withValues(alpha: 0.55),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: listaEditor.length,
                  itemBuilder: (context, index) {
                    return buildTextoTile(
                      texto: listaEditor[index],
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
            child: _singleLineResponsiveText(
              'VOLVER AL JUEGO',
              alignment: Alignment.center,
              style: TextStyle(
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCard() {
    final compact = _isCompactScreen;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CuboCardStack(
        child: CuboPlayCard(
          key: ValueKey('$tipoActual|$textoActual'),
          chip: tipoActual.isEmpty ? 'ELIGE' : tipoActual,
          chipIcon: cardIcon,
          accent: cardAccent,
          maxFontSize: compact ? 25 : 29,
          leading: CuboCardBadge(
            icon: cardIcon,
            accent: cardAccent,
            size: compact ? 58 : 72,
          ),
          text: textoActual,
        ),
      ),
    );
  }

  Widget buildProgressInfo() {
    return CuboProgressPill(
      label: 'RESTANTES',
      valueText: '$cartasRestantes / $totalCartas',
      value: progresoRestante,
      caption:
          'Verdades ${verdadesDisponibles.length} · Pruebas ${pruebasDisponibles.length}',
      labelTrailing: CuboPressable(
        onTap: abrirEditor,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CuboColors.whiteA(0.28), width: 1.2),
          ),
          child: Icon(
            Icons.edit_rounded,
            color: CuboColors.whiteA(0.65),
            size: 15,
          ),
        ),
      ),
    );
  }

  Widget buildJuego() {
    final compact = _isCompactScreen;
    final gap = compact ? 12.0 : 18.0;

    return Column(
      children: [
        Expanded(child: buildCard()),
        SizedBox(height: gap),
        buildProgressInfo(),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              child: CuboChoiceButton(
                label: 'PRUEBA',
                icon: Icons.local_fire_department_rounded,
                accent: CuboColors.fiesta,
                height: compact ? 80 : 92,
                onTap: sacarPrueba,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CuboChoiceButton(
                label: 'VERDAD',
                icon: Icons.question_answer_rounded,
                accent: CuboColors.chill,
                primary: true,
                height: compact ? 80 : 92,
                onTap: sacarVerdad,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: CuboColors.blue,
        body: CuboGameBackground(
          accent: CuboColors.fiesta,
          halo: CuboHalo.topRight,
          child: Center(
            child: CircularProgressIndicator(color: CuboColors.white),
          ),
        ),
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
