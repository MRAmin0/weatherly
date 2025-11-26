import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class WeatherDrawer extends StatelessWidget {
  final WeatherViewModel vm;
  final AppLocalizations l10n;

  const WeatherDrawer({super.key, required this.vm, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            border: Border(
              left: isRtl ? BorderSide.none : BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              right: isRtl ? BorderSide(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ) : BorderSide.none,
            ),
          ),
          child: Column(
            children: [
              // --- GLASSMORPHIC HEADER ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.cloud_circle_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.weatherly,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- LIST ---
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ---------------- 1. PINNED SECTION ----------------
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                      child: Text(
                        l10n.pinnedLocations,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    _buildLocationTile(
                      context: context,
                      city: vm.defaultCity,
                      isPinnedSection: true,
                      isRtl: isRtl,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------- 2. RECENT SECTION ----------------
                    if (vm.recent.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
                        child: Text(
                          l10n.recentLocations,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      ...vm.recent.map((city) {
                        return _buildLocationTile(
                          context: context,
                          city: city,
                          isPinnedSection: false,
                          isRtl: isRtl,
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationTile({
    required BuildContext context,
    required String city,
    required bool isPinnedSection,
    required bool isRtl,
  }) {
    final theme = Theme.of(context);

    final isSelected = vm.location.toLowerCase() == city.toLowerCase();
    final isPinned = city.toLowerCase() == vm.defaultCity.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              isPinnedSection ? Icons.push_pin : Icons.history,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
          title: Text(
            city,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          onTap: () {
            vm.fetchWeatherByCity(city);
            Navigator.pop(context);
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPinnedSection)
                Container(
                  decoration: BoxDecoration(
                    color: isPinned
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    tooltip: 'سنجاق کردن',
                    onPressed: () {
                      vm.setDefaultCity(city);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          content: Text(
                            '$city پین شد',
                            style: const TextStyle(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  tooltip: isPinnedSection ? 'حذف پین' : 'حذف از تاریخچه',
                  onPressed: () {
                    if (isPinnedSection) {
                      vm.setDefaultCity('Tehran');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          content: const Text(
                            'مکان پیش‌فرض بازنشانی شد',
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    } else {
                      vm.removeRecent(city);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}