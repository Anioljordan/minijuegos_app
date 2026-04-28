import 'dart:math';
import 'package:flutter/material.dart';
import '../data/animales_profesionales_data.dart';

class AnimalesProfesionalesScreen extends StatefulWidget {
  const AnimalesProfesionalesScreen({super.key});

  @override
  State<AnimalesProfesionalesScreen> createState() =>
      _AnimalesProfesionalesScreenState();
}

class _AnimalesProfesionalesScreenState
    extends State<AnimalesProfesionalesScreen> {
  final Random _random = Random();

  AnimalProfesionalItem? _itemActual;
  bool _oculto = false;

  void _generarNuevo() {
    final animal = AnimalesProfesionalesData
        .animales[_random.nextInt(AnimalesProfesionalesData.animales.length)];
    final profesion = AnimalesProfesionalesData.profesiones[
    _random.nextInt(AnimalesProfesionalesData.profesiones.length)];

    setState(() {
      _itemActual = AnimalProfesionalItem(
        animal: animal["nombre"]!,
        profesion: profesion["nombre"]!,
        animalEmoji: animal["emoji"]!,
        profesionEmoji: profesion["emoji"]!,
      );
      _oculto = false;
    });
  }

  void _toggleOcultar() {
    if (_itemActual == null) return;

    setState(() {
      _oculto = !_oculto;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF052E16),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF22C55E),
                Color(0xFF15803D),
                Color(0xFF052E16),
                Color(0xFF08051A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                right: -70,
                child: Container(
                  width: 270,
                  height: 270,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent.withOpacity(0.10),
                  ),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.home_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Animales Profesionales',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Haz mímica del animal mientras haces la profesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Expanded(
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 36,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.11),
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.16),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildContenido(Theme.of(context)),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _generarNuevo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF15803D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 17),
                            child: Text(
                              'GENERAR',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _itemActual == null ? null : _toggleOcultar,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              _oculto ? 'MOSTRAR' : 'OCULTAR',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContenido(ThemeData theme) {
    if (_itemActual == null) {
      return const Column(
        key: ValueKey('empty'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🐾', style: TextStyle(fontSize: 80)),
          SizedBox(height: 18),
          Text(
            'Pulsa GENERAR para empezar',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    if (_oculto) {
      return const Column(
        key: ValueKey('hidden'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_rounded,
            size: 76,
            color: Colors.white70,
          ),
          SizedBox(height: 18),
          Text(
            'Contenido oculto',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    }

    return Column(
      key: ValueKey('${_itemActual!.animal}-${_itemActual!.profesion}'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${_itemActual!.animalEmoji}  +  ${_itemActual!.profesionEmoji}',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 28),
        Text(
          _itemActual!.animal,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'haciendo de',
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _itemActual!.profesion,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}