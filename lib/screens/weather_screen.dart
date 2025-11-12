import 'package:flutter/material.dart';
import 'package:weatherly_app/screens/settings_screen.dart';
import 'package:weatherly_app/screens/home_page.dart';
import 'package:weatherly_app/screens/forecast_screen.dart';

class WeatherScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const WeatherScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  int _selectedTabIndex = 0;
  // 👇 این state برای مخفی کردن نوار ناوبری هنگام جستجو لازمه
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    // فراخوانی لود دیتا حذف شد (WeatherStore خودش انجام می‌ده)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar حذف شد (هر صفحه خودش AppBar خودش رو مدیریت می‌کنه)
      body: Stack(
        children: [
          // استفاده از IndexedStack برای سوییچ بین صفحات
          IndexedStack(
            index: _selectedTabIndex,
            children: [
              // --- صفحه ۰: خانه ---
              HomePage(
                key: const ValueKey('weather_page'),
                // این callback رو پاس می‌دیم تا نوار پایین مخفی بشه
                onSearchFocusChange: (hasFocus) {
                  // 👇 بررسی 'mounted' برای جلوگیری از خطا
                  if (mounted) {
                    setState(() {
                      _isSearchFocused = hasFocus;
                    });
                  }
                },
              ),

              // --- صفحه ۱: پیش‌بینی ---
              const ForecastScreen(
                key: ValueKey('forecast_page'),
              ),

              // --- صفحه ۲: تنظیمات ---
              SettingsScreen(
                key: const ValueKey('settings_page'),
                currentThemeMode: widget.currentThemeMode,
                onThemeChanged: widget.onThemeChanged,
                onGoToDefaultCity: () => setState(() => _selectedTabIndex = 0),
                onGoToRecentCity: () => setState(() => _selectedTabIndex = 0),
              ),
            ],
          ),

          // نوار ناوبری پایین (فقط وقتی جستجو فعال نیست)
          if (!_isSearchFocused)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildCustomBottomNav(context),
            ),
        ],
      ),
    );
  }

  // 👇 🚀 بهینه‌سازی: نوار ناوبری (افکت سنگین blur حذف شد)
  Widget _buildCustomBottomNav(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withAlpha(153); // (Opacity 0.6)

    final double systemBottomPadding = MediaQuery.of(
      context,
    ).viewPadding.bottom;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0), // مارجین بالا
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- ۱. نوار اصلی با دکمه‌ها ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withAlpha(51),
                  width: 0.5,
                ), // (Opacity 0.2)
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_filled,
                  "خانه",
                  0,
                  primaryColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  Icons.bar_chart_rounded,
                  "پیش‌بینی",
                  1,
                  primaryColor,
                  unselectedColor,
                ),
                _buildNavItem(
                  Icons.settings_outlined,
                  "تنظیمات",
                  2,
                  primaryColor,
                  unselectedColor,
                ),
              ],
            ),
          ),

          // --- ۲. بخش جایگزین blur (سبک و بهینه) ---
          if (systemBottomPadding > 0)
            Container(
              height: systemBottomPadding,
              color: cardColor, // 👈 استفاده از رنگ ثابت به جای blur
            ),
        ],
      ),
    );
  }

  // آیتم نوار ناوبری
  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    Color activeColor,
    Color? inactiveColor,
  ) {
    final bool isSelected = _selectedTabIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
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
}
