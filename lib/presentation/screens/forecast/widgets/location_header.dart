import 'package:flutter/material.dart';
import 'glass_box.dart';

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
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GlassBox(
          isDark: isDark,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.location_on, color: Colors.redAccent, size: 36),
              const SizedBox(height: 8),
              Text(
                city,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: subTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
