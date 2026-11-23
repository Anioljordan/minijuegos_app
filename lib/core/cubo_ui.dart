import 'package:flutter/material.dart';

/// Tokens de diseño de Cubo: colores, radios, sombras, tipografía y estilos
/// comunes. Todas las pantallas deben tirar de aquí en vez de definir sus
/// propios valores sueltos.
class CuboColors {
  CuboColors._();

  static const Color blue = Color(0xFF2F4F9C);
  static const Color blueLight = Color(0xFF3E63BE);
  static const Color blueDeep = Color(0xFF223D80);

  /// Texto azul sobre fondo blanco.
  static const Color blueInk = Color(0xFF1F3672);

  /// Fondos suaves sobre blanco (cuadrados de icono, chips claros).
  static const Color blueTint = Color(0xFFE3E9F7);
  static const Color white = Color(0xFFF7F7F7);

  /// Blanco puro para el brillo superior de las tarjetas.
  static const Color paper = Color(0xFFFFFFFF);

  /// Acento de los juegos de Fiesta.
  static const Color fiesta = Color(0xFFFFCC3D);

  /// Acento de los juegos de Chill.
  static const Color chill = Color(0xFF8FD3FF);

  static Color whiteA(double alpha) => white.withValues(alpha: alpha);
}

class CuboRadii {
  CuboRadii._();

  /// Chips, cuadrados de icono.
  static const double sm = 12;

  /// Campos de texto.
  static const double input = 14;

  /// Botones y diálogos.
  static const double md = 18;

  /// Tarjetas.
  static const double lg = 24;

  /// Tarjeta central de juego y parte superior de los sheets.
  static const double xl = 28;

  /// Carta protagonista de las partidas (frase, pregunta, palabra...).
  static const double card = 32;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius inputAll = BorderRadius.all(Radius.circular(input));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

class CuboShadows {
  CuboShadows._();

  /// Única sombra de la app: tarjetas blancas sobre azul.
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x2B000000), // negro al 17 %
      blurRadius: 22,
      offset: Offset(0, 9),
    ),
  ];

  /// Carta protagonista: sombra corta de contacto + sombra larga azulada.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x2E0F1E46),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x660F1E5A),
      blurRadius: 48,
      offset: Offset(0, 24),
    ),
  ];

  /// Elementos que flotan sobre el azul (tarjetas de modo, botón principal).
  static const List<BoxShadow> float = [
    BoxShadow(
      color: Color(0x260A143C),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x520C1A46),
      blurRadius: 30,
      offset: Offset(0, 16),
    ),
  ];

  /// Cartas fantasma del mazo, detrás de la protagonista.
  static const List<BoxShadow> ghost = [
    BoxShadow(
      color: Color(0x400C1A46),
      blurRadius: 30,
      offset: Offset(0, 16),
    ),
  ];
}

class CuboText {
  CuboText._();

  /// Tipografía de las pantallas de juego (assets/fonts/inter).
  static const String fontFamily = 'Inter';

  /// Frase o pregunta dentro de la carta protagonista.
  static TextStyle cardPhrase({double size = 31}) {
    return TextStyle(
      fontFamily: fontFamily,
      color: CuboColors.blueInk,
      fontSize: size,
      height: 1.14,
      fontWeight: FontWeight.w800,
      letterSpacing: -size * 0.026,
    );
  }

  /// Título grande en minúscula (fiesta, chill, normas...).
  static TextStyle title({double size = 66, Color color = CuboColors.white}) {
    return TextStyle(
      color: color,
      fontSize: size,
      height: 0.95,
      fontWeight: FontWeight.w900,
      letterSpacing: -size * 0.025,
      // Sin ligaduras: Roboto une la "fi" de "fiesta".
      fontFeatures: const [FontFeature.disable('liga')],
    );
  }

  /// Texto de tarjetas y botones, en tipo frase.
  static TextStyle label({
    double size = 18,
    Color color = CuboColors.blueInk,
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.1,
    );
  }

  /// Etiqueta pequeña tipo chip (esta sí en mayúsculas).
  static TextStyle chip({Color color = CuboColors.white, double size = 11.5}) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.8,
    );
  }
}

class CuboDecorations {
  CuboDecorations._();

