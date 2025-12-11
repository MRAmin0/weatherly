import 'package:flutter/material.dart';

class SearchingRadar extends StatefulWidget {
  final String message;
  final Color? color;

  const SearchingRadar({super.key, this.message = 'Scanning...', this.color});

  @override
  State<SearchingRadar> createState() => _SearchingRadarState();
}

class _SearchingRadarState extends State<SearchingRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _RadarPainter(animation: _controller, color: color),
              child: Center(
                child: Icon(
                  Icons.location_searching_rounded,
                  size: 40,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RadarPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 expanding circles
    for (int i = 0; i < 3; i++) {
      // Stagger animations: 0.0, 0.33, 0.66
      final initialOffset = i / 3.0;
      final value = (animation.value + initialOffset) % 1.0;

      final radius = maxRadius * value;
      final opacity = (1.0 - value).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2; // Thin rings

      canvas.drawCircle(center, radius, paint);

      // Optional: Fill for a softer effect
      final fillPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.1)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}
