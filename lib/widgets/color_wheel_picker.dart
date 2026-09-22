import 'dart:math';
import 'package:flutter/material.dart' hide Text;
import 'i18n_text.dart';

class ColorWheelPicker extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;

  final double initialHue;
  final double initialSaturation;
  final double initialValue;

  final double maxWheelSize;

  const ColorWheelPicker({
    super.key,
    required this.onColorChanged,
    this.initialHue = 0,
    this.initialSaturation = 0,
    this.initialValue = 1,
    this.maxWheelSize = 225,
  });

  @override
  State<ColorWheelPicker> createState() =>
      _ColorWheelPickerState();
}

class _ColorWheelPickerState
    extends State<ColorWheelPicker> {
  double _hue = 0;
  double _saturation = 0;
  double _value = 1;

  @override
  void initState() {
    super.initState();

    _hue = widget.initialHue;
    _saturation = widget.initialSaturation;
    _value = widget.initialValue;
  }

  Color get _selectedColor =>
      HSVColor.fromAHSV(
        1,
        _hue,
        _saturation,
        _value,
      ).toColor();

  void _emitColor() {
    widget.onColorChanged(
      _selectedColor,
    );
  }

  Offset _selectorPosition(
      Size size,
      ) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius =
        size.width / 2;

    final angle =
        _hue * pi / 180;

    return Offset(
      center.dx +
          cos(angle) *
              (_saturation * radius),
      center.dy +
          sin(angle) *
              (_saturation * radius),
    );
  }

  void _updateWheelFromPosition(
      Offset position,
      Size size, {
        bool clampOutside = false,
      }) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    double dx =
        position.dx - center.dx;

    double dy =
        position.dy - center.dy;

    final radius =
        size.width / 2;

    final distance =
    sqrt(dx * dx + dy * dy);

    if (!clampOutside &&
        distance > radius) {
      return;
    }

    double finalDistance =
        distance;

    if (distance > radius &&
        distance > 0) {
      final factor =
          radius / distance;

      dx *= factor;
      dy *= factor;

      finalDistance =
          radius;
    }

    final angle =
    atan2(dy, dx);

    final hue =
        (angle * 180 / pi + 360) %
            360;

    final saturation =
    (finalDistance / radius)
        .clamp(
      0.0,
      1.0,
    );

    setState(() {
      _hue = hue;

      _saturation =
          saturation.toDouble();
    });

    _emitColor();
  }

  void _updateBrightness(
      double y,
      double height,
      ) {
    final newValue =
    (1 - (y / height))
        .clamp(
      0.0,
      1.0,
    );

    setState(() {
      _value =
          newValue.toDouble();
    });

    _emitColor();
  }

  Widget _buildBrightnessBar({
    required double height,
  }) {
    final brightColor =
    HSVColor.fromAHSV(
      1,
      _hue,
      _saturation,
      1,
    ).toColor();

    return SizedBox(
      width: 44,
      height: height,
      child: Column(
        children: [
          const Icon(
            Icons.light_mode_rounded,
            color: Colors.white,
            size: 18,
          ),

          const SizedBox(height: 5),

          Expanded(
            child: LayoutBuilder(
              builder:
                  (
                  context,
                  constraints,
                  ) {
                final barHeight =
                    constraints.maxHeight;

                final indicatorY =
                    (1 - _value) *
                        barHeight;

                final top =
                (indicatorY - 3)
                    .clamp(
                  0.0,
                  max(
                    0.0,
                    barHeight -
                        6,
                  ),
                )
                    .toDouble();

                return GestureDetector(
                  behavior:
                  HitTestBehavior
                      .opaque,

                  // Solo cambia al completar
                  // realmente un toque.
                  onTapUp:
                      (details) {
                    _updateBrightness(
                      details
                          .localPosition
                          .dy,
                      barHeight,
                    );
                  },

                  onVerticalDragUpdate:
                      (details) {
                    _updateBrightness(
                      details
                          .localPosition
                          .dy,
                      barHeight,
                    );
                  },

                  child: Stack(
                    clipBehavior:
                    Clip.none,
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration:
                          BoxDecoration(
                            gradient:
                            LinearGradient(
                              begin:
                              Alignment
                                  .topCenter,
                              end:
                              Alignment
                                  .bottomCenter,
                              colors: [
                                brightColor,
                                Colors.black,
                              ],
                            ),
                            border:
                            Border.all(
                              color: Colors
                                  .white
                                  .withOpacity(
                                0.75,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: top,
                        left: -5,
                        right: -5,
                        child: Container(
                          height: 6,
                          decoration:
                          BoxDecoration(
                            color:
                            Colors.white,
                            border:
                            Border.all(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.35,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.28,
                                ),
                                blurRadius:
                                5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${(_value * 100).round()}%',
            maxLines: 1,
            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.72),
              fontSize: 10.5,
              fontWeight:
              FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return LayoutBuilder(
      builder:
          (
          context,
          constraints,
          ) {
        const brightnessWidth =
        44.0;

        const gap = 13.0;

        final availableWidth =
        max(
          0.0,
          constraints.maxWidth -
              brightnessWidth -
              gap,
        );

        final availableHeight =
        constraints
            .maxHeight
            .isFinite
            ? constraints
            .maxHeight
            : widget.maxWheelSize;

        final calculatedSize =
        min(
          widget.maxWheelSize,
          min(
            availableWidth,
            availableHeight,
          ),
        );

        final wheelSize =
        calculatedSize
            .clamp(
          110.0,
          widget.maxWheelSize,
        )
            .toDouble();

        final size = Size(
          wheelSize,
          wheelSize,
        );

        final selector =
        _selectorPosition(size);

        final handleSize =
        wheelSize < 180
            ? 27.0
            : 31.0;

        return SizedBox(
          height: wheelSize,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              SizedBox(
                width: wheelSize,
                height: wheelSize,
                child: Stack(
                  clipBehavior:
                  Clip.none,
                  children: [
                    // La rueda SOLO cambia
                    // con un tap terminado.
                    GestureDetector(
                      behavior:
                      HitTestBehavior
                          .opaque,

                      onTapUp:
                          (details) {
                        _updateWheelFromPosition(
                          details
                              .localPosition,
                          size,
                        );
                      },

                      child: CustomPaint(
                        size: size,
                        painter:
                        _ColorWheelPainter(
                          value:
                          _value,
                        ),
                      ),
                    ),

                    // Solo este punto se
                    // puede arrastrar.
                    Positioned(
                      left:
                      selector.dx -
                          handleSize /
                              2,
                      top:
                      selector.dy -
                          handleSize /
                              2,
                      child:
                      GestureDetector(
                        behavior:
                        HitTestBehavior
                            .opaque,

                        onPanUpdate:
                            (details) {
                          final current =
                          _selectorPosition(
                            size,
                          );

                          _updateWheelFromPosition(
                            current +
                                details
                                    .delta,
                            size,
                            clampOutside:
                            true,
                          );
                        },

                        child: Container(
                          width:
                          handleSize,
                          height:
                          handleSize,
                          decoration:
                          BoxDecoration(
                            shape:
                            BoxShape
                                .circle,
                            color:
                            _selectedColor,
                            border:
                            Border.all(
                              color:
                              Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .black
                                    .withOpacity(
                                  0.35,
                                ),
                                blurRadius:
                                7,
                                spreadRadius:
                                1,
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                            Container(
                              width: 5,
                              height: 5,
                              decoration:
                              const BoxDecoration(
                                color: Colors
                                    .white,
                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: gap,
              ),

              _buildBrightnessBar(
                height: wheelSize,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColorWheelPainter
    extends CustomPainter {
  final double value;

  const _ColorWheelPainter({
    required this.value,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final center =
    size.center(
      Offset.zero,
    );

    final radius =
        size.width / 2;

    final rect =
    Offset.zero & size;

    final huePaint = Paint()
      ..shader =
      const SweepGradient(
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(rect);

    canvas.drawCircle(
      center,
      radius,
      huePaint,
    );

    final whiteOverlay =
    Paint()
      ..shader =
      RadialGradient(
        colors: [
          Colors.white,
          Colors.white
              .withOpacity(0),
        ],
      ).createShader(rect);

    canvas.drawCircle(
      center,
      radius,
      whiteOverlay,
    );

    if (value < 1) {
      final blackOverlay =
      Paint()
        ..color = Colors.black
            .withOpacity(
          1 - value,
        );

      canvas.drawCircle(
        center,
        radius,
        blackOverlay,
      );
    }
  }

  @override
  bool shouldRepaint(
      covariant _ColorWheelPainter
      oldDelegate,
      ) {
    return oldDelegate.value !=
        value;
  }
}