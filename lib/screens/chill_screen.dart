import 'package:flutter/material.dart';
import 'impostor_screen.dart';
import 'cuatro_en_raya_screen.dart';
import 'escala_screen.dart';
import 'asamblea_setup_screen.dart';
import 'animales_profesionales_screen.dart';
import 'color_duel_screen.dart';
import 'barcelonamedianoche_screen.dart';
import 'describe_la_palabra_screen.dart';
import '../widgets/app_settings_button.dart';

class ChillScreen extends StatelessWidget {
  const ChillScreen({super.key});

  static const Color blue = Color(0xFF2F4F9C);
  static const Color white = Color(0xFFF7F7F7);

  Widget buildTopIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
          ),

          const AppSettingsButton(
            blue: blue,
            white: white,
          ),
        ],
      ),
    );
  }

  Widget buildTitle() {
    const double parentPadding = 30;
    const double sideInset = 28;

    return Padding(
      padding: const EdgeInsets.only(right: sideInset),
      child: SizedBox(
        width: double.infinity,
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              top: 0,
              right: 0,
              child: Text(
                'chill',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: white,
                  fontSize: 66,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            Positioned(
              top: 68,
              left: -parentPadding,
              right: 0,
              child: Container(
                height: 3,
                color: white.withOpacity(0.58),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGameButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: const BoxDecoration(
            color: white,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: blue,
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final juegos = [
      {
        'title': 'La Asamblea',
        'screen': const AsambleaSetupScreen(),
      },
      {
        'title': 'Impostor',
        'screen': const ImpostorScreen(),
      },
      {
        'title': 'BCN Medianoche',
        'screen': const BarcelonaMedianocheScreen(),
      },
      {
        'title': 'Markel & Cesar',
        'screen': const EscalaScreen(),
      },
      {
        'title': '4 en raya',
        'screen': const CuatroEnRayaScreen(),
      },
      {
        'title': 'Describe la palabra',
        'screen': const DescribeLaPalabraScreen(),
      },
      {
        'title': 'Memoria Fotográfica',
        'screen': const ColorDuelScreen(),
      },
      {
        'title': 'Animales Profesionales',
        'screen': const AnimalesProfesionalesScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: blue,
      body: Stack(
        children: [
          buildTopIcons(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 180, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildTitle(),
                  const SizedBox(height: 105),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: juegos.length,
                      itemBuilder: (context, index) {
                        final juego = juegos[index];

                        return buildGameButton(
                          title: juego['title'] as String,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}