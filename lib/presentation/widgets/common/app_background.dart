import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    // رنگ بک‌گراند متناسب با مود
    final Color backgroundColor = brightness == Brightness.dark
        ? const Color(0xFF0F0F0F) // دارک مود زیبا
        : const Color(0xFFF7F4F8); // لایت مود مینیمال و خاص

    return Container(color: backgroundColor);
  }
}
