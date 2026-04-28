import 'package:flutter/material.dart';
import 'yo_nunca_screen.dart';

class YoNuncaModesScreen extends StatelessWidget {
  const YoNuncaModesScreen({super.key});

  void abrirModo(BuildContext context, String modo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoNuncaScreen(modo: modo),
      ),
    );
  }

  Widget buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08051A),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF25113B),
                Color(0xFF10091F),
                Color(0xFF070411),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.home_rounded, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Yo Nunca Nunca',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige el modo de juego',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildModeCard(
                    context: context,
                    title: 'Modo Chill',
                    subtitle: 'Preguntas suaves, graciosas y para todos.',
                    icon: Icons.spa_rounded,
                    colors: const [Color(0xFF14B8A6), Color(0xFF0F766E)],
                    onTap: () => abrirModo(context, 'chill'),
                  ),
                  const SizedBox(height: 16),
                  buildModeCard(
                    context: context,
                    title: 'Modo Mix',
                    subtitle: 'Mezcla de preguntas chill y más picantes.',
                    icon: Icons.shuffle_rounded,
                    colors: const [Color(0xFFF97316), Color(0xFFDB2777)],
                    onTap: () => abrirModo(context, 'mix'),
                  ),
                  const SizedBox(height: 16),
                  buildModeCard(
                    context: context,
                    title: 'Modo Erótico',
                    subtitle: 'Preguntas más atrevidas para jugar con confianza.',
                    icon: Icons.local_fire_department_rounded,
                    colors: const [Color(0xFFFF005C), Color(0xFF7C2D12)],
                    onTap: () => abrirModo(context, 'erotico'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}