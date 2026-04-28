import 'dart:math';
import 'package:flutter/material.dart';

class ColorWheelPicker extends StatefulWidget {
  final ValueChanged<Color> onColorChanged;
  final double initialHue;
  final double initialSaturation;
  final double initialValue;

  const ColorWheelPicker({
    super.key,
    required this.onColorChanged,
    this.initialHue = 0,
    this.initialSaturation = 0,
    this.initialValue = 1,
  });

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  double _hue = 0;
  double _saturation = 0;
  double _value = 1;

  Offset? _selectorOffset;

  @override
  void initState() {
    super.initState();
    _hue = widget.initialHue;
    _saturation = widget.initialSaturation;
    _value = widget.initialValue;
  }

  Color get _selectedColor =>
      HSVColor.fromAHSV(1, _hue, _saturation, _value).toColor();

  void _emitColor() {
    widget.onColorChanged(_selectedColor);
  }

  void _handleTouch(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    final radius = size.width / 2;
    final distance = sqrt(dx * dx + dy * dy);

    if (distance > radius) return;

    double angle = atan2(dy, dx);
    double hue = (angle * 180 / pi + 360) % 360;
    double saturation = (distance / radius).clamp(0.0, 1.0);

    setState(() {
      _hue = hue;
      _saturation = saturation;
      _selectorOffset = localPosition;
    });

    _emitColor();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wheelSize = min(constraints.maxWidth, 280.0);
        final size = Size(wheelSize, wheelSize);
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.width / 2;

        final selector = _selectorOffset ??
            Offset(
              center.dx + cos(_hue * pi / 180) * (_saturation * radius),
              center.dy + sin(_hue * pi / 180) * (_saturation * radius),
            );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: wheelSize,
              height: wheelSize,
              child: GestureDetector(
                onPanDown: (details) => _handleTouch(details.localPosition, size),
                onPanUpdate: (details) => _handleTouch(details.localPosition, size),
                onTapDown: (details) => _handleTouch(details.localPosition, size),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: size,
                      painter: _ColorWheelPainter(value: _value),
                    ),
                    Positioned(
                      left: selector.dx - 11,
                      top: selector.dy - 11,
                      child: IgnorePointer(
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedColor,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Brillo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 0,
              max: 1,
              value: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                _emitColor();
              },
            ),
          ],
        );
      },
    );
  }
}

class _ColorWheelPainter extends CustomPainter {
  final double value;

  const _ColorWheelPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Offset.zero & size;

    final huePaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.cyan,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, huePaint);

    final whiteOverlay = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(0),
        ],
      ).createShader(rect);

    canvas.drawCircle(center, radius, whiteOverlay);

    if (value < 1) {
      final blackOverlay = Paint()
        ..color = Colors.black.withOpacity(1 - value);
      canvas.drawCircle(center, radius, blackOverlay);
    }
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}