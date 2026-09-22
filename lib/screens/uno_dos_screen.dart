import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_logo_button.dart';

class UnoDosScreen extends StatefulWidget {
  const UnoDosScreen({super.key});

  @override
  State<UnoDosScreen> createState() => _UnoDosScreenState();
}

class _UnoDosScreenState extends State<UnoDosScreen> {
  final Random random = Random();

  static const Color appBlue = Color(0xFF2F4F9C);
  static const Color appWhite = Color(0xFFF7F7F7);
  static const Color accentTurquoise = Color(0xFF12B8C4);

  static const String storageKey =
      'uno_dos_acciones_personalizadas';

  final TextEditingController accionController =
  TextEditingController();

  List<String> acciones = [];
  List<String> accionesDisponibles = [];
  List<String> accionesUsadas = [];

  String accionActual = '';

  bool cargando = true;
  bool configurando = false;

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
    cargarAcciones();
  }

  @override
  void dispose() {
    accionController.dispose();
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

  Future<void> cargarAcciones() async {
    final prefs =
    await SharedPreferences.getInstance();

    final guardadas =
        prefs.getStringList(storageKey) ?? [];

    if (!mounted) return;

    final lista =
    List<String>.from(guardadas);

    final baraja =
    List<String>.from(lista)
      ..shuffle(random);

    String actual = '';

    if (baraja.isNotEmpty) {
      actual = baraja.removeLast();
    }

    setState(() {
      acciones = lista;
      accionesDisponibles = baraja;
      accionesUsadas =
      actual.isEmpty ? [] : [actual];

      accionActual = actual;

      cargando = false;
      configurando = false;
    });
  }

  Future<void> guardarAcciones() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setStringList(
      storageKey,
      acciones,
    );
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
          backgroundColor: appBlue,
        ),
      );
  }

  String normalizarAccion(String texto) {
    String accion = texto.trim();

    if (accion.isEmpty) {
      return '';
    }

    if (!accion.endsWith('.') &&
        !accion.endsWith('?') &&
        !accion.endsWith('!')) {
      accion = '$accion.';
    }

    return accion;
  }

  String limpiarPrefijoImportado(
      String texto,
      ) {
    String limpio = texto.trim();

    // 1. Acción
    // 1) Acción
    // 1- Acción
    // - Acción
    // • Acción
    // * Acción

    limpio = limpio.replaceFirst(
      RegExp(
        r'^\s*\d+\s*[\.\)\-:]\s*',
      ),
      '',
    );

    limpio = limpio.replaceFirst(
      RegExp(r'^\s*[-•*]\s*'),
      '',
    );

    return limpio.trim();
  }

  Future<void> agregarAccion() async {
    final nueva =
    normalizarAccion(
      accionController.text,
    );

    if (nueva.isEmpty) {
      mostrarMensaje(
        'Escribe una acción.',
      );
      return;
    }

    final repetida = acciones.any(
          (accion) =>
      accion.toLowerCase() ==
          nueva.toLowerCase(),
    );

    if (repetida) {
      mostrarMensaje(
        'Esta acción ya está añadida.',
      );
      return;
    }

    setState(() {
      acciones.add(nueva);

      if (nueva != accionActual) {
        accionesDisponibles.add(
          nueva,
        );

        accionesDisponibles.shuffle(
          random,
        );
      }

      accionController.clear();
    });

    await guardarAcciones();
  }

  Future<int> importarAccionesDesdeTexto(
      String texto,
      ) async {
    final lineas = texto
        .split(RegExp(r'\r?\n'))
        .map(limpiarPrefijoImportado)
        .where(
          (linea) =>
      linea.trim().isNotEmpty,
    )
        .toList();

    if (lineas.isEmpty) {
      return 0;
    }

    final existentes = acciones
        .map(
          (accion) =>
          accion.toLowerCase().trim(),
    )
        .toSet();

    final nuevas = <String>[];

    for (final linea in lineas) {
      final accion =
      normalizarAccion(linea);

      if (accion.isEmpty) continue;

      final clave =
      accion.toLowerCase().trim();

      if (!existentes.contains(clave)) {
        existentes.add(clave);
        nuevas.add(accion);
      }
    }

    if (nuevas.isEmpty) {
      return 0;
    }

    setState(() {
      acciones.addAll(nuevas);

      accionesDisponibles.addAll(
        nuevas.where(
              (accion) =>
          accion != accionActual,
        ),
      );

      accionesDisponibles.shuffle(
        random,
      );
    });

    await guardarAcciones();

    return nuevas.length;
  }

  Future<void> eliminarAccion(
      int index,
      ) async {
    if (index < 0 ||
        index >= acciones.length) {
      return;
    }

    final eliminada =
    acciones[index];

    setState(() {
      acciones.removeAt(index);

      accionesDisponibles.removeWhere(
            (accion) =>
        accion == eliminada,
      );

      accionesUsadas.removeWhere(
            (accion) =>
        accion == eliminada,
      );

      if (accionActual == eliminada) {
        accionActual = '';
      }
    });

    await guardarAcciones();
  }

  void siguienteAccion() {
    if (acciones.isEmpty) {
      mostrarMensaje(
        'Añade acciones con el botón de editar.',
      );
      return;
    }

    if (accionesDisponibles.isEmpty) {
      accionesDisponibles =
      List<String>.from(acciones)
        ..shuffle(random);

      accionesUsadas.clear();

      if (accionesDisponibles.length > 1 &&
          accionActual.isNotEmpty) {
        accionesDisponibles.remove(
          accionActual,
        );
      }
    }

    if (accionesDisponibles.isEmpty) {
      setState(() {
        accionActual = acciones.first;
        accionesUsadas = [
          acciones.first,
        ];
      });

      return;
    }

    final siguiente =
    accionesDisponibles.removeLast();

    setState(() {
      accionActual = siguiente;
      accionesUsadas.add(siguiente);
    });
  }

  void abrirEditor() {
    setState(() {
      configurando = true;
    });
  }

  void volverAlJuego() {
    if (acciones.isEmpty) {
      setState(() {
        accionActual = '';
        accionesDisponibles = [];
        accionesUsadas = [];
        configurando = false;
      });

      return;
    }

    final actualSigueExistiendo =
        accionActual.isNotEmpty &&
            acciones.contains(
              accionActual,
            );

    if (!actualSigueExistiendo) {
      final baraja =
      List<String>.from(acciones)
        ..shuffle(random);

      final primera =
      baraja.removeLast();

      setState(() {
        accionActual = primera;
        accionesDisponibles = baraja;
        accionesUsadas = [primera];
        configurando = false;
      });

      return;
    }

    setState(() {
      configurando = false;
    });
  }

  int get totalAcciones =>
      acciones.length;

  double get progresoRestante {
    if (totalAcciones == 0) {
      return 0;
    }

    return (
        accionesDisponibles.length /
            totalAcciones
    ).clamp(0.0, 1.0);
  }

  ButtonStyle mainButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: appWhite,
      foregroundColor: appBlue,
      elevation: 0,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.zero,
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
            color:
            appWhite.withOpacity(
              0.85,
            ),
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
        MediaQuery.of(context)
            .size
            .height <
            740;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () =>
                  Navigator.pop(
                    context,
                  ),
            ),
            circleButton(
              onTap: mostrarNormas,
              child: const Icon(
                Icons
                    .question_mark_rounded,
                color: appWhite,
                size: 27,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Padding(
          padding:
          const EdgeInsets.only(
            left: 28,
          ),
          child: SizedBox(
            height: 94,
            child: Stack(
              clipBehavior:
              Clip.none,
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FittedBox(
                    fit:
                    BoxFit.scaleDown,
                    alignment:
                    Alignment
                        .centerLeft,
                    child: Text(
                      '1 y 2',
                      maxLines: 1,
                      style:
                      TextStyle(
                        color:
                        appWhite,
                        fontSize: 48,
                        height: 1.90,
                        fontWeight:
                        FontWeight
                            .w900,
                        letterSpacing:
                        -1,
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
                    color: appWhite
                        .withOpacity(
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
      const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color:
        appWhite.withOpacity(
          0.08,
        ),
        border: Border.all(
          color:
          appWhite.withOpacity(
            0.26,
          ),
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
              CrossAxisAlignment
                  .start,
              children: [
                SizedBox(
                  width:
                  double.infinity,
                  child:
                  _singleLineResponsiveText(
                    tr(title).toUpperCase(),
                    style:
                    const TextStyle(
                      color:
                      appWhite,
                      fontSize:
                      13.5,
                      fontWeight:
                      FontWeight
                          .w900,
                      letterSpacing:
                      0.3,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  text,
                  style:
                  TextStyle(
                    color: appWhite
                        .withOpacity(
                      0.72,
                    ),
                    fontSize:
                    12.5,
                    height: 1.25,
                    fontWeight:
                    FontWeight
                        .w600,
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
      Colors.black.withOpacity(
        0.45,
      ),
      builder: (_) => Dialog(
        backgroundColor:
        Colors.transparent,
        insetPadding:
        const EdgeInsets
            .symmetric(
          horizontal: 22,
        ),
        child: Container(
          padding:
          const EdgeInsets
              .fromLTRB(
            20,
            20,
            20,
            18,
          ),
          decoration: BoxDecoration(
            color: appBlue,
            border: Border.all(
              color: appWhite
                  .withOpacity(
                0.75,
              ),
              width: 2.2,
            ),
          ),
          child:
          ConstrainedBox(
            constraints:
            BoxConstraints(
              maxHeight:
              MediaQuery.of(
                context,
              ).size.height *
                  0.78,
            ),
            child:
            SingleChildScrollView(
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
                          BoxShape
                              .circle,
                          border:
                          Border.all(
                            color: appWhite
                                .withOpacity(
                              0.85,
                            ),
                            width: 2.1,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons
                              .question_mark_rounded,
                          color:
                          appWhite,
                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Expanded(
                        child: Text(
                          'normas',
                          style:
                          TextStyle(
                            color:
                            appWhite,
                            fontSize:
                            38,
                            height:
                            0.9,
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
                    color: appWhite
                        .withOpacity(
                      0.58,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  const Text(
                    '1 Y 2',
                    style: TextStyle(
                      color: appWhite,
                      fontSize: 15,
                      fontWeight:
                      FontWeight
                          .w900,
                      letterSpacing:
                      1.2,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  rulesItem(
                    icon:
                    Icons.edit_rounded,
                    title:
                    'Tus acciones',
                    text:
                    'Crea tus propias acciones desde el botón del lápiz.',
                  ),

                  rulesItem(
                    icon: Icons
                        .content_paste_rounded,
                    title:
                    'Importar lista',
                    text:
                    'Puedes pegar una lista completa con cientos de acciones y añadirlas todas de golpe.',
                  ),

                  rulesItem(
                    icon: Icons
                        .looks_one_rounded,
                    title:
                    'Jugador 1',
                    text:
                    'La acción empieza con una persona como jugador 1.',
                  ),

                  rulesItem(
                    icon: Icons
                        .looks_two_rounded,
                    title:
                    'Jugador 2',
                    text:
                    'Después se elige o se menciona otra persona como jugador 2.',
                  ),

                  rulesItem(
                    icon: Icons
                        .record_voice_over_rounded,
                    title:
                    'Lee la acción',
                    text:
                    'Lee la acción en voz alta y haced lo que indique.',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  SizedBox(
                    width:
                    double.infinity,
                    child:
                    ElevatedButton(
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
                            fontSize:
                            16,
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
      tr('Ej: Jugador 1 elige un reto para Jugador 2'),
      hintStyle: TextStyle(
        color:
        appWhite.withOpacity(
          0.42,
        ),
        fontSize: 13,
      ),
      filled: true,
      fillColor:
      appWhite.withOpacity(
        0.07,
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.zero,
        borderSide: BorderSide(
          color:
          appWhite.withOpacity(
            0.28,
          ),
          width: 1.4,
        ),
      ),
      focusedBorder:
      const OutlineInputBorder(
        borderRadius:
        BorderRadius.zero,
        borderSide: BorderSide(
          color:
          accentTurquoise,
          width: 2,
        ),
      ),
    );
  }

  Widget buildAccionTile({
    required String accion,
    required int index,
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),
      padding:
      EdgeInsets.fromLTRB(
        compact ? 9 : 11,
        compact ? 7 : 8,
        4,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color:
        appWhite.withOpacity(
          0.07,
        ),
        border: Border(
          left: const BorderSide(
            color:
            accentTurquoise,
            width: 6,
          ),
          bottom: BorderSide(
            color: appWhite
                .withOpacity(
              0.25,
            ),
            width: 2,
          ),
          top: BorderSide(
            color: appWhite
                .withOpacity(
              0.15,
            ),
          ),
          right: BorderSide(
            color: appWhite
                .withOpacity(
              0.15,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width:
            compact ? 31 : 35,
            height:
            compact ? 31 : 35,
            alignment:
            Alignment.center,
            decoration:
            BoxDecoration(
              shape:
              BoxShape.circle,
              border: Border.all(
                color: appWhite
                    .withOpacity(
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
                compact
                    ? 12
                    : 13,
                fontWeight:
                FontWeight
                    .w900,
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              accion,
              maxLines: 2,
              overflow:
              TextOverflow
                  .ellipsis,
              style: TextStyle(
                color: appWhite,
                fontSize:
                compact
                    ? 12.5
                    : 14,
                height: 1.2,
                fontWeight:
                FontWeight
                    .w700,
              ),
            ),
          ),

          IconButton(
            tooltip:
            tr('Eliminar acción'),
            constraints:
            const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
            ),
            padding:
            EdgeInsets.zero,
            onPressed: () =>
                eliminarAccion(index),
            icon: Icon(
              Icons
                  .delete_outline_rounded,
              color: appWhite
                  .withOpacity(
                0.78,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void>
  mostrarImportarAcciones() async {
    final controller =
    TextEditingController();

    final size =
    MediaQuery.sizeOf(context);

    final resultado =
    await showDialog<int>(
      context: context,
      barrierDismissible: false,
      barrierColor:
      Colors.black.withOpacity(
        0.55,
      ),
      builder:
          (dialogContext) {
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
            width:
            double.infinity,
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
            decoration:
            BoxDecoration(
              color: appBlue,
              border: Border.all(
                color: appWhite
                    .withOpacity(
                  0.75,
                ),
                width: 2.2,
              ),
            ),
            child:
            SingleChildScrollView(
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
                          BoxShape
                              .circle,
                          color:
                          accentTurquoise
                              .withOpacity(
                            0.14,
                          ),
                          border:
                          Border.all(
                            color:
                            accentTurquoise,
                            width: 2,
                          ),
                        ),
                        child:
                        const Icon(
                          Icons
                              .content_paste_rounded,
                          color:
                          accentTurquoise,
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
                            fontSize:
                            22,
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
                      0.58,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Text(
                    'Pega todas las acciones aquí. Pon una acción en cada línea.',
                    style:
                    TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.75,
                      ),
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'También puedes pegar listas numeradas: 1. ..., 2. ..., 3. ...',
                    style:
                    TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.50,
                      ),
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  SizedBox(
                    height: min(
                      360.0,
                      size.height * 0.42,
                    ),
                    child:
                    TextField(
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
                        color:
                        appWhite,
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
                        tr('Jugador 1...\nJugador 2...\nLos dos jugadores...'),
                        hintStyle:
                        TextStyle(
                          color: appWhite
                              .withOpacity(
                            0.30,
                          ),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        filled: true,
                        fillColor:
                        appWhite
                            .withOpacity(
                          0.07,
                        ),
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
                              0.25,
                            ),
                            width: 1.4,
                          ),
                        ),
                        focusedBorder:
                        const OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .zero,
                          borderSide:
                          BorderSide(
                            color:
                            accentTurquoise,
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
                    height: 54,
                    child:
                    ElevatedButton(
                      onPressed:
                          () async {
                        final cantidad =
                        await importarAccionesDesdeTexto(
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
                              'IMPORTAR ACCIONES',
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
        'No se ha añadido ninguna acción nueva.',
      );
    } else {
      mostrarMensaje(
        '$resultado ${resultado == 1 ? 'acción importada' : 'acciones importadas'}.',
      );
    }
  }

  Widget buildConfiguracion() {
    final compact =
        _isCompactScreen;

    final veryNarrow =
        _isVeryNarrowScreen;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width:
              compact ? 40 : 46,
              height:
              compact ? 40 : 46,
              decoration:
              BoxDecoration(
                color:
                accentTurquoise
                    .withOpacity(
                  0.14,
                ),
                shape:
                BoxShape.circle,
                border: Border.all(
                  color:
                  accentTurquoise
                      .withOpacity(
                    0.70,
                  ),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons
                    .compare_arrows_rounded,
                color:
                accentTurquoise,
                size:
                compact ? 22 : 25,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
              _singleLineResponsiveText(
                'TUS ACCIONES',
                style:
                TextStyle(
                  color: appWhite,
                  fontSize:
                  compact
                      ? 16
                      : 19,
                  fontWeight:
                  FontWeight
                      .w900,
                  letterSpacing:
                  0.4,
                ),
              ),
            ),

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
              BoxDecoration(
                color: appWhite
                    .withOpacity(
                  0.09,
                ),
                border: Border.all(
                  color: appWhite
                      .withOpacity(
                    0.22,
                  ),
                ),
              ),
              child: Text(
                '${acciones.length}',
                maxLines: 1,
                style:
                TextStyle(
                  color: appWhite,
                  fontSize:
                  compact
                      ? 12
                      : 14,
                  fontWeight:
                  FontWeight
                      .w900,
                ),
              ),
            ),
          ],
        ),

        SizedBox(
          height:
          compact ? 12 : 16,
        ),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller:
                accionController,
                textInputAction:
                TextInputAction
                    .done,
                onSubmitted:
                    (_) =>
                    agregarAccion(),
                maxLines: 1,
                style:
                const TextStyle(
                  color: appWhite,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
                cursorColor:
                appWhite,
                decoration:
                inputDecoration(),
              ),
            ),

            SizedBox(
              width:
              veryNarrow
                  ? 6
                  : 9,
            ),

            SizedBox(
              width:
              veryNarrow
                  ? 46
                  : compact
                  ? 50
                  : 54,
              height:
              veryNarrow
                  ? 48
                  : compact
                  ? 50
                  : 54,
              child:
              ElevatedButton(
                onPressed:
                agregarAccion,
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  accentTurquoise,
                  foregroundColor:
                  appWhite,
                  elevation: 0,
                  padding:
                  EdgeInsets.zero,
                  minimumSize:
                  Size.zero,
                  tapTargetSize:
                  MaterialTapTargetSize
                      .shrinkWrap,
                  shape:
                  const RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .zero,
                  ),
                ),
                child:
                const Icon(
                  Icons.add_rounded,
                  size: 28,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        SizedBox(
          width: double.infinity,
          height:
          compact ? 42 : 46,
          child:
          OutlinedButton(
            onPressed:
            mostrarImportarAcciones,
            style:
            OutlinedButton
                .styleFrom(
              foregroundColor:
              appWhite,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
              ),
              side: BorderSide(
                color: appWhite
                    .withOpacity(
                  0.45,
                ),
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
              MainAxisAlignment
                  .center,
              children: [
                Icon(
                  Icons
                      .content_paste_rounded,
                  size:
                  compact
                      ? 18
                      : 20,
                ),

                const SizedBox(
                  width: 7,
                ),

                Expanded(
                  child:
                  _singleLineResponsiveText(
                    'IMPORTAR LISTA',
                    alignment:
                    Alignment
                        .center,
                    style:
                    TextStyle(
                      color:
                      appWhite,
                      fontSize:
                      compact
                          ? 11.5
                          : 13,
                      fontWeight:
                      FontWeight
                          .w900,
                      letterSpacing:
                      0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(
          height:
          compact ? 12 : 16,
        ),

        Row(
          children: [
            Expanded(
              child:
              _singleLineResponsiveText(
                'LISTA DE ACCIONES',
                style:
                TextStyle(
                  color: appWhite
                      .withOpacity(
                    0.70,
                  ),
                  fontSize:
                  compact
                      ? 10.5
                      : 12,
                  fontWeight:
                  FontWeight
                      .w900,
                  letterSpacing:
                  0.7,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${acciones.length}',
              maxLines: 1,
              style:
              TextStyle(
                color: appWhite
                    .withOpacity(
                  0.62,
                ),
                fontSize:
                compact
                    ? 11
                    : 12,
                fontWeight:
                FontWeight
                    .w900,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 9,
        ),

        Expanded(
          child: acciones.isEmpty
              ? Center(
            child: Padding(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 20,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize
                    .min,
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
                    'Todavía no has añadido ninguna acción',
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.68,
                      ),
                      fontSize:
                      14,
                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Añade una acción o importa una lista completa',
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      color: appWhite
                          .withOpacity(
                        0.44,
                      ),
                      fontSize:
                      12,
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
              compact
                  ? 8
                  : 12,
            ),
            itemCount:
            acciones.length,
            itemBuilder:
                (
                context,
                index,
                ) {
              return buildAccionTile(
                accion:
                acciones[
                index],
                index:
                index,
                compact:
                compact,
              );
            },
          ),
        ),

        SizedBox(
          height:
          compact ? 8 : 12,
        ),

        SizedBox(
          width: double.infinity,
          height:
          compact ? 56 : 62,
          child:
          ElevatedButton(
            onPressed:
            volverAlJuego,
            style:
            mainButtonStyle(),
            child: Padding(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Icon(
                    Icons
                        .arrow_back_rounded,
                    size:
                    compact
                        ? 21
                        : 24,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                    _singleLineResponsiveText(
                      'VOLVER AL JUEGO',
                      alignment:
                      Alignment
                          .center,
                      style:
                      TextStyle(
                        fontSize:
                        compact
                            ? 13
                            : 15,
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
        ),
      ],
    );
  }

  Widget buildActionCard() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets
              .symmetric(
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
                  color: appWhite
                      .withOpacity(
                    0.16,
                  ),
                  border: Border.all(
                    color: appWhite,
                    width: 3,
                  ),
                ),
                child:
                const Icon(
                  Icons
                      .visibility_rounded,
                  color: appWhite,
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
                    (
                    child,
                    animation,
                    ) {
                  final slide =
                  Tween<Offset>(
                    begin:
                    const Offset(
                      0,
                      0.08,
                    ),
                    end:
                    Offset.zero,
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
                  accionActual.isEmpty
                      ? 'Añade tus acciones para empezar'
                      : accionActual,
                  key: ValueKey(
                    accionActual.isEmpty
                        ? 'sin_acciones'
                        : accionActual,
                  ),
                  textAlign:
                  TextAlign.center,
                  style:
                  const TextStyle(
                    color:
                    appWhite,
                    fontSize: 32,
                    height: 1.14,
                    fontWeight:
                    FontWeight
                        .w900,
                    letterSpacing:
                    -0.7,
                  ),
                ),
              ),

              if (accionActual
                  .isEmpty) ...[
                const SizedBox(
                  height: 12,
                ),

                Text(
                  'Pulsa el lápiz para crear o importar tu lista',
                  textAlign:
                  TextAlign.center,
                  style:
                  TextStyle(
                    color: appWhite
                        .withOpacity(
                      0.52,
                    ),
                    fontSize: 13,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ],
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
                'ACCIONES RESTANTES',
                style:
                TextStyle(
                  color: appWhite
                      .withOpacity(
                    0.76,
                  ),
                  fontSize: 12,
                  fontWeight:
                  FontWeight
                      .w900,
                  letterSpacing:
                  0.7,
                ),
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${accionesDisponibles.length} / $totalAcciones',
              maxLines: 1,
              softWrap: false,
              style:
              const TextStyle(
                color:
                appWhite,
                fontSize: 14,
                fontWeight:
                FontWeight
                    .w900,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 9,
        ),

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
              (
              context,
              value,
              _,
              ) {
            return Container(
              height: 14,
              decoration:
              BoxDecoration(
                color: appWhite
                    .withOpacity(
                  0.15,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  7,
                ),
                border:
                Border.all(
                  color: appWhite
                      .withOpacity(
                    0.34,
                  ),
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
                Colors
                    .transparent,
                valueColor:
                const AlwaysStoppedAnimation<
                    Color>(
                  appWhite,
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
          color:
          backgroundColor,
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
                    .circular(
                  16,
                ),
                border:
                Border.all(
                  color: appWhite
                      .withOpacity(
                    0.28,
                  ),
                  width: 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    backgroundColor
                        .withOpacity(
                      0.28,
                    ),
                    blurRadius:
                    16,
                    offset:
                    const Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),
              child:
              Center(
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
          buildActionCard(),
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
              abrirEditor,
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
              siguienteAccion,
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
        backgroundColor:
        appBlue,
        body: Center(
          child:
          CircularProgressIndicator(
            color: appWhite,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      appBlue,
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (
              context,
              constraints,
              ) {
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
                      child:
                      configurando
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