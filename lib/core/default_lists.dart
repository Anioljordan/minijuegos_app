import 'package:shared_preferences/shared_preferences.dart';

/// Carga una lista editable por el usuario y, la primera vez, la rellena con
/// las frases de serie de Cubo. Las frases que el usuario ya tuviera
/// guardadas (también en claves antiguas) se conservan detrás de las de
/// serie, sin duplicados. Después de esa primera vez la lista es solo suya:
/// si borra frases de serie, no vuelven a aparecer.
Future<List<String>> loadListWithDefaults(
  SharedPreferences prefs,
  String key,
  List<String> defaults, {
  List<String> legacyKeys = const [],
}) async {
  final seededKey = '${key}_serie_v1';
  final saved = prefs.getStringList(key);

  if (prefs.getBool(seededKey) ?? false) return saved ?? <String>[];

  final result = <String>[];
  final seen = <String>{};

  void add(String value) {
    final text = value.trim();
    if (text.isNotEmpty && seen.add(text.toLowerCase())) result.add(text);
  }

  defaults.forEach(add);
  (saved ?? const <String>[]).forEach(add);
  for (final legacy in legacyKeys) {
    (prefs.getStringList(legacy) ?? const <String>[]).forEach(add);
  }

  await prefs.setStringList(key, result);
  await prefs.setBool(seededKey, true);
  return result;
}
