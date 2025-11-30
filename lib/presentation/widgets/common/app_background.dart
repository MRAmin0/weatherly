import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // رنگ بک‌گراند متناسب با مود
    // گرادینت برای حالت مات و عمق‌دار
    final Decoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: brightness == Brightness.dark
            ? [const Color(0xFF1A1A1A), const Color(0xFF000000)]
            : [
                const Color(0xFFF2F2F7), // Light gray/blueish white
                const Color(0xFFE5E5EA), // Slightly darker gray
              ],
      ),
    );

    return Container(decoration: decoration);
  }
}
