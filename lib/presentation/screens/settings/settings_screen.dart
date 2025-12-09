import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/presentation/screens/about/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/common/app_background.dart';
import 'package:weatherly_app/presentation/widgets/common/glass_container.dart';
import 'package:weatherly_app/data/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onGoToRecentCity;

  const SettingsScreen({super.key, required this.onGoToRecentCity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<Color> _seedColorOptions = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.lime,
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.pink,
    Color(0xFF6750A4),
    Color(0xFF006C4C),
  ];

  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = (1.0 - (offset / 100)).clamp(0.0, 1.0);
    if (newOpacity != _titleOpacity) {
      setState(() {
        _titleOpacity = newOpacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(AppLocalizations l10n, WeatherViewModel vm) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AlertDialog(
            backgroundColor: Colors.black.withValues(alpha: 0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
                Divider(color: Colors.white.withValues(alpha: 0.2)),
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
          ),
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
      initialEntryMode:
          TimePickerEntryMode.dial, // Shows both input fields and clock dial
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await vm.setDailyNotificationTime(picked.hour, picked.minute);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vm.lang == 'fa'
                  ? 'هشدار صبحگاهی روی ${_formatTime(picked.hour, picked.minute)} تنظیم شد'
                  : 'Daily alert set for ${_formatTime(picked.hour, picked.minute)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _testDailyNotification(
    BuildContext context,
    WeatherViewModel vm,
  ) async {
    // Show snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          vm.lang == 'fa'
              ? '✅ نوتیفیکیشن تست ارسال شد!'
              : '✅ Test notification sent!',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Initialize and request permission first
    final notificationService = NotificationService();
    await notificationService.initialize();
    final hasPermission = await notificationService.requestPermission();

    if (!hasPermission) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              vm.lang == 'fa'
                  ? '⚠️ لطفاً دسترسی نوتیفیکیشن را فعال کنید'
                  : '⚠️ Please enable notification permission',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show test notification
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
    final theme = Theme.of(context);
    final vm = context.watch<WeatherViewModel>();

    final textColor = theme.colorScheme.onSurface;
    final subTextColor = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.85,
        ),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _titleOpacity,
          child: Text(
            l10n.settings,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const AppBackground(),

          NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              setState(() {});
              return false;
            },
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 160,
              ),
              children: [
                // LANGUAGE
                _buildSectionTitle(context, l10n.language, textColor),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(
                      l10n.language,
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      vm.lang == 'fa' ? l10n.persian : l10n.english,
                      style: TextStyle(color: subTextColor),
                    ),
                    onTap: () => _showLanguageDialog(l10n, vm),
                  ),
                ),
                const SizedBox(height: 24),

                // DISPLAY MODE
                _buildSectionTitle(context, l10n.displayMode, textColor),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  child: _buildThemeModeSelector(context, l10n, vm, textColor),
                ),
                const SizedBox(height: 24),

                // THEME COLOR
                _buildSectionTitle(context, l10n.themeColor, textColor),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: Text(
                          l10n.useSystemColor,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          l10n.systemColorSubtitle,
                          style: TextStyle(color: subTextColor),
                        ),
                        value: vm.useSystemColor,
                        onChanged: (val) => vm.setUseSystemColor(val),
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: vm.useSystemColor ? 0.35 : 1.0,
                        child: IgnorePointer(
                          ignoring: vm.useSystemColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _seedColorOptions.map((color) {
                                final isSelected =
                                    vm.seedColor.toARGB32() == color.toARGB32();
                                return GestureDetector(
                                  onTap: () => vm.setSeedColor(color),
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 2.5,
                                            )
                                          : null,
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // UNITS
                _buildSectionTitle(
                  context,
                  l10n.temperatureUnitCelsius,
                  textColor,
                ),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: Text(
                      l10n.temperatureUnitCelsius,
                      style: TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      l10n.celsiusFahrenheit,
                      style: TextStyle(color: subTextColor),
                    ),
                    value: vm.useCelsius,
                    onChanged: vm.setUseCelsius,
                  ),
                ),
                const SizedBox(height: 24),

                // NOTIFICATIONS
                _buildSectionTitle(context, l10n.smartNotifications, textColor),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile(
                        secondary: const Icon(
                          Icons.notifications_active_outlined,
                        ),
                        title: Text(
                          l10n.smartNotifications,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          l10n.smartNotificationsDesc,
                          style: TextStyle(color: subTextColor),
                        ),
                        value: vm.smartNotificationsEnabled,
                        onChanged: vm.setSmartNotifications,
                      ),
                      Divider(height: 1, indent: 16, endIndent: 16),
                      SwitchListTile(
                        secondary: const Icon(Icons.alarm_outlined),
                        title: Text(
                          l10n.dailyNotifications,
                          style: TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          vm.lang == 'fa'
                              ? 'هر روز ساعت ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)} خلاصه آب‌وهوا'
                              : 'Daily summary at ${_formatTime(vm.dailyNotificationHour, vm.dailyNotificationMinute)}',
                          style: TextStyle(color: subTextColor),
                        ),
                        value: vm.dailyNotificationsEnabled,
                        onChanged: vm.setDailyNotifications,
                      ),
                      // Time picker - only show when daily notifications are enabled
                      if (vm.dailyNotificationsEnabled) ...[
                        Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.schedule_outlined),
                          title: Text(
                            l10n.notificationTimeLabel,
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            _formatTime(
                              vm.dailyNotificationHour,
                              vm.dailyNotificationMinute,
                            ),
                            style: TextStyle(color: subTextColor),
                          ),
                          trailing: Icon(
                            Icons.edit_outlined,
                            color: subTextColor,
                          ),
                          onTap: () => _showTimePicker(context, vm),
                        ),
                        Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.play_arrow_outlined),
                          title: Text(
                            vm.lang == 'fa'
                                ? 'تست نوتیفیکیشن'
                                : 'Test Notification',
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: Text(
                            vm.lang == 'fa'
                                ? 'ببین نوتیف چطوری نشون داده میشه'
                                : 'See how the notification looks',
                            style: TextStyle(color: subTextColor),
                          ),
                          onTap: () => _testDailyNotification(context, vm),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ABOUT
                _buildSectionTitle(context, l10n.aboutApp, textColor),
                GlassContainer(
                  isDark: theme.brightness == Brightness.dark,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(
                      l10n.aboutApp,
                      style: TextStyle(color: textColor),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: subTextColor,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    AppLocalizations l10n,
    WeatherViewModel vm,
    Color textColor,
  ) {
    final theme = Theme.of(context);

    return SegmentedButton<ThemeMode>(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return theme.colorScheme.primary.withValues(alpha: 0.25);
          }
          return theme.colorScheme.surfaceContainerHighest;
        }),
        foregroundColor: WidgetStatePropertyAll(textColor),
        side: WidgetStatePropertyAll(BorderSide(color: theme.dividerColor)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text(l10n.system),
          icon: const Icon(Icons.phone_iphone),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(l10n.light),
          icon: const Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text(l10n.dark),
          icon: const Icon(Icons.dark_mode),
        ),
      ],
      selected: {vm.themeMode},
      onSelectionChanged: (v) async {
        final mode = v.first;
        await vm.setThemeMode(mode);
        await vm.setUseSystemColor(mode == ThemeMode.system);
      },
      showSelectedIcon: false,
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 6),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor.withValues(alpha: 0.9),
          fontWeight: FontWeight.bold,
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
    final theme = Theme.of(context);
    final color = textColor ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(color: color),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.white)
          : null,
      onTap: onTap,
    );
  }
}
