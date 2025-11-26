import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/screens/home_page.dart';
import 'package:weatherly_app/screens/forecast_screen.dart';
import 'package:weatherly_app/screens/settings_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/utils/weather_gradients.dart';
import 'package:weatherly_app/models/weather_type.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final vm = context.watch<WeatherViewModel>();

    final Color userSeedColor = vm.seedColor;

    final WeatherType currentType = vm.currentWeather != null
        ? vm.currentWeather!.weatherType
        : WeatherType.clear;

    final bgGradient = WeatherGradients.getGradient(currentType, userSeedColor);

    final List<Widget> pages = [
      HomePage(onSearchFocusChange: (_) {}),
      const ForecastScreen(),
      SettingsScreen(onGoToRecentCity: () => _onItemTapped(0)),
    ];

    return Container(
      decoration: BoxDecoration(gradient: bgGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: pages,
        ),

        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final color = states.contains(WidgetState.selected)
                  ? theme.colorScheme.primary
                  : Colors.white;
              return TextStyle(
                fontWeight: states.contains(WidgetState.selected)
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: color,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final color = states.contains(WidgetState.selected)
                  ? theme.colorScheme.primary
                  : Colors.white;
              return IconThemeData(color: color);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            indicatorColor: theme.colorScheme.secondaryContainer,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_filled),
                label: l10n.localeName == 'fa' ? 'خانه' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart_rounded),
                label: l10n.localeName == 'fa' ? 'پیش‌بینی' : 'Forecast',
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: l10n.localeName == 'fa' ? 'تنظیمات' : 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
