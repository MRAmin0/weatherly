// lib/widgets/home/recent_cities_slider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class RecentCitiesSlider extends StatelessWidget {
  const RecentCitiesSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // If there are no recent cities, hide the slider completely
    if (vm.recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            l10n.recentSearches,
            style: theme.textTheme.labelLarge?.copyWith(
              // Using withValues as requested for Flutter 3.27+
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vm.recent.length,
            // FIX: Changed (_, __) to (_, index) to remove linter warning
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = vm.recent[index];
              // Highlight if this is the currently displayed city
              final isSelected =
                  city.toLowerCase() == vm.location.toLowerCase();

              return ActionChip(
                label: Text(city),
                avatar: Icon(
                  Icons.history,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                backgroundColor: isSelected
                    ? theme.colorScheme.secondaryContainer
                    : theme.colorScheme.surfaceContainerHigh,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  // When tapped, fetch weather for this city
                  vm.fetchWeatherByCity(city);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
