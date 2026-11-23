import 'package:flutter/material.dart' hide Text;

import '../widgets/cubo_menu_layout.dart';
import 'drink_dare_screen.dart';
import 'moneda_screen.dart';
import 'piccolo_screen.dart';
import 'ping_pong_screen.dart';
import 'prueba_verdad_screen.dart';
import 'uno_dos_screen.dart';
import 'yo_nunca_modes_screen.dart';

class FiestaScreen extends StatelessWidget {
  const FiestaScreen({super.key});

  static final List<CuboMenuGame> _games = [
    CuboMenuGame(
      title: 'Yo Nunca',
      illustration: 'yo_nunca',
      fallbackIcon: Icons.front_hand_rounded,
      builder: (_) => const YoNuncaModesScreen(),
    ),
    CuboMenuGame(
      title: 'Señala al mas...',
      illustration: 'senala',
      fallbackIcon: Icons.back_hand_rounded,
      builder: (_) => const PiccoloScreen(),
    ),
    CuboMenuGame(
      title: '1 & 2',
      illustration: 'uno_dos',
      fallbackIcon: Icons.looks_two_rounded,
      builder: (_) => const UnoDosScreen(),
    ),
    CuboMenuGame(
      title: 'Prueba o verdad',
      illustration: 'prueba_verdad',
      fallbackIcon: Icons.style_rounded,
      builder: (_) => const PruebaVerdadScreen(),
    ),
    CuboMenuGame(
      title: 'La Ruleta',
      illustration: 'ruleta',
      fallbackIcon: Icons.casino_rounded,
      builder: (_) => const DrinkDareScreen(),
    ),
    CuboMenuGame(
      title: 'Moneda',
      illustration: 'moneda',
      fallbackIcon: Icons.monetization_on_rounded,
      builder: (_) => const MonedaScreen(),
    ),
    CuboMenuGame(
      title: 'Ping Pong',
      illustration: 'ping_pong',
      fallbackIcon: Icons.sports_tennis_rounded,
      builder: (_) => const PingPongScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CuboMenuLayout(
      title: 'fiesta',
      heroIllustration: 'fiesta_hero',
      mirrored: false,
      games: _games,
    );
  }
}
