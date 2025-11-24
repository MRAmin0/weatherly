// lib/screens/weather_screen.dart

import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';

// --- FIX: Explicitly import the separate screen files ---
import 'package:weatherly_app/screens/home_page.dart';
import 'package:weatherly_app/screens/forecast_screen.dart';
import 'package:weatherly_app/screens/settings_screen.dart';

class WeatherScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;

  const WeatherScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final PageController _pageController;
  int _selectedTabIndex = 0;
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedTabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // Prevents the bottom nav from jumping up when keyboard opens
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            // Disable swiping so it feels like a standard tab app
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (mounted) {
                setState(() => _selectedTabIndex = index);
              }
            },
            children: [
              // Tab 0: Home
              HomePage(
                key: const ValueKey('weather_page'),
                onSearchFocusChange: (hasFocus) {
                  if (mounted) {
                    setState(() => _isSearchFocused = hasFocus);
                  }
                },
              ),
              // Tab 1: Forecast
              const ForecastScreen(key: ValueKey('forecast_page')),
              // Tab 2: Settings
              SettingsScreen(
                key: const ValueKey('settings_page'),
                currentThemeMode: widget.currentThemeMode,
                onThemeChanged: widget.onThemeChanged,
                onLocaleChanged: widget.onLocaleChanged,
                // Both redirect to Home (Tab 0)
                onGoToDefaultCity: () => _goToTab(0),
                onGoToRecentCity: () => _goToTab(0),
              ),
            ],
          ),

          // Custom Bottom Navigation Bar
          // Hidden when searching to give keyboard space
          if (!_isSearchFocused)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCustomBottomNav(context, l10n),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomNav(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    // M3 Colors
    final backgroundColor = theme.colorScheme.surfaceContainer;
    final primaryColor = theme.colorScheme.primary;
    // Updated: withValues for Flutter 3.27+
    final unselectedColor = theme.textTheme.bodyMedium?.color?.withValues(
      alpha: 0.6,
    );
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.2);

    final double systemBottomPadding = MediaQuery.of(
      context,
    ).viewPadding.bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border(top: BorderSide(color: borderColor, width: 1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_filled,
                l10n.home,
                0,
                primaryColor,
                unselectedColor,
              ),
              _buildNavItem(
                Icons.bar_chart_rounded,
                l10n.forecast,
                1,
                primaryColor,
                unselectedColor,
              ),
              _buildNavItem(
                Icons.settings_outlined,
                l10n.settings,
                2,
                primaryColor,
                unselectedColor,
              ),
            ],
          ),
        ),
        // Space for gesture bar on newer phones
        if (systemBottomPadding > 0)
          Container(height: systemBottomPadding, color: backgroundColor),
      ],
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color activeColor,
    Color? inactiveColor,
  ) {
    final bool isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () => _goToTab(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          // M3 Pill shape highlight
          color: isSelected
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToTab(int index) {
    if (index == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }
}
