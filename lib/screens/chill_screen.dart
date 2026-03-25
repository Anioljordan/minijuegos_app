import 'package:flutter/material.dart';
import '../data/games_data.dart';
import 'impostor_screen.dart';

class ChillScreen extends StatelessWidget {
  const ChillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juegos de chill'),
      ),
      body: ListView.builder(
        itemCount: juegosChill.length,
        itemBuilder: (context, index) {
          final juego = juegosChill[index];

          return ListTile(
            title: Text(juego),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              if (juego == 'Impostor') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImpostorScreen(),
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