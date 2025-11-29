import 'package:flutter/material.dart';

class WeatherDetailBox extends StatelessWidget {
  final Widget icon;
  final String title;
  final String value;

  const WeatherDetailBox({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withAlpha(40)
            : theme.colorScheme.surfaceVariant.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withAlpha(30)),
      ),
      child: Column(
        children: [
          SizedBox(height: 32, width: 32, child: Center(child: icon)),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
