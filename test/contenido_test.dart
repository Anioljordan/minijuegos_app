import 'package:cubo/core/content_i18n.dart';
import 'package:cubo/data/impostor_data.dart';
import 'package:cubo/data/yo_nunca_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada palabra del Impostor clásico tiene pistas', () {
    for (final category in classicWordsData) {
      for (final word in category['words'] as List) {
        expect((word['hints'] as List).isNotEmpty, isTrue, reason: '${word['word']}');
      }
    }
  });

  test('cada lugar de roles tiene pistas y roles', () {
    for (final place in rolesScenariosData) {
      expect((place['hints'] as List).isNotEmpty, isTrue);
      expect((place['roles'] as List).length, greaterThanOrEqualTo(4));
    }
  });

  test('cada nombre de fútbol tiene pistas', () {
    for (final words in footballWordsData.values) {
      for (final word in words) {
        expect(word.hints.isNotEmpty, isTrue, reason: word.name);
      }
    }
  });

  test('las pistas con doble sentido se traducen según la palabra', () {
    expect(localizeContentHint('Barbie', 'Muñeca', 'en'), 'Doll');
    expect(localizeContentHint('Reloj', 'Muñeca', 'en'), 'Wrist');
    expect(localizeContentHint('Pizza', 'Horno', 'es'), 'Horno');
  });

  test('Yo Nunca trae frases de serie sin repetir', () {
    expect(yoNuncaFrases.length, greaterThan(100));
    expect(yoNuncaFrases.toSet().length, yoNuncaFrases.length);
  });
}
