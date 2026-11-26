import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/cubo_dialog.dart';
import '../widgets/cubo_game_widgets.dart';
import '../core/default_lists.dart';
import '../data/yo_nunca_data.dart';

class YoNuncaScreen extends StatefulWidget {
  final String modo;

  const YoNuncaScreen({super.key, required this.modo});

  @override
  State<YoNuncaScreen> createState() => _YoNuncaScreenState();
}

class _YoNuncaScreenState extends State<YoNuncaScreen> {
  final Random random = Random();

  final TextEditingController fraseController = TextEditingController();

  List<String> frases = [];
  List<String> preguntasRestantes = [];

  String preguntaActual = '';

  bool cargando = true;
  bool configurando = true;

  bool get _isNarrowScreen => MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen => MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 || _isNarrowScreen;

  // La misma lista para el modo normal y por equipos.
  static const String storageKey = 'yo_nunca_frases';
  static const List<String> legacyKeys = [
    'yo_nunca_normal_frases_personalizadas',
    'yo_nunca_equipos_frases_personalizadas',
    'yo_nunca_lobo_frases_personalizadas',
  ];

  Color get accentColor {
    switch (widget.modo) {
      case 'equipos':
        return CuboColors.white;

      case 'lobo':
        return CuboColors.chill;

      default:
        return CuboColors.fiesta;
    }
  }

