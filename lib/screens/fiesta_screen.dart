import 'package:flutter/material.dart';
import '../data/games_data.dart';
import 'yo_nunca_screen.dart';
import 'piccolo_screen.dart';
import 'uno_dos_screen.dart';
import 'prueba_verdad_screen.dart';
import 'drink_dare_screen.dart';
import 'ping_pong_screen.dart';

class FiestaScreen extends StatelessWidget {
  const FiestaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juegos de fiesta'),
      ),
      body: ListView.builder(
        itemCount: juegosFiesta.length,
        itemBuilder: (context, index) {
          final juego = juegosFiesta[index];

          return ListTile(
            title: Text(juego),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (juego == 'Yo Nunca Nunca') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const YoNuncaScreen(),
                  ),
                );
              }

              if (juego == 'Piccolo') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PiccoloScreen(),
                  ),
                );
              }
              if (juego == '1 y 2') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnoDosScreen(),
                  ),
                );
              }
              if (juego == 'Prueba o Verdad') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PruebaVerdadScreen(),
                  ),
                );
              }
              if (juego == 'Drink & Dare') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DrinkDareScreen(),
                  ),
                );
              }
              if (juego == 'Ping Pong') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PingPongScreen(),
                  ),
                );
              }

            },
          );
        },
      ),
    );
  }
}