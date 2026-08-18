import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rewire/core/constants/app_colors.dart';

enum SparkMood { idle, support, celebrate }

class SparkOrb extends StatefulWidget {
  const SparkOrb({
    super.key,
    this.size = 180,
    this.mood = SparkMood.idle,
    this.breathing = false,
  });

  final double size;
  final SparkMood mood;
  final bool breathing;

  @override
  State<SparkOrb> createState() => _SparkOrbState();
}

class _SparkOrbState extends State<SparkOrb> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );
    if (widget.breathing) _breath.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant SparkOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.breathing && !_breath.isAnimating) {
      _breath.repeat(reverse: true);
    } else if (!widget.breathing && _breath.isAnimating) {
      _breath.stop();
      _breath.value = 0.35;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _breath.dispose();
    super.dispose();
  }

  Color get _core {
    switch (widget.mood) {
      case SparkMood.idle:
        return AppColors.spark;
      case SparkMood.support:
        return AppColors.teal;
      case SparkMood.celebrate:
        return AppColors.moss;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulse, _breath]),
      builder: (context, _) {
        final breath = widget.breathing ? 0.85 + (_breath.value * 0.25) : 1.0;
        final glow = 0.35 + (_pulse.value * 0.25);
        return Transform.scale(
          scale: breath,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _SparkPainter(core: _core, glow: glow),
            ),
          ),
        );
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.core, required this.glow});

  final Color core;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.6;

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [
          core.withValues(alpha: glow),
          core.withValues(alpha: 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, halo);

    final body = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.sparkGlow,
          core,
          core.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, body);

    final sparkle = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi / 4) * i;
      final inner = Offset(
        center.dx + math.cos(angle) * (radius * 0.15),
        center.dy + math.sin(angle) * (radius * 0.15),
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius * 0.38),
        center.dy + math.sin(angle) * (radius * 0.38),
      );
      canvas.drawLine(inner, outer, sparkle);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) =>
      oldDelegate.glow != glow || oldDelegate.core != core;
}