  /// Tarjeta de cristal con más profundidad: degradado blanco translúcido
  /// en diagonal, borde fino y sombra flotante.
  static BoxDecoration glassRaised({double radius = CuboRadii.xl}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [CuboColors.whiteA(0.20), CuboColors.whiteA(0.07)],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: CuboColors.whiteA(0.28)),
      boxShadow: CuboShadows.float,
    );
  }

  /// Carta protagonista de las partidas.
  static const BoxDecoration playCard = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [CuboColors.paper, CuboColors.white],
    ),
    borderRadius: CuboRadii.cardAll,
    boxShadow: CuboShadows.card,
  );

  /// Tarjeta translúcida dentro de los juegos. Con [selected] se marca la
  /// selección con fondo más claro y borde más opaco (sin barra lateral).
  static BoxDecoration glass({
    bool selected = false,
    double radius = CuboRadii.lg,
    Color? accent,
  }) {
    final borderColor = selected
        ? (accent ?? CuboColors.white).withValues(alpha: 0.85)
        : CuboColors.whiteA(0.22);
    return BoxDecoration(
      color: CuboColors.whiteA(selected ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: selected ? 1.8 : 1.2),
    );
  }

  /// Tarjeta blanca con la sombra suave.
  static BoxDecoration whiteCard({double radius = CuboRadii.lg}) {
    return BoxDecoration(
      color: CuboColors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: CuboShadows.soft,
    );
  }

  /// Panel de diálogo azul con borde blanco translúcido.
  static BoxDecoration dialog() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [CuboColors.blueLight, CuboColors.blue],
      ),
      borderRadius: CuboRadii.xlAll,
      border: Border.all(color: CuboColors.whiteA(0.30), width: 1.2),
      boxShadow: CuboShadows.soft,
    );
  }
}

class CuboButtons {
  CuboButtons._();

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 22,
    vertical: 14,
  );

  /// Principal: píldora blanca con texto azul.
  static ButtonStyle primary({
    Color foreground = CuboColors.blue,
    EdgeInsetsGeometry? padding = _padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: CuboColors.white,
      foregroundColor: foreground,
      disabledBackgroundColor: CuboColors.whiteA(0.35),
      disabledForegroundColor: CuboColors.blue.withValues(alpha: 0.55),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: padding,
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontFamily: CuboText.fontFamily,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Secundario: píldora contorneada blanca translúcida.
  static ButtonStyle secondary({EdgeInsetsGeometry? padding = _padding}) {
    return OutlinedButton.styleFrom(
      foregroundColor: CuboColors.white,
      backgroundColor: CuboColors.whiteA(0.08),
      disabledForegroundColor: CuboColors.whiteA(0.45),
      padding: padding,
      side: BorderSide(color: CuboColors.whiteA(0.55), width: 1.4),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontFamily: CuboText.fontFamily,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  /// Igual que [secondary] pero para usar con [ElevatedButton].
  static ButtonStyle secondaryElevated({
    EdgeInsetsGeometry? padding = _padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: CuboColors.whiteA(0.10),
      foregroundColor: CuboColors.white,
      disabledBackgroundColor: CuboColors.whiteA(0.05),
      disabledForegroundColor: CuboColors.whiteA(0.45),
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: padding,
      side: BorderSide(color: CuboColors.whiteA(0.55), width: 1.4),
      shape: const StadiumBorder(),
      textStyle: const TextStyle(
        fontFamily: CuboText.fontFamily,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class CuboInputs {
  CuboInputs._();

  static OutlineInputBorder _border(double alpha, [double width = 1.2]) {
    return OutlineInputBorder(
      borderRadius: CuboRadii.inputAll,
      borderSide: BorderSide(color: CuboColors.whiteA(alpha), width: width),
    );
  }

  /// Campo de texto sobre fondo azul.
  static InputDecoration decoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
    bool isDense = false,
    String? counterText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: CuboColors.whiteA(0.55),
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      counterText: counterText,
      filled: true,
      fillColor: CuboColors.whiteA(0.07),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: _border(0.28),
      enabledBorder: _border(0.28),
      focusedBorder: _border(0.75, 1.6),
      disabledBorder: _border(0.15),
    );
  }

  /// Borde redondeado conservando el color que ya define una pantalla.
  static OutlineInputBorder rounded(BorderSide side) {
    return OutlineInputBorder(borderRadius: CuboRadii.inputAll, borderSide: side);
  }
}

/// Tema global: lo que no tenga estilo propio ya sale redondeado.
ThemeData buildCuboTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CuboColors.blue,
      primary: CuboColors.blue,
      surface: CuboColors.white,
    ),
    scaffoldBackgroundColor: CuboColors.blue,
  );

  return base.copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: CuboButtons.primary(padding: null),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: CuboButtons.secondary(padding: null),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CuboColors.white,
        shape: const StadiumBorder(),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: CuboRadii.xlAll),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(borderRadius: CuboRadii.sheetTop),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: CuboColors.blueInk,
      contentTextStyle: const TextStyle(
        color: CuboColors.white,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: CuboRadii.mdAll,
        side: BorderSide(color: CuboColors.whiteA(0.22)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: CuboInputs.rounded(BorderSide(color: CuboColors.whiteA(0.28))),
    ),
  );
}
