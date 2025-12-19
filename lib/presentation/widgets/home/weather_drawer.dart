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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final drawerContent = Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2), // Darker base for drawer
        border: Border(
          left: isRtl
              ? BorderSide.none
              : BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
          right: isRtl
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          // --- HEADER ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 24,
              24,
              24,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_queue_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.weatherly,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // --- LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionHeader(l10n.pinnedLocations),
                _buildLocationTile(
                  context: context,
                  city: vm.defaultCity,
                  isPinnedSection: true,
                  isRtl: isRtl,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(color: Colors.white10),
                ),

                if (vm.recent.isNotEmpty) ...[
                  _buildSectionHeader(l10n.recentLocations),
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
    );

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: drawerContent,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.5,
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
    final isSelected = vm.location.toLowerCase() == city.toLowerCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white24 : Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPinnedSection ? Icons.push_pin_rounded : Icons.history_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          title: Text(
            city,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          onTap: () {
            vm.fetchWeatherByCity(city);
            Navigator.pop(context);
          },
          trailing: isSelected
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
}
