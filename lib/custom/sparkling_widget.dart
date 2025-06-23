import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

class ShinySparkleEffect extends StatefulWidget {
  final Widget child;

  const ShinySparkleEffect({super.key, required this.child});

  @override
  State<ShinySparkleEffect> createState() => _ShinySparkleEffectState();
}

class _ShinySparkleEffectState extends State<ShinySparkleEffect>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();
  static const int maxSparkles = 15;
  static const Duration sparkleLifetime = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 200), _addSparkle);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addSparkle(Timer timer) {
    if (_sparkles.length < maxSparkles) {
      setState(() {
        _sparkles.add(
          Sparkle(
            position: Offset(
              _random.nextDouble() * 256,
              _random.nextDouble() * 256,
            ),
            size: _random.nextDouble() * 8 + 4,
            color: _getRandomSparkleColor(),
            createdAt: DateTime.now(),
          ),
        );
      });
    }

    // Remove expired sparkles
    setState(() {
      _sparkles.removeWhere(
        (sparkle) =>
            DateTime.now().difference(sparkle.createdAt) > sparkleLifetime,
      );
    });
  }

  Color _getRandomSparkleColor() {
    final colors = [
      Colors.yellowAccent,
      Colors.white,
      Colors.amberAccent,
      Colors.lightBlueAccent,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        widget.child,
        SizedBox(
          width: 256,
          height: 256,
          child: CustomPaint(
            painter: SparklesPainter(
              sparkles: _sparkles,
              lifetime: sparkleLifetime,
            ),
          ),
        ),
      ],
    );
  }
}

class Sparkle {
  final Offset position;
  final double size;
  final Color color;
  final DateTime createdAt;

  Sparkle({
    required this.position,
    required this.size,
    required this.color,
    required this.createdAt,
  });
}

class SparklesPainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final Duration lifetime;

  SparklesPainter({required this.sparkles, required this.lifetime});

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final progress =
          DateTime.now().difference(sparkle.createdAt).inMilliseconds /
          lifetime.inMilliseconds;

      // Calculate opacity based on lifetime (fade in and out)
      double opacity;
      if (progress < 0.3) {
        opacity = progress / 0.3; // Fade in
      } else if (progress > 0.7) {
        opacity = (1 - progress) / 0.3; // Fade out
      } else {
        opacity = 1.0; // Full opacity
      }

      final paint =
          Paint()
            ..color = sparkle.color.withValues(alpha: opacity)
            ..style = PaintingStyle.fill;

      // Draw a star
      _drawStar(canvas, sparkle.position, sparkle.size, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    const int points = 4;
    final Path path = Path();

    for (int i = 0; i < points * 2; i++) {
      final double radius = i.isEven ? size : size / 2;
      final double angle = i * pi / points;

      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklesPainter oldDelegate) => true;
}
