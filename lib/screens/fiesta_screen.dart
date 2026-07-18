import 'package:flutter/material.dart';
import 'yo_nunca_modes_screen.dart';
import 'piccolo_screen.dart';
import 'uno_dos_screen.dart';
import 'prueba_verdad_screen.dart';
import 'drink_dare_screen.dart';
import 'ping_pong_screen.dart';
import '../widgets/app_settings_button.dart';
import '../widgets/app_logo_button.dart';

class FiestaScreen extends StatelessWidget {
  const FiestaScreen({super.key});

  static const Color blue = Color(0xFF2F4F9C);
  static const Color white = Color(0xFFF7F7F7);

  Widget buildTopIcons(BuildContext context) {
    final compact = MediaQuery.of(context).size.height < 740;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppLogoButton(
            compact: compact,
            onTap: () => Navigator.pop(context),
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
      padding: const EdgeInsets.only(left: sideInset),
      child: SizedBox(
        width: double.infinity,
        height: 82,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned(
              top: 0,
              left: 0,
              child: Text(
                'fiesta',
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
              left: 0,
              right: -parentPadding,
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
            alignment: Alignment.centerLeft,
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        'title': 'Yo Nunca',
        'screen': const YoNuncaModesScreen(),
      },
      {
        'title': 'Señala y bebe',
        'screen': const PiccoloScreen(),
      },
      {
        'title': '1 & 2',
        'screen': const UnoDosScreen(),
      },
      {
        'title': 'Prueba o verdad',
        'screen': const PruebaVerdadScreen(),
      },
      {
        'title': 'Drink & Dare',
        'screen': const DrinkDareScreen(),
      },
      {
        'title': 'Ping Pong',
        'screen': const PingPongScreen(),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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