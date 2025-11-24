// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/screens/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLocaleChanged;
  final VoidCallback onGoToDefaultCity;
  final VoidCallback onGoToRecentCity;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.onGoToDefaultCity,
    required this.onGoToRecentCity,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _scrollOffset = 0;
  double _maxScroll = 0;

  // Material 3 Seed Colors
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
    Color(0xFF6750A4), // M3 Baseline Purple
    Color(0xFF006C4C), // M3 Baseline Green
  ];

  void _showLanguageDialog(AppLocalizations l10n, WeatherViewModel vm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOptionTile(
                flag: '🇮🇷',
                label: l10n.persian,
                isSelected: vm.lang == 'fa',
                onTap: () {
                  widget.onLocaleChanged(const Locale('fa'));
                  vm.setLang('fa');
                  Navigator.pop(context);
                },
              ),
              _LanguageOptionTile(
                flag: '🇬🇧',
                label: l10n.english,
                isSelected: vm.lang == 'en',
                onTap: () {
                  widget.onLocaleChanged(const Locale('en'));
                  vm.setLang('en');
                  Navigator.pop(context);
                },
              ),
            ],
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings), centerTitle: true),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notif) {
              setState(() {
                _scrollOffset = notif.metrics.pixels;
                _maxScroll = notif.metrics.maxScrollExtent;
              });
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
                // ---------------- LANGUAGE ----------------
                _buildSectionTitle(l10n.language),
                _buildSectionCard(
                  context,
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.language),
                    subtitle: Text(
                      vm.lang == 'fa' ? l10n.persian : l10n.english,
                    ),
                    onTap: () => _showLanguageDialog(l10n, vm),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- THEME MODE ----------------
                _buildSectionTitle(l10n.displayMode),
                _buildSectionCard(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: _buildThemeModeSelector(l10n),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- THEME COLOR ----------------
                _buildSectionTitle(l10n.themeColor),
                _buildSectionCard(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. System Color Toggle
                      SwitchListTile(
                        title: Text(l10n.useSystemColor),
                        subtitle: Text(l10n.systemColorSubtitle),
                        value: vm.useSystemColor,
                        onChanged: (val) => vm.setUseSystemColor(val),
                      ),

                      const Divider(height: 1, indent: 16, endIndent: 16),

                      // 2. Static Color Picker
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: vm.useSystemColor ? 0.4 : 1.0,
                        child: IgnorePointer(
                          ignoring: vm.useSystemColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.chooseStaticColor,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _seedColorOptions.map((color) {
                                    // --- FIX IS HERE: Use toARGB32() ---
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
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                  width: 2.5,
                                                )
                                              : null,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.15,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
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

                // ---------------- UNITS ----------------
                _buildSectionTitle(l10n.temperatureUnitCelsius),
                _buildSectionCard(
                  context,
                  Column(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.temperatureUnitCelsius),
                        subtitle: Text(l10n.celsiusFahrenheit),
                        value: vm.useCelsius,
                        onChanged: (v) => vm.setUseCelsius(v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- DEFAULT CITY ----------------
                _buildSectionTitle(l10n.defaultCity),
                _buildSectionCard(
                  context,
                  Column(
                    children: [
                      ListTile(
                        title: Text(l10n.goToDefaultCity),
                        subtitle: Text(l10n.currentDefault(vm.defaultCity)),
                        trailing: const Icon(Icons.location_city_outlined),
                        onTap: () async {
                          await vm.fetchByDefaultCity();
                          widget.onGoToDefaultCity();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- ABOUT ----------------
                _buildSectionTitle(l10n.aboutApp),
                _buildSectionCard(
                  context,
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.aboutApp),
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

          // ============== Fade-out bottom ==============
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: (_scrollOffset + 80 < _maxScroll) ? 1 : 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.scaffoldBackgroundColor.withValues(alpha: 0),
                        theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                        theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS ==================

  Widget _buildSectionCard(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 6),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final selected = [
      widget.currentThemeMode == ThemeMode.system,
      widget.currentThemeMode == ThemeMode.light,
      widget.currentThemeMode == ThemeMode.dark,
    ];

    return ToggleButtons(
      isSelected: selected,
      onPressed: (i) => widget.onThemeChanged(
        [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i],
      ),
      borderRadius: BorderRadius.circular(20),
      constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
      fillColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      selectedColor: theme.colorScheme.primary,
      borderColor: theme.dividerColor.withValues(alpha: 0.4),
      children: [
        Row(
          children: [
            const Icon(Icons.phone_iphone),
            const SizedBox(width: 6),
            Text(l10n.system),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.light_mode),
            const SizedBox(width: 6),
            Text(l10n.light),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.dark_mode),
            const SizedBox(width: 6),
            Text(l10n.dark),
          ],
        ),
      ],
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Text(flag, style: theme.textTheme.headlineSmall),
      title: Text(label, style: theme.textTheme.titleMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