  IconData get modeIcon {
    switch (widget.modo) {
      case 'equipos':
        return Icons.groups_rounded;

      case 'lobo':
        return Icons.visibility_off_rounded;

      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  String tituloModo() {
    switch (widget.modo) {
      case 'equipos':
        return 'yo nunca equipos';

      case 'lobo':
        return 'yo nunca lobo';

      default:
        return 'yo nunca';
    }
  }

  String nombreModo() {
    switch (widget.modo) {
      case 'equipos':
        return 'YO NUNCA POR EQUIPOS';

      case 'lobo':
        return 'YO NUNCA LOBO';

      default:
        return 'YO NUNCA';
    }
  }

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

    final guardadas = await loadListWithDefaults(
      prefs,
      storageKey,
      yoNuncaFrases,
      legacyKeys: legacyKeys,
    );

    if (!mounted) return;

    final lista = List<String>.from(guardadas);

    String actual = '';
    List<String> restantes = [];

    if (lista.isNotEmpty) {
      restantes = List<String>.from(lista)..shuffle(random);

      actual = restantes.removeLast();
    }

    setState(() {
      frases = lista;
      preguntasRestantes = restantes;
      preguntaActual = actual;
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

    final lower = frase.toLowerCase();

    if (!lower.startsWith('yo nunca')) {
      frase = 'Yo nunca $frase';
    }

    if (!frase.endsWith('.') && !frase.endsWith('?') && !frase.endsWith('!')) {
      frase = '$frase.';
    }

    return frase;
  }

  String limpiarPrefijoImportado(String texto) {
    String limpio = texto.trim();

    // Quita formatos tipo:
    // 1. frase
    // 1) frase
    // - frase
    // • frase
    // * frase

    limpio = limpio.replaceFirst(RegExp(r'^\s*\d+\s*[\.\)\-:]\s*'), '');

    limpio = limpio.replaceFirst(RegExp(r'^\s*[-•*]\s*'), '');

    return limpio.trim();
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
    });

    await guardarFrases();

    return nuevas.length;
  }

  Future<void> mostrarImportarFrases() async {
    final controller = TextEditingController();

    final resultado = await showCuboDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => CuboDialogFrame(
        icon: Icons.content_paste_rounded,
        title: 'importar lista',
        trailing: const CuboDialogCloseButton(),
        children: [
          const CuboDialogNote(
            'Pega todas tus frases aquí. Pon una frase en cada línea. También puedes pegar listas numeradas: 1. ..., 2. ..., 3. ...',
          ),
          SizedBox(
            height: (MediaQuery.sizeOf(dialogContext).height * 0.32).clamp(
              160.0,
              320.0,
            ),
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
                hintText: tr('Yo nunca he...\nYo nunca he...\nYo nunca he...'),
                hintStyle: TextStyle(
                  color: CuboColors.white.withValues(alpha: 0.30),
                  fontSize: 13,
                  height: 1.4,
                ),
                filled: true,
                fillColor: CuboColors.white.withValues(alpha: 0.07),
                contentPadding: const EdgeInsets.all(14),
                enabledBorder: CuboInputs.rounded(
                  BorderSide(color: CuboColors.whiteA(0.28), width: 1.4),
                ),
                focusedBorder: CuboInputs.rounded(
                  const BorderSide(color: CuboColors.white, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          CuboDialogButton(
            label: 'IMPORTAR FRASES',
            onTap: () async {
              final cantidad = await importarFrasesDesdeTexto(controller.text);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext, cantidad);
            },
          ),
        ],
      ),
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

  Future<void> agregarFrase() async {
    final nueva = normalizarFrase(fraseController.text);

    if (nueva.isEmpty) {
      mostrarMensaje('Escribe una frase de Yo Nunca.');
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
      fraseController.clear();
    });

    await guardarFrases();
  }

  Future<void> eliminarFrase(int index) async {
    if (index < 0 || index >= frases.length) {
      return;
    }

    setState(() {
      frases.removeAt(index);
    });

    await guardarFrases();
  }

  void volverAlJuego() {
    if (frases.isEmpty) {
      setState(() {
        preguntaActual = '';
        preguntasRestantes = [];
        configurando = false;
      });

      return;
    }

    final preguntaSigueExistiendo =
        preguntaActual.isNotEmpty && frases.contains(preguntaActual);

    if (!preguntaSigueExistiendo) {
      final baraja = List<String>.from(frases)..shuffle(random);

      final primera = baraja.removeLast();

      setState(() {
        preguntaActual = primera;
        preguntasRestantes = baraja;
        configurando = false;
      });

      return;
    }

    setState(() {
      configurando = false;
    });
  }

  void volverAEditar() {
    setState(() {
      configurando = true;
    });
  }

  void siguientePregunta() {
    if (frases.isEmpty) {
      mostrarMensaje('Añade frases con el botón de editar.');
      return;
    }

    if (preguntasRestantes.isEmpty) {
      preguntasRestantes = List<String>.from(frases)..shuffle(random);

      if (preguntasRestantes.length > 1) {
        preguntasRestantes.remove(preguntaActual);
      }
    }

    if (preguntasRestantes.isEmpty) {
      preguntaActual = frases.first;
      setState(() {});
      return;
    }

    final siguiente = preguntasRestantes.removeLast();

    setState(() {
      preguntaActual = siguiente;
    });
  }

  int get totalPreguntas => frases.length;

  double get progresoRestante {
    if (totalPreguntas == 0) return 0;

    return (preguntasRestantes.length / totalPreguntas).clamp(0.0, 1.0);
  }

  ButtonStyle mainButtonStyle() {
    return CuboButtons.primary(padding: null);
  }

  Widget buildTopBar() {
    final compact = MediaQuery.of(context).size.height < 740;

    if (!configurando) {
      return CuboGameHeader(
        onRules: mostrarNormas,
        status: CuboStatusChip(nombreModo(), dot: accentColor),
      );
    }

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

        CuboGameTitle(
          tituloModo(),
          side: CuboTitleSide.fiesta,
          illustration: 'yo_nunca',
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

                  SizedBox(
                    width: double.infinity,
                    child: _singleLineResponsiveText(
                      nombreModo(),
                      style: const TextStyle(
                        color: CuboColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (widget.modo == 'normal') ...[
                    rulesItem(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Lee el Yo Nunca',
                      text:
                          'Una persona lee en voz alta la frase de “Yo nunca...”.',
                    ),

                    rulesItem(
                      icon: Icons.pan_tool_alt_rounded,
                      title: '¿Lo has hecho?',
                      text:
                          'Todos los que sí lo hayan hecho cumplen un castigo. Los que no, se libran.',
                    ),

                    rulesItem(
                      icon: Icons.arrow_forward_rounded,
                      title: 'Siguiente',
                      text:
                          'Pasad a la siguiente frase y seguid jugando. El clásico Yo Nunca de toda la vida.',
                    ),
                  ],

                  if (widget.modo == 'equipos') ...[
                    rulesItem(
                      icon: Icons.groups_rounded,
                      title: 'Dos equipos',
                      text:
                          'Dividíos en dos equipos. Un equipo lanza una frase de “Yo nunca...” al equipo contrario.',
                    ),

                    rulesItem(
                      icon: Icons.hearing_rounded,
                      title: 'Pasad el número',
                      text:
                          'El otro equipo se coloca en orden. El primero susurra “1” si lo ha hecho o “0” si no. Cada jugador suma 1 si también lo ha hecho o repite el número si no.',
                    ),

                    rulesItem(
                      icon: Icons.tag_rounded,
                      title: 'Solo sabéis cuántos',
                      text:
                          'El número va pasando de jugador en jugador hasta el último. Así se sabe cuántos lo han hecho, pero no quiénes.',
                    ),

                    rulesItem(
                      icon: Icons.psychology_alt_rounded,
                      title: 'Adivinad quién',
                      text:
                          'El equipo que lanzó la pregunta debe adivinar exactamente qué jugadores sí lo han hecho y cuáles no.',
                    ),

                    rulesItem(
                      icon: Icons.swap_horiz_rounded,
                      title: 'Cambiad de equipo',
                      text:
                          'Después se intercambian los papeles y el otro equipo lanza la siguiente frase.',
                    ),
                  ],

                  if (widget.modo == 'lobo') ...[
                    rulesItem(
                      icon: Icons.nightlight_round,
                      title: 'El pueblo duerme',
                      text:
                          'En cada ronda hay un narrador. Todos cierran los ojos y el narrador lee una frase de “Yo nunca...”.',
                    ),

                    rulesItem(
                      icon: Icons.visibility_rounded,
                      title: 'Despiertan los lobos',
                      text:
                          'Solo se levantan o abren los ojos quienes sí hayan hecho lo que dice la frase. Ellos son los lobos de esa ronda.',
                    ),

                    rulesItem(
                      icon: Icons.gps_fixed_rounded,
                      title: 'Los lobos matan',
                      text:
                          'Sin hablar, los lobos eligen a una persona que no se haya levantado. Esa persona será la víctima.',
                    ),

                    rulesItem(
                      icon: Icons.search_rounded,
                      title: 'Descubre los lobos',
                      text:
                          'Todos despiertan. El narrador dice cuántos lobos había y la víctima intenta adivinar quiénes eran.',
                    ),

                    rulesItem(
                      icon: Icons.auto_stories_rounded,
                      title: 'Compra historias',
                      text:
                          'Si la víctima acierta, puede pedir la mitad de las historias de los lobos: deberán contar qué pasó para haber hecho ese “Yo nunca”.',
                    ),

                    rulesItem(
                      icon: Icons.campaign_rounded,
                      title: 'Nuevo narrador',
                      text:
                          'La persona que ha muerto pasa a ser el narrador de la siguiente ronda y lanza el próximo “Yo nunca”.',
                    ),
                  ],

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
      hintText: tr('Ej: he mentido para no salir de fiesta'),
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
        BorderSide(color: accentColor, width: 2),
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
              color: accentColor.withValues(alpha: 0.14),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.70),
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

  Widget buildConfiguracion() {
    final compact = _isCompactScreen;
    final veryNarrow = _isVeryNarrowScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CABECERA
        Row(
          children: [
            Container(
              width: compact ? 40 : 46,
              height: compact ? 40 : 46,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.70),
                  width: 2,
                ),
              ),
              child: Icon(
                modeIcon,
                color: accentColor,
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
                maxLines: 1,
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

        // INPUT
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
                  backgroundColor: accentColor,
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
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: CuboColors.white.withValues(alpha: 0.62),
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        // LA LISTA OCUPA TODO EL ESPACIO RESTANTE
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
                          'Escribe arriba tu primer Yo Nunca',
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

        // VOLVER AL JUEGO
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

  Widget buildQuestionCard() {
    final cardKey = preguntaActual.isEmpty ? 'sin_frases' : preguntaActual;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: CuboCardStack(
        child: CuboPlayCard(
          key: ValueKey(cardKey),
          accent: accentColor,
          maxFontSize: _isCompactScreen ? 27 : 31,
          text: preguntaActual.isEmpty
              ? 'Añade tus frases para empezar'
              : preguntaActual,
        ),
      ),
    );
  }

  Widget buildProgressInfo() {
    return CuboProgressPill(
      label: 'FRASES RESTANTES',
      valueText: '${preguntasRestantes.length} / $totalPreguntas',
      value: progresoRestante,
      accent: accentColor,
    );
  }

  Widget buildJuego() {
    final gap = _isCompactScreen ? 12.0 : 18.0;

    return Column(
      children: [
        Expanded(child: buildQuestionCard()),
        SizedBox(height: gap),
        buildProgressInfo(),
        SizedBox(height: gap),
        CuboActionBar(
          height: _isCompactScreen ? 60 : 68,
          secondaryIcon: Icons.edit_rounded,
          onSecondary: volverAEditar,
          onPrimary: siguientePregunta,
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
      body: CuboGameScope(
        child: CuboBackground(
          halo: CuboHalo.topRight,
          accent: CuboColors.fiesta,
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
      ),
    );
  }
}
