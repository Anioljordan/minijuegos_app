import 'package:cubo/core/app_settings.dart';
import 'package:cubo/core/cubo_ui.dart';
import 'package:cubo/screens/chill_screen.dart';
import 'package:cubo/screens/escala_screen.dart';
import 'package:cubo/screens/fiesta_screen.dart';
import 'package:cubo/widgets/cubo_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpMenu(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: buildCuboTheme(), home: screen));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettings.instance.language = 'es';
  });

  testWidgets('Fiesta muestra sus 7 juegos en tarjetas', (tester) async {
    tester.view.physicalSize = const Size(412, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpMenu(tester, const FiestaScreen());

    expect(find.text('fiesta'), findsOneWidget);
    expect(find.byType(CuboGameTile), findsNWidgets(7));
    expect(find.text('Yo Nunca'), findsOneWidget);
  });

  testWidgets('Chill invierte el orden de las tarjetas (efecto espejo)',
      (tester) async {
    await _pumpMenu(tester, const ChillScreen());

    expect(find.text('chill'), findsOneWidget);
    final tile = find.byType(CuboGameTile).first;
    final arrow = find.descendant(
      of: tile,
      matching: find.byIcon(Icons.arrow_back_rounded),
    );
    final title = find.descendant(of: tile, matching: find.text('Impostor'));
    expect(tester.getCenter(arrow).dx, lessThan(tester.getCenter(title).dx));
  });

  testWidgets('Los menús siguen el idioma elegido', (tester) async {
    AppSettings.instance.language = 'en';
    await _pumpMenu(tester, const ChillScreen());

    expect(find.text('Describe the Word'), findsOneWidget);
  });

  group('Escala mental: elegir escala', () {
    Future<void> abrirSelector(WidgetTester tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpMenu(tester, const EscalaScreen());
      await tester.tap(find.byIcon(Icons.format_list_bulleted_rounded));
      await tester.pumpAndSettle();
    }

    testWidgets('filtrar por categoría deja solo sus escalas', (tester) async {
      await abrirSelector(tester);
      expect(find.text('Comida rica'), findsOneWidget);

      await tester.ensureVisible(find.text('Amor'));
      await tester.tap(find.text('Amor'));
      await tester.pumpAndSettle();

      expect(find.text('Green flag'), findsOneWidget);
      expect(find.text('Comida rica'), findsNothing);
    });

    testWidgets('elegir una escala empieza la ronda con ella', (tester) async {
      await abrirSelector(tester);
      await tester.ensureVisible(find.text('Amor'));
      await tester.tap(find.text('Amor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Green flag'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Green flag'), findsOneWidget);
      expect(find.text('Red flag'), findsOneWidget);
      expect(find.text('QUE NO MIRE EL JUGADOR 2'), findsOneWidget);
    });
  });
}
