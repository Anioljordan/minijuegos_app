import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/cubo_ui.dart';

/// Un elemento de la pantalla de inicio (una palabra, una línea) que se
/// mueve cuando le cae un cubo encima y vuelve a su sitio como un muelle.
class MoodBody {
  final GlobalKey key = GlobalKey();
  double dy = 0;
  double vy = 0;
  double angle = 0;
  double va = 0;

  bool get resting =>
      dy.abs() < 0.05 &&
      vy.abs() < 0.5 &&
      angle.abs() < 0.0005 &&
      va.abs() < 0.005;

  /// [impact] es la velocidad de caída del cubo; [lever] va de -1 (golpe en
  /// el extremo izquierdo) a 1 (derecho) y hace que se incline.
  void hit(double impact, double lever) {
    vy += impact * _impactToBounce;
    va += lever * impact * _impactToTilt;
  }

  void step(double dt) {
    vy += (-_stiffness * dy - _damping * vy) * dt;
    dy += vy * dt;
    va += (-_stiffness * angle - _damping * va) * dt;
    angle += va * dt;
    if (resting) {
      dy = vy = angle = va = 0;
    }
  }
}

const double _impactToBounce = 0.3;
const double _impactToTilt = 0.0008;
const double _stiffness = 260;
const double _damping = 13;

/// Todos los elementos que pueden recibir cubos.
class MoodPhysics extends ChangeNotifier {
  final Map<String, MoodBody> _bodies = {};

  MoodBody body(String id) => _bodies.putIfAbsent(id, MoodBody.new);

  Iterable<MoodBody> get bodies => _bodies.values;

  /// Avanza los muelles. Devuelve si algo se sigue moviendo.
  bool step(double dt) {
    var moving = false;
    for (final b in _bodies.values) {
      if (b.resting) continue;
      b.step(dt);
      moving = true;
    }
    if (moving) notifyListeners();
    return moving;
  }
}

/// Envuelve un elemento para que los cubos choquen con él y lo muevan.
class MoodBouncy extends StatelessWidget {
  final MoodPhysics physics;
  final String id;
  final Widget child;

  const MoodBouncy({
    super.key,
    required this.physics,
    required this.id,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final body = physics.body(id);
    return AnimatedBuilder(
      animation: physics,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, body.dy),
        child: Transform.rotate(angle: body.angle, child: child),
      ),
      child: KeyedSubtree(key: body.key, child: child),
    );
  }
}

class _Cube {
  double x;
  double y;
  double vx;
  double vy = 0;
  double angle;
  double spin;
  final double size;
  final Color fill;
  final Color rim;

  /// Veces que ha tocado algo. Al segundo toque ya no rebota: lo atraviesa
  /// y se cae.
  int hits = 0;

  _Cube({
    required this.x,
    required this.y,
    required this.vx,
    required this.angle,
    required this.spin,
    required this.size,
    required this.fill,
    required this.rim,
  });
}

const double _gravity = 1900;
const double _bounce = 0.42;
const int _maxCubes = 14;
const int _hitsBeforeFalling = 2;

const List<(Color, Color)> _cubeColors = [
  (CuboColors.blueLight, CuboColors.white),
  (CuboColors.chill, CuboColors.white),
  (CuboColors.fiesta, CuboColors.white),
  (CuboColors.white, CuboColors.blueLight),
];

/// Lluvia de cubos: cae uno cada [every] y otro donde se toque la pantalla.
/// Chocan con los [MoodBouncy] de [physics].
class MoodRain extends StatefulWidget {
  final MoodPhysics physics;
  final Duration every;
  final Widget child;

  const MoodRain({
    super.key,
    required this.physics,
    required this.child,
    this.every = const Duration(seconds: 10),
  });

  @override
  State<MoodRain> createState() => _MoodRainState();
}

