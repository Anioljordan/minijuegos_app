import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Text;
import '../widgets/i18n_text.dart';
import 'fiesta_screen.dart';
import 'chill_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_settings_button.dart';
import '../core/app_settings.dart';
import '../widgets/app_logo_button.dart';
import '../widgets/mood_physics.dart';
import '../core/cubo_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool showSplash = true;

  /// Palabras y líneas de la pantalla de inicio con las que chocan los cubos.
  final MoodPhysics _moodPhysics = MoodPhysics();
  late final AnimationController _splashController;

  String selectedLanguage = 'es';
  double volume = 0.8;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  static const Color blue = Color(0xFF2F4F9C);
  static const Color white = Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();

    AppSettings.instance.load();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;

      setState(() {
        showSplash = false;
      });
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    _moodPhysics.dispose();
    super.dispose();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      selectedLanguage = prefs.getString('app_language') ?? 'es';
      volume = (prefs.getDouble('app_volume') ?? 0.8).clamp(0.0, 1.0);
      soundEnabled = prefs.getBool('app_sound_enabled') ?? true;
      vibrationEnabled = prefs.getBool('app_vibration_enabled') ?? true;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_language', selectedLanguage);
    await prefs.setDouble('app_volume', volume);
    await prefs.setBool('app_sound_enabled', soundEnabled);
    await prefs.setBool('app_vibration_enabled', vibrationEnabled);
  }

  String t(String key) {
    final translations = {
      'es': {
        'chooseYour': 'choose your',
        'mood': 'mood',
        'party': 'party',
        'chill': 'chill',
        'settings': 'Ajustes',
        'language': 'Idioma',
        'volume': 'Volumen',
        'sound': 'Sonidos',
        'vibration': 'Vibración',
        'resetData': 'Reiniciar datos guardados',
        'about': 'Acerca de la app',
        'close': 'Cerrar',
        'spanish': 'Español',
        'catalan': 'Català',
        'english': 'English',
      },
      'ca': {
        'chooseYour': 'tria el teu',
        'mood': 'mood',
        'party': 'festa',
        'chill': 'chill',
        'settings': 'Configuració',
        'language': 'Idioma',
        'volume': 'Volum',
        'sound': 'Sons',
        'vibration': 'Vibració',
        'resetData': 'Reiniciar dades guardades',
        'about': 'Sobre l’app',
        'close': 'Tancar',
        'spanish': 'Español',
        'catalan': 'Català',
        'english': 'English',
      },
      'en': {
        'chooseYour': 'choose your',
        'mood': 'mood',
        'party': 'party',
        'chill': 'chill',
        'settings': 'Settings',
        'language': 'Language',
        'volume': 'Volume',
        'sound': 'Sound',
        'vibration': 'Vibration',
        'resetData': 'Reset saved data',
        'about': 'About the app',
        'close': 'Close',
        'spanish': 'Español',
        'catalan': 'Català',
        'english': 'English',
      },
    };

    return translations[selectedLanguage]?[key] ?? translations['es']![key]!;
  }

  Widget buildTopIcons() {
    final compact = MediaQuery.of(context).size.height < 740;
    final size = compact ? 44.0 : 50.0;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 13 : 18,
          compact ? 11 : 18,
          compact ? 13 : 18,
          0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppLogoButton(
              compact: compact,
              onTap: () {},
            ),

            GestureDetector(
              onTap: showSettingsSheet,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: white.withOpacity(0.85),
                    width: 2.2,
                  ),
                ),
                child: const AppSettingsButton(
                  blue: blue,
                  white: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: white.withOpacity(0.45),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.settings_rounded,
                          color: white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t('settings'),
                            style: const TextStyle(
                              color: white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Text(
                      t('language'),
                      style: TextStyle(
                        color: white.withOpacity(0.72),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        buildLanguageButton(
                          label: t('spanish'),
                          value: 'es',
                          setModalState: setModalState,
                        ),
                        const SizedBox(width: 8),
                        buildLanguageButton(
                          label: t('catalan'),
                          value: 'ca',
                          setModalState: setModalState,
                        ),
                        const SizedBox(width: 8),
                        buildLanguageButton(
                          label: t('english'),
                          value: 'en',
                          setModalState: setModalState,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    buildSettingsSwitch(
                      icon: Icons.volume_up_rounded,
                      title: t('sound'),
                      value: soundEnabled,
                      onChanged: (value) async {
                        setModalState(() {
                          soundEnabled = value;
                        });
                        setState(() {});
                        await saveSettings();
                      },
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        const Icon(
                          Icons.graphic_eq_rounded,
                          color: white,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t('volume'),
                            style: const TextStyle(
                              color: white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${(volume * 100).round()}%',
                          style: TextStyle(
                            color: white.withOpacity(0.75),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      activeColor: white,
                      inactiveColor: white.withOpacity(0.25),
                      onChanged: soundEnabled == true
                          ? (value) async {
                        setModalState(() {
                          volume = value;
                        });
                        setState(() {});
                        await saveSettings();
                      }
                          : null,
                    ),

                    const SizedBox(height: 10),

                    buildSettingsSwitch(
                      icon: Icons.vibration_rounded,
                      title: t('vibration'),
                      value: vibrationEnabled,
                      onChanged: (value) async {
                        setModalState(() {
                          vibrationEnabled = value;
                        });
                        setState(() {});
                        await saveSettings();
                      },
                    ),

                    const SizedBox(height: 18),

                    buildSettingsAction(
                      icon: Icons.delete_outline_rounded,
                      title: t('resetData'),
                      onTap: () async {
                        await resetSavedData();
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: 10),

                    buildSettingsAction(
                      icon: Icons.info_outline_rounded,
                      title: t('about'),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'MiniGames',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 MiniGames',
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildLanguageButton({
    required String label,
    required String value,
    required StateSetter setModalState,
  }) {
    final bool selected = selectedLanguage == value;

    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setModalState(() {
            selectedLanguage = value;
          });
          setState(() {});
          await saveSettings();
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: selected ? white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: white.withOpacity(0.65),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? blue : white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSettingsSwitch({
    required IconData icon,
    required String title,
    required bool? value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: white,
          size: 26,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Switch(
          value: value ?? true,
          activeColor: white,
          activeTrackColor: white.withOpacity(0.35),
          inactiveThumbColor: white.withOpacity(0.75),
          inactiveTrackColor: white.withOpacity(0.18),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget buildSettingsAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: white.withOpacity(0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: white.withOpacity(0.65),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('yo_nunca_chill_restantes');
    await prefs.remove('yo_nunca_chill_actual');
    await prefs.remove('yo_nunca_erotico_restantes');
    await prefs.remove('yo_nunca_erotico_actual');
    await prefs.remove('yo_nunca_mix_restantes');
    await prefs.remove('yo_nunca_mix_actual');

    await prefs.remove('asamblea_last_players');
    await prefs.remove('asamblea_partida_guardada');

    await prefs.remove('escalas_guardadas');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Datos guardados reiniciados'),
      ),
    );
  }
  Widget buildSplash() {
    return Scaffold(
      key: const ValueKey('splash'),
      backgroundColor: blue,
      body: SizedBox.expand(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final shortestSide = width < height ? width : height;

              final compact = height < 680;
              final logoSize = (shortestSide * 0.40)
                  .clamp(compact ? 132.0 : 150.0, 240.0)
                  .toDouble();
              final titleSize =
              (width * 0.145).clamp(48.0, 88.0).toDouble();
              final contentWidth =
              (width * 0.82).clamp(280.0, 620.0).toDouble();
              final progressWidth =
              (width * 0.62).clamp(230.0, 430.0).toDouble();
              final decorationSize =
              (shortestSide * 0.72).clamp(260.0, 560.0).toDouble();

              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: -decorationSize * 0.42,
                    right: -decorationSize * 0.34,
                    child: Container(
                      width: decorationSize,
                      height: decorationSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: white.withOpacity(0.08),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -decorationSize * 0.48,
                    left: -decorationSize * 0.36,
                    child: Container(
                      width: decorationSize * 1.12,
                      height: decorationSize * 1.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: white.withOpacity(0.035),
                        border: Border.all(
                          color: white.withOpacity(0.07),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: contentWidth,
                      height: height,
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.76, end: 1.0),
                            duration: const Duration(milliseconds: 950),
                            curve: Curves.easeOutBack,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value.clamp(0.0, 1.0).toDouble(),
                                child: Transform.scale(
                                  scale: value,
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: logoSize,
                                  height: logoSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox.expand(
                                        child: CircularProgressIndicator(
                                          strokeWidth: logoSize * 0.027,
                                          color: white.withOpacity(0.96),
                                          backgroundColor:
                                          white.withOpacity(0.11),
                                        ),
                                      ),
                                      Container(
                                        width: logoSize * 0.84,
                                        height: logoSize * 0.84,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: blue,
                                          border: Border.all(
                                            color: white.withOpacity(0.78),
                                            width: logoSize * 0.018,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.black.withOpacity(0.20),
                                              blurRadius: logoSize * 0.20,
                                              offset: Offset(
                                                0,
                                                logoSize * 0.08,
                                              ),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(logoSize * 0.16),
                                          child: SvgPicture.asset(
                                            'assets/images/CUBO0white.svg',
                                            fit: BoxFit.contain,
                                            colorFilter: const ColorFilter.mode(
                                              white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: height * 0.035),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'CUBO',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: titleSize,
                                      height: 0.9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing:
                                      (titleSize * 0.12).clamp(5.0, 10.0).toDouble(),
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.018),

                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                          SizedBox(
                            width: progressWidth,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    minHeight: (height * 0.007)
                                        .clamp(5.0, 8.0)
                                        .toDouble(),
                                    backgroundColor:
                                    white.withOpacity(0.12),
                                    valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                      white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.020),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: compact ? 16 : 20,
                                      height: compact ? 16 : 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: white.withOpacity(0.76),
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Text(
                                      'CARGANDO JUEGOS',
                                      style: TextStyle(
                                        color: white.withOpacity(0.80),
                                        fontSize: (width * 0.027)
                                            .clamp(11.0, 15.0)
                                            .toDouble(),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.075),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildMoodTitle() {
    return SizedBox(
      width: double.infinity,
      height: 105,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 28,
            top: 0,
            child: Text(
              'choose your',
              style: TextStyle(
                color: white.withOpacity(0.96),
                fontSize: 34,
                height: 0.95,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.18),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 54,
            top: 36,
            child: Text(
              'mood',
              style: TextStyle(
                color: white.withOpacity(0.98),
                fontSize: 52,
                height: 0.9,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.20),
                    blurRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Duration _entranceDuration = Duration(milliseconds: 1500);

  /// Anima de 0 a 1 al abrir la pantalla, empezando en [delay] (fracción
  /// de [_entranceDuration]).
  Widget _entrance({
    required double delay,
    required Widget Function(double t) builder,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _entranceDuration,
      curve: Interval(
        delay,
        math.min(1, delay + 0.6),
        curve: Curves.easeOutCubic,
      ),
      builder: (context, t, _) => builder(t),
    );
  }

  Widget buildMoodOption({
    required String id,
    required String title,
    required Color accent,
    required Alignment alignment,
    required VoidCallback onTap,
  }) {
    final bool isChill = alignment == Alignment.centerRight;

    const double parentPadding = 30;
    const double sideInset = 28;
    final double wordDelay = isChill ? 0.15 : 0.32;
    final double lineDelay = isChill ? 0.2 : 0.38;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 82,
        child: Padding(
          padding: EdgeInsets.only(
            left: isChill ? 0 : sideInset,
            right: isChill ? sideInset : 0,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Brillo suave del color del mood detrás de la palabra.
              Positioned(
                top: -34,
                left: isChill ? null : -36,
                right: isChill ? -36 : null,
                child: IgnorePointer(
                  child: _entrance(
                    delay: wordDelay,
                    builder: (t) => Opacity(
                      opacity: t,
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: 30,
                          sigmaY: 30,
                        ),
                        child: Container(
                          width: 230,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(120),
                            color: accent.withValues(alpha: 0.30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 0,
                left: isChill ? null : 0,
                right: isChill ? 0 : null,
                child: _entrance(
                  delay: wordDelay,
                  builder: (t) => Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset((1 - t) * (isChill ? 46 : -46), 0),
                      child: MoodBouncy(
                        physics: _moodPhysics,
                        id: '$id-word',
                        child: Text(
                          title,
                          textAlign: isChill ? TextAlign.right : TextAlign.left,
                          style: const TextStyle(
                            color: white,
                            fontSize: 66,
                            height: 0.9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 68,
                left: isChill ? -parentPadding : 0,
                right: isChill ? 0 : -parentPadding,
                child: _entrance(
                  delay: lineDelay,
                  // La línea se dibuja desde el borde de la pantalla.
                  builder: (t) => Transform.scale(
                    scaleX: t,
                    scaleY: 1,
                    alignment: isChill
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: MoodBouncy(
                      physics: _moodPhysics,
                      id: '$id-line',
                      child: Container(
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMoodScreen() {
    return Scaffold(
      key: const ValueKey('mood'),
      backgroundColor: blue,
      body: MoodRain(physics: _moodPhysics, child: Stack(
        children: [
          buildTopIcons(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 150, 30, 30),
              child: Column(
                children: [
                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 105,
                    child: Center(
                      child: SizedBox(
                        width: 280,
                        height: 105,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              child: MoodBouncy(physics: _moodPhysics, id: 'chooseYour', child: Text(
                                AppSettings.instance.t('chooseYour'),
                                style: TextStyle(
                                  color: white.withOpacity(0.96),
                                  fontSize: 34,
                                  height: 0.95,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.18),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              )),
                            ),
                            Positioned(
                              left: 120,
                              top: 36,
                              child: MoodBouncy(physics: _moodPhysics, id: 'mood', child: Text(
                                AppSettings.instance.t('mood'),
                                style: TextStyle(
                                  color: white.withOpacity(0.98),
                                  fontSize: 52,
                                  height: 0.9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white.withOpacity(0.20),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  buildMoodOption(
                    id: 'chill',
                    accent: CuboColors.chill,
                    title: AppSettings.instance.t('chill'),
                    alignment: Alignment.centerRight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChillScreen(),
                        ),
                      );
                    },
                  ),



                  const SizedBox(height: 72),

                  buildMoodOption(
                    id: 'fiesta',
                    accent: CuboColors.fiesta,
                    title: AppSettings.instance.t('party'),
                    alignment: Alignment.centerLeft,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FiestaScreen(),
                        ),
                      );
                    },
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: showSplash ? buildSplash() : buildMoodScreen(),
        );
      },
    );
  }
}
