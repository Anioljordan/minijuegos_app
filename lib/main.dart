import 'package:flutter/material.dart';
import 'core/app_settings.dart';
import 'core/cubo_ui.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.instance.load();
  runApp(const MiniJuegosApp());
}

class MiniJuegosApp extends StatelessWidget {
  const MiniJuegosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppSettings.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildCuboTheme(),
          title: 'Cubo',
          // IMPORTANTE:
          // El idioma de Cubo se gestiona con AppSettings + i18n.dart.
          // No se fuerza MaterialApp.locale porque, sin flutter_localizations
          // en pubspec.yaml, Flutter no dispone de MaterialLocalizations para
          // es/ca y widgets como showModalBottomSheet fallan.
          home: const HomeScreen(),
        );
      },
    );
  }
}
