import 'dart:async';
import 'package:flutter/material.dart';
import 'fiesta_screen.dart';
import 'chill_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_settings_button.dart';
import '../core/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSplash = true;

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

    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      setState(() {
        showSplash = false;
      });
    });
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: white.withOpacity(0.85),
                width: 2.2,
              ),
            ),
            child: const Center(
              child: Text(
                '8',
                style: TextStyle(
                  color: white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: showSettingsSheet,
            child: Container(
              width: 54,
              height: 54,
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
      backgroundColor: blue,
      body: Stack(
        children: [
          buildTopIcons(),
          Positioned(
            left: 28,
            bottom: 330,
            child: Text(
              'Ready\nto play?',
              style: TextStyle(
                color: white,
                fontSize: 66,
                height: 0.95,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.white.withOpacity(0.22),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 0,
            child: CustomPaint(
              size: const Size(260, 120),
              painter: PeopleLinePainter(),
            ),
          ),
        ],
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

  Widget buildMoodOption({
    required String title,
    required Alignment alignment,
    required VoidCallback onTap,
  }) {
    final bool isChill = alignment == Alignment.centerRight;

    const double parentPadding = 30;
    const double sideInset = 28;

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
              Positioned(
                top: 0,
                left: isChill ? null : 0,
                right: isChill ? 0 : null,
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

              Positioned(
                top: 68,
                left: isChill ? -parentPadding : 0,
                right: isChill ? 0 : -parentPadding,
                child: Container(
                  height: 3,
                  color: white.withOpacity(0.58),
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
      backgroundColor: blue,
      body: Stack(
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
                              child: Text(
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
                              ),
                            ),
                            Positioned(
                              left: 120,
                              top: 36,
                              child: Text(
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  buildMoodOption(
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

                  const SizedBox(height: 72),

                  buildMoodOption(
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

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
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

class PeopleLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final baseY = size.height * 0.78;

    void person(double x, double scale) {
      canvas.drawCircle(Offset(x, baseY - 52 * scale), 10 * scale, paint);

      final body = Path()
        ..moveTo(x, baseY - 42 * scale)
        ..lineTo(x - 10 * scale, baseY - 10 * scale)
        ..lineTo(x + 10 * scale, baseY - 10 * scale)
        ..close();

      canvas.drawPath(body, paint);

      canvas.drawLine(
        Offset(x - 7 * scale, baseY - 30 * scale),
        Offset(x - 25 * scale, baseY - 20 * scale),
        paint,
      );

      canvas.drawLine(
        Offset(x + 7 * scale, baseY - 30 * scale),
        Offset(x + 28 * scale, baseY - 20 * scale),
        paint,
      );

      canvas.drawLine(
        Offset(x - 7 * scale, baseY - 10 * scale),
        Offset(x - 18 * scale, baseY + 18 * scale),
        paint,
      );

      canvas.drawLine(
        Offset(x + 7 * scale, baseY - 10 * scale),
        Offset(x + 18 * scale, baseY + 18 * scale),
        paint,
      );
    }

    person(45, 0.85);
    person(88, 1.0);
    person(132, 0.9);
    person(178, 0.95);
    person(220, 1.1);

    canvas.drawLine(
      Offset(20, baseY + 18),
      Offset(size.width - 15, baseY + 18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}