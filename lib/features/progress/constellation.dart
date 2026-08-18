import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/models/star_model.dart';

class Constellation extends StatelessWidget {
  const Constellation({super.key, required this.stars});

  final List<StarModel> stars;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: CustomPaint(
        painter: _ConstellationPainter(count: stars.length),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  _ConstellationPainter({required this.count});

  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final center = Offset(size.width / 2, size.height / 2);

    final bg = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.surfaceHigh.withValues(alpha: 0.9),
          AppColors.night.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final starPaint = Paint()..color = AppColors.sparkGlow;
    final line = Paint()
      ..color = AppColors.spark.withValues(alpha: 0.28)
      ..strokeWidth = 1;

    final points = <Offset>[];
    for (var i = 0; i < count; i++) {
      final angle = (i / math.max(count, 1)) * math.pi * 2 + 0.4;
      final radius = 24.0 + (i * 11) % (size.shortestSide * 0.38);
      final wobble = (random.nextDouble() - 0.5) * 18;
      points.add(Offset(
        center.dx + math.cos(angle) * (radius + wobble),
        center.dy + math.sin(angle) * (radius + wobble * 0.6),
      ));
    }

    for (var i = 1; i < points.length; i++) {
      canvas.drawLine(points[i - 1], points[i], line);
    }

    for (final point in points) {
      canvas.drawCircle(point, 3.4, starPaint);
      canvas.drawCircle(
        point,
        8,
        Paint()..color = AppColors.spark.withValues(alpha: 0.18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) =>
      oldDelegate.count != count;
}
