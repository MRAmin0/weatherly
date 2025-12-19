import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/common/glass_container.dart';

class RecentCitiesSlider extends StatelessWidget {
  const RecentCitiesSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // تشخیص جهت متن (برای گرد کردن صحیح گوشه‌ها در فارسی و انگلیسی)
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final radius = const Radius.circular(24);

    // محاسبه BorderRadius برای دکمه شروع (پین)
    final startBorderRadius = isRtl
        ? BorderRadius.only(topRight: radius, bottomRight: radius)
        : BorderRadius.only(topLeft: radius, bottomLeft: radius);

    // محاسبه BorderRadius برای دکمه پایان (حذف)
    final endBorderRadius = isRtl
        ? BorderRadius.only(topLeft: radius, bottomLeft: radius)
        : BorderRadius.only(topRight: radius, bottomRight: radius);

    if (vm.recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            l10n.recentSearches,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: vm.recent.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = vm.recent[index];
              final isSelected =
                  city.toLowerCase() == vm.location.toLowerCase();
              final isPinned =
                  city.toLowerCase() == vm.defaultCity.toLowerCase();

              final foregroundColor = isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.8);

              return GlassContainer(
                isDark: true,
                padding: EdgeInsets.zero,
                borderRadius: 24,
                // Add border if selected for better visibility
                blur: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- دکمه پین (Start) ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: startBorderRadius, // ✅ اصلاح شد
                        onTap: () {
                          vm.setDefaultCity(city);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '$city ${l10n.localeName == 'fa' ? 'پین شد' : 'Pinned'}',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                          child: Icon(
                            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 16,
                            color: isPinned
                                ? theme.colorScheme.primary
                                : foregroundColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),

                    // --- متن شهر (Middle) ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => vm.fetchWeatherByCity(city),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 4,
                          ),
                          child: Text(
                            city,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: foregroundColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- دکمه حذف (End) ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: endBorderRadius, // ✅ اصلاح شد
                        onTap: () => vm.removeRecent(city),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: foregroundColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
