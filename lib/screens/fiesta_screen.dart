import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import 'yo_nunca_modes_screen.dart';
import 'piccolo_screen.dart';
import 'uno_dos_screen.dart';
import 'prueba_verdad_screen.dart';
import 'drink_dare_screen.dart';
import 'ping_pong_screen.dart';

class FiestaScreen extends StatelessWidget {
  const FiestaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final juegos = [
      {
        'title': 'Yo Nunca Nunca',
        'icon': Icons.local_bar_outlined,
        'colors': [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
        'screen': const YoNuncaModesScreen(),
      },
      {
        'title': 'Señala y bebe',
        'icon': Icons.touch_app_outlined,
        'colors': [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
        'screen': const PiccoloScreen(),
      },
      {
        'title': '1 y 2',
        'icon': Icons.visibility_outlined,
        'colors': [const Color(0xFF48DCCB), const Color(0xFF22C1B5)],
        'screen': const UnoDosScreen(),
      },
      {
        'title': 'Prueba o verdad',
        'icon': Icons.theater_comedy_outlined,
        'colors': [const Color(0xFFFBBF24), const Color(0xFFF59E0B)],
        'screen': const PruebaVerdadScreen(),
      },
      {
        'title': 'Drink and Dare',
        'icon': Icons.blur_circular,
        'colors': [const Color(0xFFFF5A5F), const Color(0xFFEF4444)],
        'screen': const DrinkDareScreen(),
      },
      {
        'title': 'Ping Pong',
        'icon': Icons.timer_outlined,
        'colors': [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)],
        'screen': const PingPongScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      appBar: AppBar(
        title: const Text('Juegos de fiesta'),
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

            return GameCard(
              title: juego['title'] as String,
              icon: juego['icon'] as IconData,
              gradientColors: juego['colors'] as List<Color>,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => juego['screen'] as Widget,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}