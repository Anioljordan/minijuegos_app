import 'dart:ui';
import 'package:flutter/material.dart';
import 'fiesta_screen.dart';
import 'chill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  /// 🎨 CARD PRINCIPAL

  Widget buildMainCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),

          padding: const EdgeInsets.all(26),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),

            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.45),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),

          child: Row(
            children: [

              /// TEXTO

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              /// ICONO BONITO

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  size: 42,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🌌 FONDO ANIMADO

  Widget buildAnimatedBackground() {

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {

        final v = _bgController.value;

        return Stack(
          children: [

            /// GRADIENTE BASE

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF120A2A),
                    Color(0xFF08051A),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            /// LUZ SUPERIOR

            Positioned(
              top: -120 + (v * 60),
              left: -80,
              right: -80,
              child: _glowLayer(
                height: 280,
                color: const Color(0xFF8B5CF6),
                opacity: 0.25,
              ),
            ),

            /// LUZ INFERIOR

            Positioned(
              bottom: -140 + (v * 50),
              left: -80,
              right: -80,
              child: _glowLayer(
                height: 320,
                color: const Color(0xFF2563EB),
                opacity: 0.22,
              ),
            ),

            /// GRANO

            Positioned.fill(
              child: CustomPaint(
                painter: _GrainPainter(
                  opacity: 0.04 + (v * 0.02),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowLayer({
    required double height,
    required Color color,
    required double opacity,
  }) {

    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color.withOpacity(opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  /// 🧠 UI

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF08051A),

      body: Stack(
        children: [

          /// FONDO

          Positioned.fill(
            child: buildAnimatedBackground(),
          ),

          /// CONTENIDO

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const SizedBox(height: 6),

                  /// TÍTULO

                  Text(
                    '¿A qué quieres jugar hoy?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,

                      shadows: [
                        Shadow(
                          color: Colors.white.withOpacity(0.25),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Elige el mood y empieza la partida.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// FIESTA

                  buildMainCard(
                    title: 'Juegos de fiesta',
                    subtitle: 'Retos, alcohol, risas y caos.',
                    icon: Icons.local_bar_rounded,
                    colors: const [
                      Color(0xFF8B5CF6),
                      Color(0xFF2563EB),
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FiestaScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  /// CHILL

                  buildMainCard(
                    title: 'Juegos chill',
                    subtitle: 'Palabras, estrategia y diversión.',
                    icon: Icons.nightlight_round,
                    colors: const [
                      Color(0xFF1E293B),
                      Color(0xFF020617),
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChillScreen(),
                        ),
                      );
                    },
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

/// 🎞️ GRANO

class _GrainPainter extends CustomPainter {

  final double opacity;

  _GrainPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity);

    for (double x = 0; x < size.width; x += 3) {
      for (double y = 0; y < size.height; y += 3) {

        if ((x + y) % 7 == 0) {

          canvas.drawRect(
            Rect.fromLTWH(x, y, 1, 1),
            paint,
          );

        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}