import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/screens/about_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onGoToRecentCity;

  const SettingsScreen({super.key, required this.onGoToRecentCity});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _scrollOffset = 0;
  double _maxScroll = 0;

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
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.65),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
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
              Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vm = context.watch<WeatherViewModel>();

    const textColor = Colors.white;
    final subTextColor = Colors.white.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
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
                // --- LANGUAGE ---
                _buildSectionTitle(context, l10n.language, textColor),
                _buildSectionCard(
                  context,
                  ListTile(
                    leading: const Icon(
                      Icons.language_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.language,
                      style: const TextStyle(color: textColor),
                    ),
                    subtitle: Text(
                      vm.lang == 'fa' ? l10n.persian : l10n.english,
                      style: TextStyle(color: subTextColor),
                    ),
                    onTap: () => _showLanguageDialog(l10n, vm),
                  ),
                ),
                const SizedBox(height: 24),

                // --- DISPLAY MODE ---
                _buildSectionTitle(context, l10n.displayMode, textColor),
                _buildSectionCard(
                  context,
                  Padding(
                    padding: const EdgeInsets.all(14),
                    // FIX: پارامتر textColor اضافه شد
                    child: Center(
                      child: _buildThemeModeSelector(
                        context,
                        l10n,
                        vm,
                        textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- THEME COLOR ---
                _buildSectionTitle(context, l10n.themeColor, textColor),
                _buildSectionCard(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        title: Text(
                          l10n.useSystemColor,
                          style: const TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          l10n.systemColorSubtitle,
                          style: TextStyle(color: subTextColor),
                        ),
                        value: vm.useSystemColor,
                        onChanged: (val) => vm.setUseSystemColor(val),
                        // FIX: استفاده از activeThumbColor به جای activeColor
                        activeThumbColor: Colors.white,
                        activeTrackColor: theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
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
                                    color: subTextColor,
                                  ),
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

                // --- UNITS ---
                _buildSectionTitle(
                  context,
                  l10n.temperatureUnitCelsius,
                  textColor,
                ),
                _buildSectionCard(
                  context,
                  Column(
                    children: [
                      SwitchListTile(
                        title: Text(
                          l10n.temperatureUnitCelsius,
                          style: const TextStyle(color: textColor),
                        ),
                        subtitle: Text(
                          l10n.celsiusFahrenheit,
                          style: TextStyle(color: subTextColor),
                        ),
                        value: vm.useCelsius,
                        onChanged: (v) => vm.setUseCelsius(v),
                        // FIX: استفاده از activeThumbColor به جای activeColor
                        activeThumbColor: Colors.white,
                        activeTrackColor: theme.colorScheme.primary.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- ABOUT ---
                _buildSectionTitle(context, l10n.aboutApp, textColor),
                _buildSectionCard(
                  context,
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    title: Text(
                      l10n.aboutApp,
                      style: const TextStyle(color: textColor),
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
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
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

  Widget _buildSectionCard(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    Color textColor,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 6),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector(
    BuildContext context,
    AppLocalizations l10n,
    WeatherViewModel vm,
    Color textColor,
  ) {
    final selected = [
      vm.themeMode == ThemeMode.system,
      vm.themeMode == ThemeMode.light,
      vm.themeMode == ThemeMode.dark,
    ];

    return ToggleButtons(
      isSelected: selected,
      onPressed: (i) {
        final mode = [ThemeMode.system, ThemeMode.light, ThemeMode.dark][i];
        vm.setThemeMode(mode);
        // FIX: اضافه کردن آکولاد برای رفع وارنینگ
        if (mode == ThemeMode.system) {
          vm.setUseSystemColor(true);
        } else {
          vm.setUseSystemColor(false);
        }
      },
      borderRadius: BorderRadius.circular(20),
      constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
      fillColor: Colors.white.withValues(alpha: 0.3),
      selectedColor: Colors.white,
      color: Colors.white.withValues(alpha: 0.6),
      borderColor: Colors.white.withValues(alpha: 0.3),
      selectedBorderColor: Colors.white.withValues(alpha: 0.5),
      children: [
        Row(
          children: [
            const Icon(Icons.phone_iphone, size: 18),
            const SizedBox(width: 6),
            Text(l10n.system),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.light_mode, size: 18),
            const SizedBox(width: 6),
            Text(l10n.light),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.dark_mode, size: 18),
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
    final color = textColor ?? theme.textTheme.bodyMedium?.color;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
