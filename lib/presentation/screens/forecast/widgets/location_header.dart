import 'package:flutter/material.dart';
import '../../../../presentation/widgets/common/glass_container.dart';

class LocationHeader extends StatelessWidget {
  final String city;
  final String subtitle;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;

  const LocationHeader({
    super.key,
    required this.city,
    required this.subtitle,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      isDark: true, // Force white styles
      borderRadius: 30,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: Colors.redAccent,
            size: 40,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            city,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
