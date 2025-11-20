import 'package:flutter/material.dart';
import 'package:weatherly_app/screens/settings_screen.dart';
import 'package:weatherly_app/screens/home_page.dart';
import 'package:weatherly_app/screens/forecast_screen.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';

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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (mounted) {
                setState(() => _selectedTabIndex = index);
              }
            },
            children: [
              HomePage(
                key: const ValueKey('weather_page'),
                onSearchFocusChange: (hasFocus) {
                  if (mounted) {
                    setState(() => _isSearchFocused = hasFocus);
                  }
                },
              ),
              const ForecastScreen(key: ValueKey('forecast_page')),
              SettingsScreen(
                key: const ValueKey('settings_page'),
                currentThemeMode: widget.currentThemeMode,
                onThemeChanged: widget.onThemeChanged,
                onLocaleChanged: widget.onLocaleChanged,
                onGoToDefaultCity: () => _goToTab(0),
                onGoToRecentCity: () => _goToTab(0),
              ),
            ],
          ),
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
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withAlpha(153);
    final double systemBottomPadding = MediaQuery.of(
      context,
    ).viewPadding.bottom;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey.withAlpha(51), width: 0.5),
              ),
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
          if (systemBottomPadding > 0)
            Container(height: systemBottomPadding, color: cardColor),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? activeColor : inactiveColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }
}
