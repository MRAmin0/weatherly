import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/presentation/screens/about/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/common/glass_container.dart';
import 'package:weatherly_app/data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onGoToRecentCity;

  const SettingsScreen({super.key, required this.onGoToRecentCity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(AppLocalizations l10n, WeatherViewModel vm) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final dialogContent = AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          ),
          title: Text(
            l10n.language,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOptionTile(
                flag: '🇮🇷',
                label: l10n.persian,
                isSelected: vm.lang == 'fa',
                textColor: Colors.white,
                onTap: () {
                  vm.setLang('fa');
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.white.withOpacity(0.1)),
              _LanguageOptionTile(
                flag: '🇬🇧',
                label: l10n.english,
                isSelected: vm.lang == 'en',
                textColor: Colors.white,
                onTap: () {
                  vm.setLang('en');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: dialogContent,
        );
      },
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    WeatherViewModel vm,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: vm.dailyNotificationHour,
        minute: vm.dailyNotificationMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await vm.setDailyNotificationTime(picked.hour, picked.minute);
    }
  }

  Future<void> _testDailyNotification(
    BuildContext context,
    WeatherViewModel vm,
  ) async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    await notificationService.requestPermission();

    final isFarsi = vm.lang == 'fa';
    await notificationService.showWeatherNotification(
      title: isFarsi ? '☀️ هوای امروز' : '☀️ Today\'s Weather',
      body: isFarsi
          ? 'این یک نوتیفیکیشن تستی است!'
          : 'This is a test notification!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<WeatherViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            l10n.settings,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // LANGUAGE
                    _buildSectionTitle(l10n.language),
                    GlassContainer(
                      isDark: true,
                      padding: EdgeInsets.zero,
                      borderRadius: 25,
                      child: ListTile(
                        leading: const Icon(
                          Icons.language_rounded,
                          color: Colors.white,
                        ),
                        title: Text(
                          l10n.language,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          vm.lang == 'fa' ? l10n.persian : l10n.english,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        onTap: () => _showLanguageDialog(l10n, vm),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // THEME
                    _buildSectionTitle(l10n.displayMode),
                    GlassContainer(
                      isDark: true,
                      borderRadius: 25,
                      child: _buildThemeModeSelector(l10n, vm),
                    ),
                    const SizedBox(height: 24),

                    // UNITS
                    _buildSectionTitle(l10n.temperatureUnitCelsius),
                    GlassContainer(
                      isDark: true,
                      padding: EdgeInsets.zero,
                      borderRadius: 25,
                      child: SwitchListTile(
                        title: Text(
                          l10n.temperatureUnitCelsius,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          l10n.celsiusFahrenheit,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        activeThumbColor: Colors.white,
                        value: vm.useCelsius,
                        onChanged: vm.setUseCelsius,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // NOTIFICATIONS
                    _buildSectionTitle(l10n.smartNotifications),
                    GlassContainer(
                      isDark: true,
                      padding: EdgeInsets.zero,
                      borderRadius: 25,
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                            ),
                            title: Text(
                              l10n.smartNotifications,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              l10n.smartNotificationsDesc,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            activeThumbColor: Colors.white,
                            value: vm.smartNotificationsEnabled,
                            onChanged: vm.setSmartNotifications,
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.1)),
                          SwitchListTile(
                            secondary: const Icon(
                              Icons.alarm_rounded,
                              color: Colors.white,
                            ),
                            title: Text(
                              l10n.dailyNotifications,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              vm.lang == 'fa'
                                  ? 'ساعت ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)}'
                                  : 'Daily summary at ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            activeThumbColor: Colors.white,
                            value: vm.dailyNotificationsEnabled,
                            onChanged: vm.setDailyNotifications,
                          ),
                          if (vm.dailyNotificationsEnabled) ...[
                            ListTile(
                              leading: const Icon(
                                Icons.schedule_rounded,
                                color: Colors.white,
                              ),
                              title: Text(
                                l10n.notificationTimeLabel,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                              onTap: () => _showTimePicker(context, vm),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              title: Text(
                                vm.lang == 'fa'
                                    ? 'تست نوتیفیکیشن'
                                    : 'Test Notification',
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () => _testDailyNotification(context, vm),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ABOUT
                    _buildSectionTitle(l10n.aboutApp),
                    GlassContainer(
                      isDark: true,
                      padding: EdgeInsets.zero,
                      borderRadius: 25,
                      child: ListTile(
                        leading: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white,
                        ),
                        title: Text(
                          l10n.aboutApp,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeModeSelector(AppLocalizations l10n, WeatherViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildThemeChip(
            ThemeMode.system,
            l10n.system,
            Icons.brightness_auto_rounded,
            vm,
          ),
          const SizedBox(width: 8),
          _buildThemeChip(
            ThemeMode.light,
            l10n.light,
            Icons.wb_sunny_rounded,
            vm,
          ),
          const SizedBox(width: 8),
          _buildThemeChip(
            ThemeMode.dark,
            l10n.dark,
            Icons.nightlight_round,
            vm,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeChip(
    ThemeMode mode,
    String label,
    IconData icon,
    WeatherViewModel vm,
  ) {
    final isSelected = vm.themeMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          vm.setThemeMode(mode);
          vm.setUseSystemColor(mode == ThemeMode.system);
        }
      },
      avatar: Icon(
        icon,
        color: isSelected ? Colors.black : Colors.white,
        size: 18,
      ),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? textColor;

  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Colors.white)
          : null,
      onTap: onTap,
    );
  }
}
