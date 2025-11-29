import 'dart:ui';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Color color;
  final bool blur;

  const AppBackground({super.key, required this.color, required this.blur});

  @override
  Widget build(BuildContext context) {
    // بک‌گراند ساده با گرادیانت خیلی ملایم از رنگ کاربر
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            // کمی تیره‌تر کردن انتهای صفحه
            Color.alphaBlend(
              const Color(0x26000000), // مشکی با ~15% شفافیت
              color,
            ),
          ],
        ),
      ),
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                // لایه‌ی خیلی نازک روی blur
                color: Colors.black.withAlpha(38), // ≈ 0.15
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
