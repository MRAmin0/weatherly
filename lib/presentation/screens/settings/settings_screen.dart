import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/presentation/screens/about/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/presentation/widgets/common/app_background.dart';

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
        title: Text(
          l10n.settings,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🔹 پس‌زمینه مشترک
          AppBackground(color: vm.userBackgroundColor, blur: vm.useBlur),

          NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              setState(() {});
              return false;
            },
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 160,
              ),
              children: [
                // LANGUAGE
                _buildSectionTitle(context, l10n.language, textColor),
                _buildSectionCard(
                  context,
                  ListTile(
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
                _buildSectionCard(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: _buildThemeModeSelector(
                      context,
                      l10n,
                      vm,
                      textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // THEME COLOR
                _buildSectionTitle(context, l10n.themeColor, textColor),
                _buildSectionCard(
                  context,
                  Column(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.chooseStaticColor,
                                  style: TextStyle(color: subTextColor),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _seedColorOptions.map((color) {
                                    final isSelected =
                                        vm.seedColor.toARGB32() ==
                                        color.toARGB32();
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
                              ],
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
                _buildSectionCard(
                  context,
                  SwitchListTile(
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

                // ABOUT
                _buildSectionTitle(context, l10n.aboutApp, textColor),
                _buildSectionCard(
                  context,
                  ListTile(
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

  Widget _buildSectionCard(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: child,
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
