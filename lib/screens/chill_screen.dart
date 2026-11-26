import 'package:flutter/material.dart' hide Text;

import '../widgets/cubo_menu_layout.dart';
import 'animales_profesionales_screen.dart';
import 'asamblea_setup_screen.dart';
import 'color_duel_screen.dart';
import 'cuatro_en_raya_screen.dart';
import 'describe_la_palabra_screen.dart';
import 'escala_screen.dart';
import 'impostor_screen.dart';

class ChillScreen extends StatelessWidget {
  const ChillScreen({super.key});

  static final List<CuboMenuGame> _games = [
    CuboMenuGame(
      title: 'Impostor',
      illustration: 'impostor',
      fallbackIcon: Icons.person_search_rounded,
      builder: (_) => const ImpostorScreen(),
    ),
    CuboMenuGame(
      title: 'La Asamblea',
      illustration: 'asamblea',
      fallbackIcon: Icons.account_balance_rounded,
      builder: (_) => const AsambleaSetupScreen(),
    ),
    CuboMenuGame(
      title: 'Escala mental',
      illustration: 'escala',
      fallbackIcon: Icons.straighten_rounded,
      builder: (_) => const EscalaScreen(),
    ),
    CuboMenuGame(
      title: 'Memoria fotográfica',
      illustration: 'color_memory',
      fallbackIcon: Icons.palette_rounded,
      builder: (_) => const ColorDuelScreen(),
    ),
    CuboMenuGame(
      title: 'Describe la palabra',
      illustration: 'describe',
      fallbackIcon: Icons.record_voice_over_rounded,
      builder: (_) => const DescribeLaPalabraScreen(),
    ),
    CuboMenuGame(
      title: '4 en raya',
      illustration: 'cuatro_raya',
      fallbackIcon: Icons.grid_on_rounded,
      builder: (_) => const CuatroEnRayaScreen(),
    ),
    CuboMenuGame(
      title: 'Animales Profesionales',
      illustration: 'animales',
      fallbackIcon: Icons.pets_rounded,
      builder: (_) => const AnimalesProfesionalesScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CuboMenuLayout(
      title: 'chill',
      heroIllustration: 'chill_hero',
      mirrored: true,
      games: _games,
    );
  }
}
