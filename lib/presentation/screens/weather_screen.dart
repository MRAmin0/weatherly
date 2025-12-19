import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/widgets/home/weather_background_wrapper.dart';

import 'package:weatherly_app/presentation/screens/home/home_page.dart';
import 'package:weatherly_app/presentation/screens/forecast/forecast_screen.dart';
import 'package:weatherly_app/presentation/screens/settings/settings_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _selectedIndex = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final vm = context.watch<WeatherViewModel>();

    final weatherType = vm.currentWeather?.weatherType ?? WeatherType.unknown;

    final pages = [
      HomePage(onSearchFocusChange: (_) {}),
      const ForecastScreen(),
      SettingsScreen(onGoToRecentCity: () => _onItemTap(0)),
    ];

    return WeatherBackgroundWrapper(
      weatherType: weatherType,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: pages,
        ),
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
                size: 26,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTap,
            backgroundColor: Colors.black.withValues(alpha: 0.1),
            elevation: 0,
            indicatorColor: Colors.white.withValues(alpha: 0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: l10n.localeName == 'fa' ? 'خانه' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart_rounded),
                label: l10n.localeName == 'fa' ? 'پیش‌بینی' : 'Forecast',
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: l10n.localeName == 'fa' ? 'تنظیمات' : 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
