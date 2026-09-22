import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo_button.dart';

class YoNuncaScreen extends StatefulWidget {
  final String modo;

  const YoNuncaScreen({
    super.key,
    required this.modo,
  });

  @override
  State<YoNuncaScreen> createState() => _YoNuncaScreenState();
}

class _YoNuncaScreenState extends State<YoNuncaScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);

  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentOrange = Color(0xFFFFB86C);
  static const Color accentPurple = Color(0xFF8B5CF6);

  final TextEditingController fraseController =
  TextEditingController();

  List<String> frases = [];
  List<String> preguntasRestantes = [];

  String preguntaActual = '';

  bool cargando = true;
  bool configurando = true;

  bool get _isNarrowScreen =>
      MediaQuery.sizeOf(context).width < 380;

  bool get _isVeryNarrowScreen =>
      MediaQuery.sizeOf(context).width < 340;

  bool get _isCompactScreen =>
      MediaQuery.sizeOf(context).height < 740 ||
          _isNarrowScreen;

  String get storageKey =>
      'yo_nunca_${widget.modo}_frases_personalizadas';

  Color get accentColor {
    switch (widget.modo) {
      case 'equipos':
        return accentOrange;

      case 'lobo':
        return accentPurple;

      default:
        return accentGreen;
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
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        style: style,
      ),
    );
  }

  Future<void> cargarFrases() async {
    final prefs = await SharedPreferences.getInstance();

    final guardadas =
        prefs.getStringList(storageKey) ?? [];

    if (!mounted) return;

    final lista =
    List<String>.from(guardadas);

    String actual = '';
    List<String> restantes = [];

    if (lista.isNotEmpty) {
      restantes =
      List<String>.from(lista)
        ..shuffle(random);

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

    await prefs.setStringList(
      storageKey,
      frases,
    );
  }

  void mostrarMensaje(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: appBlue,
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

    if (!frase.endsWith('.') &&
        !frase.endsWith('?') &&
        !frase.endsWith('!')) {
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

    limpio = limpio.replaceFirst(
      RegExp(r'^\s*\d+\s*[\.\)\-:]\s*'),
      '',
    );

    limpio = limpio.replaceFirst(
      RegExp(r'^\s*[-•*]\s*'),
      '',
    );

    return limpio.trim();
  }

  Future<int> importarFrasesDesdeTexto(
      String texto,
      ) async {
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
    final controller =
    TextEditingController();

    final resultado =
    await showDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor:
      Colors.black.withOpacity(0.55),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
          Colors.transparent,
          insetPadding:
          EdgeInsets.symmetric(
            horizontal:
            _isVeryNarrowScreen
                ? 10
                : 18,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            padding:
            EdgeInsets.fromLTRB(
              _isVeryNarrowScreen
                  ? 14
                  : 18,
              18,
              _isVeryNarrowScreen
                  ? 14
                  : 18,
              16,
            ),
            decoration: BoxDecoration(
              color: appBlue,
              border: Border.all(
                color: appWhite
                    .withOpacity(0.75),
                width: 2.2,
              ),
            ),
            child: ConstrainedBox(
              constraints:
              BoxConstraints(
                maxHeight:
                MediaQuery.sizeOf(
                  context,
                ).height *
                    0.80,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration:
                        BoxDecoration(
                          shape:
                          BoxShape.circle,
                          color: accentColor
                              .withOpacity(
                              0.14),
                          border:
                          Border.all(
                            color:
                            accentColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .content_paste_rounded,
                          color:
                          accentColor,
                          size: 24,
                        ),
                      ),

                      const SizedBox(
                        width: 11,
                      ),

                      Expanded(
                        child:
                        _singleLineResponsiveText(
                          'IMPORTAR LISTA',
                          style:
                          const TextStyle(
                            color:
                            appWhite,
                            fontSize: 22,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            -0.3,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () =>
                            Navigator.pop(
                              dialogContext,
                            ),
                        icon:
                        const Icon(
                          Icons
                              .close_rounded,
                          color:
                          appWhite,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    height: 3,
                    color: appWhite
                        .withOpacity(
                        0.58),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    'Pega todas tus frases aquí. Pon una frase en cada línea.',
                    style: TextStyle(
                      color: appWhite
                          .withOpacity(
                          0.75),
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'También puedes pegar listas numeradas: 1. ..., 2. ..., 3. ...',
                    style: TextStyle(
                      color: appWhite
                          .withOpacity(
                          0.50),
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Expanded(
                    child: TextField(
                      controller:
                      controller,
                      autofocus: true,
                      keyboardType:
                      TextInputType
                          .multiline,
                      textInputAction:
                      TextInputAction
                          .newline,
                      maxLines: null,
                      expands: true,
                      textAlignVertical:
                      TextAlignVertical
                          .top,
                      style:
                      const TextStyle(
                        color: appWhite,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                      cursorColor:
                      appWhite,
                      decoration:
                      InputDecoration(
                        hintText:
                        tr('Yo nunca he...\nYo nunca he...\nYo nunca he...'),
                        hintStyle:
                        TextStyle(
                          color: appWhite
                              .withOpacity(
                              0.30),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        filled: true,
                        fillColor: appWhite
                            .withOpacity(
                            0.07),
                        contentPadding:
                        const EdgeInsets
                            .all(14),
                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .zero,
                          borderSide:
                          BorderSide(
                            color: appWhite
                                .withOpacity(
                                0.25),
                            width: 1.4,
                          ),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .zero,
                          borderSide:
                          BorderSide(
                            color:
                            accentColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    height: 54,
                    child:
                    ElevatedButton(
                      onPressed:
                          () async {
                        final cantidad =
                        await importarFrasesDesdeTexto(
                          controller
                              .text,
                        );

                        if (!dialogContext
                            .mounted) {
                          return;
                        }

                        Navigator.pop(
                          dialogContext,
                          cantidad,
                        );
                      },
                      style:
                      mainButtonStyle(),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        children: [
                          const Icon(
                            Icons
                                .playlist_add_rounded,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          Expanded(
                            child:
                            _singleLineResponsiveText(
                              'IMPORTAR FRASES',
                              alignment:
                              Alignment
                                  .center,
                              style:
                              const TextStyle(
                                fontSize:
                                14,
                                fontWeight:
                                FontWeight
                                    .w900,
                                letterSpacing:
                                0.4,
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

    if (!mounted ||
        resultado == null) {
      return;
    }

    if (resultado == 0) {
      mostrarMensaje(
        'No se ha añadido ninguna frase nueva.',
      );
    } else {
      mostrarMensaje(
        '$resultado ${resultado == 1 ? 'frase importada' : 'frases importadas'}.',
      );
    }
  }

  Future<void> agregarFrase() async {
    final nueva =
    normalizarFrase(fraseController.text);

    if (nueva.isEmpty) {
      mostrarMensaje(
        'Escribe una frase de Yo Nunca.',
      );
      return;
    }

    final repetida = frases.any(
          (frase) =>
      frase.toLowerCase() ==
          nueva.toLowerCase(),
    );

    if (repetida) {
      mostrarMensaje(
        'Esta frase ya está añadida.',
      );
      return;
    }

    setState(() {
      frases.add(nueva);
      fraseController.clear();
    });

    await guardarFrases();
  }

  Future<void> eliminarFrase(
      int index,
      ) async {
    if (index < 0 ||
        index >= frases.length) {
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
        preguntaActual.isNotEmpty &&
            frases.contains(preguntaActual);

    if (!preguntaSigueExistiendo) {
      final baraja =
      List<String>.from(frases)
        ..shuffle(random);

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
      mostrarMensaje(
        'Añade frases con el botón de editar.',
      );
      return;
    }

    if (preguntasRestantes.isEmpty) {
      preguntasRestantes =
      List<String>.from(frases)
        ..shuffle(random);

      if (preguntasRestantes.length > 1) {
        preguntasRestantes.remove(
          preguntaActual,
        );
      }
    }

    if (preguntasRestantes.isEmpty) {
      preguntaActual = frases.first;
      setState(() {});
      return;
    }

    final siguiente =
    preguntasRestantes.removeLast();

    setState(() {
      preguntaActual = siguiente;
    });
  }

  int get totalPreguntas => frases.length;

  double get progresoRestante {
    if (totalPreguntas == 0) return 0;

    return (preguntasRestantes.length /
        totalPreguntas)
        .clamp(0.0, 1.0);
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
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget buildTopBar() {
    final compact =
        MediaQuery.of(context).size.height <
            740;

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
          padding:
          const EdgeInsets.only(left: 28),
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                    Alignment.centerLeft,
                    child: Text(
                      tituloModo(),
                      maxLines: 1,
                      style: const TextStyle(
                        color: appWhite,
                        fontSize: 42,
                        height: 2.20,
                        fontWeight:
                        FontWeight.w900,
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
                    appWhite.withOpacity(
                      0.58,
                    ),
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
      margin:
      const EdgeInsets.only(bottom: 10),
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
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
                  child:
                  _singleLineResponsiveText(
                    tr(title).toUpperCase(),
                    style:
                    const TextStyle(
                      color: appWhite,
                      fontSize: 13.5,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  text,
                  style: TextStyle(
                    color:
                    appWhite.withOpacity(
                      0.72,
                    ),
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight:
                    FontWeight.w600,
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
      barrierColor:
      Colors.black.withOpacity(0.45),
      builder: (_) => Dialog(
        backgroundColor:
        Colors.transparent,
        insetPadding:
        const EdgeInsets.symmetric(
          horizontal: 22,
        ),
        child: Container(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color:
              appWhite.withOpacity(0.75),
              width: 2.2,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
              MediaQuery.of(context)
                  .size
                  .height *
                  0.78,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration:
                        BoxDecoration(
                          shape:
                          BoxShape.circle,
                          border:
                          Border.all(
                            color: appWhite
                                .withOpacity(
                                0.85),
                            width: 2.1,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .question_mark_rounded,
                          color: appWhite,
                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Expanded(
                        child: Text(
                          'normas',
                          style: TextStyle(
                            color: appWhite,
                            fontSize: 38,
                            height: 0.9,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            -0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    height: 3,
                    color:
                    appWhite.withOpacity(
                      0.58,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child:
                    _singleLineResponsiveText(
                      nombreModo(),
                      style:
                      const TextStyle(
                        color: appWhite,
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

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
                      onPressed: () =>
                          Navigator.pop(
                            context,
                          ),
                      style:
                      mainButtonStyle(),
                      child:
                      const Padding(
                        padding:
                        EdgeInsets
                            .symmetric(
                          vertical: 14,
                        ),
                        child: Text(
                          'ENTENDIDO',
                          maxLines: 1,
                          style:
                          TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight
                                .w900,
                            letterSpacing:
                            0.4,
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
      hintText:
      tr('Ej: he mentido para no salir de fiesta'),
      hintStyle: TextStyle(
        color: appWhite.withOpacity(0.42),
        fontSize: 13,
      ),
      filled: true,
      fillColor:
      appWhite.withOpacity(0.07),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color:
          appWhite.withOpacity(0.28),
          width: 1.4,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(
          color: accentColor,
          width: 2,
        ),
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
      margin:
      const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.fromLTRB(
        compact ? 9 : 11,
        compact ? 7 : 8,
        4,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: appWhite.withOpacity(0.07),
        border: Border(
          left: BorderSide(
            color: accentColor,
            width: 6,
          ),
          bottom: BorderSide(
            color:
            appWhite.withOpacity(0.25),
            width: 2,
          ),
          top: BorderSide(
            color:
            appWhite.withOpacity(0.15),
          ),
          right: BorderSide(
            color:
            appWhite.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 31 : 35,
            height: compact ? 31 : 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                appWhite.withOpacity(
                  0.68,
                ),
                width: 1.6,
              ),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: appWhite,
                fontSize:
                compact ? 12 : 13,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              frase,
              maxLines: 2,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color: appWhite,
                fontSize:
                compact ? 12.5 : 14,
                height: 1.2,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            tooltip: tr('Eliminar frase'),
            onPressed: () =>
                eliminarFrase(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color:
              appWhite.withOpacity(
                0.78,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfiguracion() {
    final compact = _isCompactScreen;
    final veryNarrow =
        _isVeryNarrowScreen;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        // CABECERA
        Row(
          children: [
            Container(
              width: compact ? 40 : 46,
              height: compact ? 40 : 46,
              decoration: BoxDecoration(
                color:
                accentColor.withOpacity(0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                  accentColor.withOpacity(
                    0.70,
                  ),
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
              child:
              _singleLineResponsiveText(
                'TUS FRASES',
                style: TextStyle(
                  color: appWhite,
                  fontSize:
                  compact ? 16 : 19,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                appWhite.withOpacity(0.09),
                border: Border.all(
                  color:
                  appWhite.withOpacity(
                    0.22,
                  ),
                ),
              ),
              child: Text(
                '${frases.length}',
                maxLines: 1,
                style: TextStyle(
                  color: appWhite,
                  fontSize:
                  compact ? 12 : 14,
                  fontWeight:
                  FontWeight.w900,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height: compact ? 12 : 16,
        ),

        // INPUT
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: fraseController,
                textInputAction:
                TextInputAction.done,
                onSubmitted:
                    (_) => agregarFrase(),
                maxLines: 1,
                style: const TextStyle(
                  color: appWhite,
                  fontWeight:
                  FontWeight.w700,
                ),
                cursorColor: appWhite,
                decoration:
                inputDecoration(),
              ),
            ),

            SizedBox(
              width: veryNarrow ? 6 : 9,
            ),

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
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  accentColor,
                  foregroundColor:
                  appWhite,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
                  shape:
                  const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.zero,
                  ),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 28,
                ),
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
            style: OutlinedButton.styleFrom(
              foregroundColor: appWhite,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              side: BorderSide(
                color:
                appWhite.withOpacity(0.45),
                width: 1.5,
              ),
              shape:
              const RoundedRectangleBorder(
                borderRadius:
                BorderRadius.zero,
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.content_paste_rounded,
                  size: compact ? 18 : 20,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child:
                  _singleLineResponsiveText(
                    'IMPORTAR LISTA',
                    alignment:
                    Alignment.center,
                    style: TextStyle(
                      color: appWhite,
                      fontSize:
                      compact ? 11.5 : 13,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: compact ? 12 : 16,
        ),

        Row(
          children: [
            Expanded(
              child:
              _singleLineResponsiveText(
                'LISTA DE FRASES',
                style: TextStyle(
                  color: appWhite
                      .withOpacity(0.70),
                  fontSize:
                  compact ? 10.5 : 12,
                  fontWeight:
                  FontWeight.w900,
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
                color:
                appWhite.withOpacity(
                  0.62,
                ),
                fontSize:
                compact ? 11 : 12,
                fontWeight:
                FontWeight.w900,
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
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 20,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .edit_note_rounded,
                    color: appWhite
                        .withOpacity(
                      0.38,
                    ),
                    size: 52,
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Todavía no has añadido ninguna frase',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.68,
                      ),
                      fontSize: 14,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Escribe arriba tu primer Yo Nunca',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.44,
                      ),
                      fontSize: 12,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),
                ],
              ),
            ),
          )
              : ListView.builder(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior
                .onDrag,
            padding:
            EdgeInsets.only(
              bottom:
              compact ? 8 : 12,
            ),
            itemCount:
            frases.length,
            itemBuilder:
                (context, index) {
              return buildFraseTile(
                frase:
                frases[index],
                index: index,
                compact: compact,
              );
            },
          ),
        ),

        SizedBox(
          height: compact ? 8 : 12,
        ),

        // VOLVER AL JUEGO
        SizedBox(
          width: double.infinity,
          height: compact ? 56 : 62,
          child: ElevatedButton(
            onPressed: volverAlJuego,
            style: mainButtonStyle(),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .arrow_back_rounded,
                    size:
                    compact ? 21 : 24,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child:
                    _singleLineResponsiveText(
                      'VOLVER AL JUEGO',
                      alignment:
                      Alignment.center,
                      style: TextStyle(
                        fontSize:
                        compact ? 13 : 15,
                        fontWeight:
                        FontWeight.w900,
                        letterSpacing:
                        0.4,
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
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Container(
                width: 94,
                height: 94,
                decoration:
                BoxDecoration(
                  shape:
                  BoxShape.circle,
                  color: accentColor
                      .withOpacity(0.15),
                  border: Border.all(
                    color: accentColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  modeIcon,
                  color: accentColor,
                  size: 50,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              AnimatedSwitcher(
                duration:
                const Duration(
                  milliseconds: 280,
                ),
                transitionBuilder:
                    (child, animation) {
                  final slide =
                  Tween<Offset>(
                    begin:
                    const Offset(
                      0,
                      0.08,
                    ),
                    end: Offset.zero,
                  ).animate(
                    animation,
                  );

                  return SlideTransition(
                    position: slide,
                    child:
                    FadeTransition(
                      opacity:
                      animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  preguntaActual.isEmpty
                      ? 'Añade tus frases para empezar'
                      : preguntaActual,
                  key: ValueKey(
                    preguntaActual.isEmpty
                        ? 'sin_frases'
                        : preguntaActual,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: appWhite,
                    fontSize: 32,
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
            Expanded(
              child:
              _singleLineResponsiveText(
                'FRASES RESTANTES',
                style: TextStyle(
                  color: appWhite
                      .withOpacity(0.76),
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${preguntasRestantes.length} / $totalPreguntas',
              maxLines: 1,
              style:
              const TextStyle(
                color: appWhite,
                fontSize: 14,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            end:
            progresoRestante,
          ),
          duration:
          const Duration(
            milliseconds: 350,
          ),
          curve:
          Curves.easeOutCubic,
          builder:
              (context, value, _) {
            return Container(
              height: 14,
              decoration:
              BoxDecoration(
                color: appWhite
                    .withOpacity(
                    0.15),
                borderRadius:
                BorderRadius
                    .circular(7),
                border: Border.all(
                  color: appWhite
                      .withOpacity(
                      0.34),
                  width: 1.2,
                ),
              ),
              clipBehavior:
              Clip.antiAlias,
              child:
              LinearProgressIndicator(
                value: value,
                minHeight: 14,
                backgroundColor:
                Colors.transparent,
                valueColor:
                AlwaysStoppedAnimation<
                    Color>(
                  accentColor,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildActionButton({
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
          borderRadius:
          BorderRadius.circular(
            16,
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius:
            BorderRadius.circular(
              16,
            ),
            child: Container(
              decoration:
              BoxDecoration(
                borderRadius:
                BorderRadius
                    .circular(16),
                border: Border.all(
                  color: appWhite
                      .withOpacity(
                      0.28),
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    backgroundColor
                        .withOpacity(
                        0.28),
                    blurRadius: 16,
                    offset:
                    const Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color:
                  foregroundColor,
                  size: 54,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildJuego() {
    return Column(
      children: [
        Expanded(
          child:
          buildQuestionCard(),
        ),

        SizedBox(
          height:
          _isCompactScreen
              ? 9
              : 14,
        ),

        buildProgressInfo(),

        SizedBox(
          height:
          _isCompactScreen
              ? 9
              : 14,
        ),

        Row(
          children: [
            buildActionButton(
              icon:
              Icons.edit_rounded,
              backgroundColor:
              appBlue,
              foregroundColor:
              appWhite,
              onTap:
              volverAEditar,
            ),

            const SizedBox(
              width: 12,
            ),

            buildActionButton(
              icon: Icons
                  .arrow_forward_rounded,
              backgroundColor:
              appWhite,
              foregroundColor:
              appBlue,
              onTap:
              siguientePregunta,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    if (cargando) {
      return const Scaffold(
        backgroundColor: appBlue,
        body: Center(
          child:
          CircularProgressIndicator(
            color: appWhite,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) {
            final narrow =
                constraints.maxWidth <
                    380;

            final veryNarrow =
                constraints.maxWidth <
                    340;

            final compact =
                constraints.maxHeight <
                    740 ||
                    narrow;

            final horizontalPadding =
            veryNarrow
                ? 8.0
                : compact
                ? 12.0
                : 18.0;

            final verticalPadding =
            compact
                ? 10.0
                : 18.0;

            return Padding(
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                compact ? 10 : 16,
              ),
              child: Column(
                children: [
                  buildTopBar(),

                  SizedBox(
                    height:
                    compact
                        ? 8
                        : 14,
                  ),

                  Expanded(
                    child:
                    AnimatedSwitcher(
                      duration:
                      const Duration(
                        milliseconds:
                        280,
                      ),
                      child: configurando
                          ? KeyedSubtree(
                        key:
                        const ValueKey(
                          'config',
                        ),
                        child:
                        buildConfiguracion(),
                      )
                          : KeyedSubtree(
                        key:
                        const ValueKey(
                          'game',
                        ),
                        child:
                        buildJuego(),
                      ),
                    ),
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