import 'dart:math' as math;
import 'package:flutter/material.dart';

class RainDropAnimator extends StatefulWidget {
  final double width;
  final double height;

  const RainDropAnimator({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<RainDropAnimator> createState() => _RainDropAnimatorState();
}

class _RainDropAnimatorState extends State<RainDropAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_RainDrop> _drops = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _createDrops();
  }

  void _createDrops() {
    _drops.clear();
    for (int i = 0; i < 25; i++) {
      _drops.add(
        _RainDrop(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          speed: 0.05 + _random.nextDouble() * 0.1,
          length: 10 + _random.nextDouble() * 15,
          opacity: 0.2 + _random.nextDouble() * 0.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RainPainter(
              drops: _drops,
              progress: _controller.value,
              color: Colors.lightBlueAccent.withValues(alpha: 0.8),
            ),
          );
        },
      ),
    );
  }
}

class _RainDrop {
  final double x; // 0.0 to 1.0 (relative width)
  final double y; // 0.0 to 1.0 (relative height)
  final double speed;
  final double length;
  final double opacity;

  _RainDrop({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.opacity,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double progress;
  final Color color;

  _RainPainter({
    required this.drops,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    for (var drop in drops) {
      // Calculate current position with wraparound
      double currentY = (drop.y + progress * drop.speed * 20) % 1.0;
      double startX = drop.x * size.width;
      double startY = currentY * size.height;

      // Slight tilt for more organic look
      double endX = startX + 2;
      double endY = startY + drop.length;

      // Draw the drop as a line
      paint.color = color.withValues(alpha: drop.opacity);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}
