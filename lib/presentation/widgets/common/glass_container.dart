import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final bool isDark;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 15,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = isDark || theme.brightness == Brightness.dark;

    // On Web, we disable BackdropFilter for better performance as blur calculation is expensive.
    // We compensate by increasing the opacity slightly.
    const bool disableBlur = kIsWeb;

    Widget containerContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.black.withValues(alpha: disableBlur ? 0.8 : 0.2)
            : Colors.white.withValues(alpha: disableBlur ? 0.9 : 0.2),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.3),
          width: 1.0,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  Colors.white.withValues(alpha: disableBlur ? 0.1 : 0.1),
                  Colors.white.withValues(alpha: disableBlur ? 0.05 : 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: disableBlur ? 0.4 : 0.4),
                  Colors.white.withValues(alpha: disableBlur ? 0.1 : 0.1),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    Widget content = Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: disableBlur
            ? containerContent
            : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: containerContent,
              ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}
