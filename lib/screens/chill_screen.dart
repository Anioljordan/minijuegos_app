import 'package:flutter/material.dart';
import 'package:minijuegos_app/screens/describe_la_palabra_screen.dart';
import '../widgets/game_card.dart';
import 'impostor_screen.dart';
import 'cuatro_en_raya_screen.dart';
import 'escala_screen.dart';
import 'asamblea_setup_screen.dart';
import 'animales_profesionales_screen.dart';
import 'color_duel_screen.dart';
import 'barcelonamedianoche_screen.dart';
import 'describe_la_palabra_screen.dart';

class ChillScreen extends StatelessWidget {
  const ChillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final juegos = [
      {
        'title': 'La Asamblea',
        'icon': Icons.account_balance_outlined,
        'colors': [const Color(0xFF1F2937), const Color(0xFF111827)],
        'screen': const AsambleaSetupScreen(),
      },
      {
        'title': 'Impostor',
        'icon': Icons.person_search_outlined,
        'colors': [const Color(0xFFFF0505), const Color(0xFFFF5656)],
        'screen': const ImpostorScreen(),
      },
      {
        'title': 'Barcelona Medianoche',
        'icon': Icons.nightlife_outlined,
        'colors': [const Color(0xFFEC4899), const Color(0xFFBE185D)],
        'screen': const BarcelonaMedianocheScreen(),
      },
      {
        'title': 'Markel y Cesar',
        'icon': Icons.balance_outlined,
        'colors': [const Color(0xFFF97316), const Color(0xFFEA580C)],
        'screen': const EscalaScreen(),
      },
      {
        'title': 'Describe la palabra',
        'icon': Icons.chat_bubble_outline,
        'colors': [const Color(0xFF14B8A6), const Color(0xFF0F766E)],
        'screen': const DescribeLaPalabraScreen(),
      },
      {
        'title': '4 en raya',
        'icon': Icons.grid_view_rounded,
        'colors': [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
        'screen': const CuatroEnRayaScreen(),
      },
      {
        'title': 'Memoria Fotografica',
        'icon': Icons.palette_outlined,
        'colors': [const Color(0xFFA16207), const Color(0xFF854D0E)],
        'screen': const ColorDuelScreen(),
      },
      {
        'title': 'Animales Profesionales',
        'icon': Icons.pets_outlined,
        'colors': [const Color(0xFF22C55E), const Color(0xFF15803D)],
        'screen': const AnimalesProfesionalesScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      appBar: AppBar(
        title: const Text('Juegos de chill'),
        backgroundColor: const Color(0xFF08051A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: juegos.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            final juego = juegos[index];
            final Widget? screen = juego['screen'] as Widget?;

            return GameCard(
              title: juego['title'] as String,
              icon: juego['icon'] as IconData,
              gradientColors: juego['colors'] as List<Color>,
              onTap: () {
                if (screen != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => screen,
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}