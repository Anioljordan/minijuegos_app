import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  bool _loaded = false;

  String language = 'es';
  double volume = 0.8;
  bool soundEnabled = true;
  bool vibrationEnabled = true;

  /// Cómo se muestran los juegos en Fiesta y Chill: 'grid' (cuadrícula con
  /// el primero destacado) o 'carousel'.
  String menuStyle = 'grid';

  Future<void> load() async {
    if (_loaded) return;

    final prefs = await SharedPreferences.getInstance();

    language = prefs.getString('app_language') ?? 'es';
    volume = (prefs.getDouble('app_volume') ?? 0.8).clamp(0.0, 1.0);
    soundEnabled = prefs.getBool('app_sound_enabled') ?? true;
    vibrationEnabled = prefs.getBool('app_vibration_enabled') ?? true;
    final storedMenu = prefs.getString('app_menu_style');
    menuStyle = storedMenu == 'carousel' ? 'carousel' : 'grid';

    _loaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('app_language', language);
    await prefs.setDouble('app_volume', volume);
    await prefs.setBool('app_sound_enabled', soundEnabled);
    await prefs.setBool('app_vibration_enabled', vibrationEnabled);
    await prefs.setString('app_menu_style', menuStyle);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    await _save();
  }

  Future<void> setVolume(double value) async {
    volume = value.clamp(0.0, 1.0);
    notifyListeners();
    await _save();
  }

  Future<void> setSoundEnabled(bool value) async {
    soundEnabled = value;
    notifyListeners();
    await _save();
  }

  Future<void> setMenuStyle(String value) async {
    menuStyle = value == 'carousel' ? 'carousel' : 'grid';
    notifyListeners();
    await _save();
  }

  Future<void> setVibrationEnabled(bool value) async {
    vibrationEnabled = value;
    notifyListeners();
    await _save();
  }

  String t(String key) {
    final translations = {
      'es': {
        'chooseYour': 'escoge tu',
        'mood': 'mood',
        'party': 'fiesta',
        'chill': 'chill',
        'settings': 'Ajustes',
        'language': 'Idioma',
        'volume': 'Volumen',
        'sound': 'Sonidos',
        'vibration': 'Vibración',
        'menuStyle': 'Menú de juegos',
        'menuGrid': 'Cuadrícula',
        'menuCarousel': 'Carrusel',
        'resetData': 'Reiniciar datos guardados',
        'about': 'Acerca de la app',
        'close': 'Cerrar',
        'spanish': 'Español',
        'catalan': 'Català',
        'english': 'English',
        'dataReset': 'Datos guardados reiniciados',
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
        'menuStyle': 'Menú de jocs',
        'menuGrid': 'Quadrícula',
        'menuCarousel': 'Carrusel',
        'resetData': 'Reiniciar dades guardades',
        'about': 'Sobre l’app',
        'close': 'Tancar',
        'spanish': 'Espanyol',
        'catalan': 'Català',
        'english': 'English',
        'dataReset': 'Dades guardades reiniciades',
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
        'menuStyle': 'Games menu',
        'menuGrid': 'Grid',
        'menuCarousel': 'Carousel',
        'resetData': 'Reset saved data',
        'about': 'About the app',
        'close': 'Close',
        'spanish': 'Español',
        'catalan': 'Català',
        'english': 'English',
        'dataReset': 'Saved data reset',
      },
    };

    return translations[language]?[key] ?? translations['es']![key]!;
  }

  Future<void> resetSavedGameData(BuildContext context) async {
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

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('dataReset')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