class _MoodRainState extends State<MoodRain>
    with SingleTickerProviderStateMixin {
  final _stackKey = GlobalKey();
  final _cubes = <_Cube>[];
  final _repaint = ValueNotifier<int>(0);
  final _rng = math.Random();
  late final Ticker _ticker = createTicker(_tick);
  Timer? _timer;
  Timer? _firstDrop;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.every, (_) => _spawn());
    // El primero cae enseguida, para que se vea que existe.
    _firstDrop = Timer(const Duration(milliseconds: 1800), _spawn);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _firstDrop?.cancel();
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  RenderBox? get _stackBox {
    final box = _stackKey.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  void _spawn([double? atX]) {
    if (!mounted || MediaQuery.disableAnimationsOf(context)) return;
    final box = _stackBox;
    if (box == null || _cubes.length >= _maxCubes) return;
    final width = box.size.width;
    final size = 24 + _rng.nextDouble() * 14;
    final colors = _cubeColors[_rng.nextInt(_cubeColors.length)];
    _cubes.add(
      _Cube(
        x: (atX ?? size + _rng.nextDouble() * (width - 2 * size)).clamp(
          size,
          width - size,
        ),
        y: -size,
        vx: (_rng.nextDouble() - 0.5) * 60,
        angle: _rng.nextDouble() * math.pi,
        spin: (_rng.nextDouble() - 0.5) * 3,
        size: size,
        fill: colors.$1,
        rim: colors.$2,
      ),
    );
    if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  /// Dónde está ahora cada elemento con el que se puede chocar.
  List<(Rect, MoodBody)> _colliders(RenderBox stack) {
    final result = <(Rect, MoodBody)>[];
    for (final body in widget.physics.bodies) {
      final box = body.key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      final rect = MatrixUtils.transformRect(
        box.getTransformTo(stack),
        Offset.zero & box.size,
      );
      if (rect.width < 4) continue; // la línea aún se está dibujando
      result.add((rect, body));
    }
    return result;
  }

  void _tick(Duration elapsed) {
    final stack = _stackBox;
    if (stack == null) return;
    final dt = _last == Duration.zero
        ? 1 / 60
        : ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 1 / 30);
    _last = elapsed;

    final colliders = _colliders(stack);
    for (final c in _cubes) {
      _moveCube(c, dt, colliders);
    }
    final height = stack.size.height;
    _cubes.removeWhere((c) => c.y - c.size > height);

    final moving = widget.physics.step(dt);
    _repaint.value++;
    if (_cubes.isEmpty && !moving) _ticker.stop();
  }

  void _moveCube(_Cube c, double dt, List<(Rect, MoodBody)> colliders) {
    final prevBottom = c.y + c.size / 2;
    c.vy += _gravity * dt;
    c.x += c.vx * dt;
    c.y += c.vy * dt;
    c.angle += c.spin * dt;
    if (c.hits >= _hitsBeforeFalling) return;

    final bottom = c.y + c.size / 2;
    for (final (rect, body) in colliders) {
      final crossesTop = prevBottom <= rect.top + 2 && bottom >= rect.top;
      final overlapsX =
          c.x + c.size * 0.35 >= rect.left && c.x - c.size * 0.35 <= rect.right;
      if (!crossesTop || !overlapsX) continue;

      final lever = ((c.x - rect.center.dx) / (rect.width / 2)).clamp(
        -1.0,
        1.0,
      );
      body.hit(c.vy, lever);
      c.hits++;
      if (c.hits < _hitsBeforeFalling) {
        c.y = rect.top - c.size / 2;
        c.vy = -c.vy * _bounce;
        c.vx += lever * 90 + (_rng.nextDouble() - 0.5) * 70;
        c.spin = c.vx / c.size;
      } else {
        // Segundo golpe: lo atraviesa frenando un poco.
        c.vy *= 0.5;
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _stackKey,
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _spawn(d.localPosition.dx),
          ),
        ),
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _RainPainter(_cubes, repaint: _repaint),
            ),
          ),
        ),
      ],
    );
  }
}

class _RainPainter extends CustomPainter {
  final List<_Cube> cubes;

  _RainPainter(this.cubes, {required Listenable repaint})
    : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in cubes) {
      final s = c.size;
      canvas
        ..save()
        ..translate(c.x, c.y)
        ..rotate(c.angle);
      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s, height: s),
        Radius.circular(s * 0.22),
      );
      canvas
        ..drawRRect(body, Paint()..color = c.fill)
        ..drawRRect(
          body,
          Paint()
            ..color = c.rim
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.5, s * 0.08),
        )
        // Brillo de arriba, para que se lea como un cubo.
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-s * 0.34, -s * 0.34, s * 0.68, s * 0.24),
            Radius.circular(s * 0.1),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_RainPainter old) => false;
}
