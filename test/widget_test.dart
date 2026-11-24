import 'package:cubo/core/app_settings.dart';
import 'package:cubo/screens/chill_screen.dart';
import 'package:cubo/screens/escala_screen.dart';
import 'package:cubo/screens/fiesta_screen.dart';
import 'package:cubo/widgets/cubo_game_widgets.dart';
import 'package:cubo/widgets/cubo_menu_layout.dart';
import 'package:cubo/widgets/i18n_text.dart';
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

  void tallView(WidgetTester tester) {
    tester.view.physicalSize = const Size(412, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('Fiesta muestra sus 7 juegos en la cuadrícula', (tester) async {
    tallView(tester);
    await _pumpMenu(tester, const FiestaScreen());

    expect(find.text('fiesta'), findsOneWidget);
    final layout = tester.widget<CuboMenuLayout>(find.byType(CuboMenuLayout));
    expect(layout.games, hasLength(7));
    for (final game in layout.games) {
      expect(find.text(tr(game.title)), findsOneWidget);
    }
    expect(find.text('Yo Nunca'), findsOneWidget);
  });

  testWidgets('Chill alinea el título a la derecha (efecto espejo)',
      (tester) async {
    await _pumpMenu(tester, const ChillScreen());
    final screenWidth = tester.view.physicalSize.width /
        tester.view.devicePixelRatio;

    expect(
      tester.getCenter(find.text('chill')).dx,
      greaterThan(screenWidth / 2),
    );
  });

  testWidgets('Los menús siguen el idioma elegido', (tester) async {
    tallView(tester);
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
