import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final bool isDark;

  const GlassBox({
    super.key,
    required this.child,
    this.padding,
    this.radius = 20,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withAlpha(36), // ~0.14
                  Colors.white.withAlpha(15), // ~0.06
                ]
              : [
                  Colors.white.withAlpha(56), // ~0.22
                  Colors.white.withAlpha(36), // ~0.14
                ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(46) // ~0.18
              : Colors.black.withAlpha(26), // ~0.10
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(33), // ~0.13
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
