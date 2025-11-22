import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/screens/about_screen.dart';

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

  static const List<int> _accentColorOptions = [
    0xFF1E88E5,
    0xFF00897B,
    0xFF8E24AA,
    0xFFF4511E,
    0xFF6D4C41,
    0xFF3949AB,
    0xFFFFB300,
    0xFF546E7A,
    0xFFD81B60,
    0xFF43A047,
    0xFF039BE5,
    0xFFFF7043,
  ];

  void _showLanguageDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(l10n.language),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageOptionTile(
                flag: '🇮🇷',
                label: l10n.persian,
                isSelected: l10n.localeName == 'fa',
                onTap: () {
                  widget.onLocaleChanged(const Locale('fa'));
                  Navigator.pop(context);
                },
              ),
              _LanguageOptionTile(
                flag: '🇬🇧',
                label: l10n.english,
                isSelected: l10n.localeName == 'en',
                onTap: () {
                  widget.onLocaleChanged(const Locale('en'));
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
    final store = context.watch<WeatherStore>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
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
                // ---------------- LANGUAGE ----------------
                _buildSectionTitle(l10n.language),
                _buildSectionCard(
                  context,
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(l10n.language),
                    subtitle: Text(l10n.localeName == 'fa' ? l10n.persian : l10n.english),
                    onTap: () => _showLanguageDialog(l10n),
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

                // ---------------- SWITCHES ----------------
                _buildSectionTitle(l10n.showHourlyTemperature),
                _buildSectionCard(
                  context,
                  Column(
                    children: [
                      SwitchListTile(
                        title: Text(l10n.showHourlyTemperature),
                        value: store.showHourly,
                        onChanged: (v) => store.updatePreference('showHourly', v),
                      ),
                      SwitchListTile(
                        title: Text(l10n.showAirQuality),
                        value: store.showAirQuality,
                        onChanged: (v) => store.updatePreference('showAirQuality', v),
                      ),
                      SwitchListTile(
                        title: Text(l10n.temperatureUnitCelsius),
                        subtitle: Text(l10n.celsiusFahrenheit),
                        value: store.useCelsius,
                        onChanged: (v) => store.updatePreference('useCelsius', v),
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
                        title: Text(l10n.setCurrentCityAsDefault),
                        subtitle: Text(l10n.currentCity(store.location)),
                        trailing: const Icon(Icons.push_pin_outlined),
                        onTap: () {
                          store.updatePreference('defaultCity', store.location);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.defaultCitySetTo(store.location))),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: Text(l10n.goToDefaultCity),
                        subtitle: Text(l10n.currentDefault(store.defaultCity)),
                        trailing: const Icon(Icons.location_city_outlined),
                        onTap: () async {
                          await store.goToDefaultCity();
                          widget.onGoToDefaultCity();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- ADVANCED ----------------
                _buildSectionTitle(l10n.advancedSettings),
                _buildSectionCard(
                  context,
                  ExpansionTile(
                    title: Text(l10n.advancedSettings),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.useSystemColor),
                        subtitle: WeatherStore.systemColorAvailable
                            ? Text(l10n.useSystemColorDescription)
                            : Text(
                          l10n.systemColorNotAvailable,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error.withOpacity(0.8),
                          ),
                        ),
                        value: store.useSystemColor,
                        onChanged: WeatherStore.systemColorAvailable
                            ? (v) => store.updatePreference('useSystemColor', v)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildAccentPicker(store, l10n),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- RECENT SEARCHES ----------------
                _buildSectionTitle(l10n.recentSearches),
                _buildSectionCard(
                  context,
                  ExpansionTile(
                    title: Text(l10n.recentSearches),
                    childrenPadding: const EdgeInsets.all(16),
                    children: [
                      if (store.recentSearches.isEmpty)
                        ListTile(title: Text(l10n.nothingFound))
                      else ...[
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: store.recentSearches.length,
                            itemBuilder: (context, i) => Dismissible(
                              key: ValueKey(store.recentSearches[i]),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) => store.removeRecentAt(i),
                              child: ListTile(
                                title: Text(store.recentSearches[i]),
                                onTap: () async {
                                  await store.searchAndFetchByCityName(store.recentSearches[i]);
                                  widget.onGoToRecentCity();
                                },
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: Text(l10n.clearAll),
                          trailing: const Icon(Icons.cleaning_services_outlined, color: Colors.redAccent),
                          onTap: store.clearRecentSearches,
                        ),
                      ],
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
                        theme.scaffoldBackgroundColor.withOpacity(0),
                        theme.scaffoldBackgroundColor.withOpacity(0.5),
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
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
          color: textTheme.bodyMedium?.color?.withOpacity(0.85),
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
      onPressed: (i) => widget.onThemeChanged([ThemeMode.system, ThemeMode.light, ThemeMode.dark][i]),
      borderRadius: BorderRadius.circular(20),
      constraints: const BoxConstraints(minHeight: 40, minWidth: 90),
      fillColor: theme.colorScheme.primary.withOpacity(0.12),
      selectedColor: theme.colorScheme.primary,
      borderColor: theme.dividerColor.withOpacity(0.4),
      children: [
        Row(children: [const Icon(Icons.phone_iphone), const SizedBox(width: 6), Text(l10n.system)]),
        Row(children: [const Icon(Icons.light_mode), const SizedBox(width: 6), Text(l10n.light)]),
        Row(children: [const Icon(Icons.dark_mode), const SizedBox(width: 6), Text(l10n.dark)]),
      ],
    );
  }

  Widget _buildAccentPicker(WeatherStore store, AppLocalizations l10n) {
    final disabled = store.useSystemColor;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.themeAccentColor, style: textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          l10n.customizeThemeDescription,
          style: textTheme.bodySmall?.copyWith(
            color: textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),

        IgnorePointer(
          ignoring: disabled,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: disabled ? 0.3 : 1,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accentColorOptions.map((v) {
                final color = Color(v);
                final selected = store.accentColorValue == v;
                return _AccentColorDot(
                  color: color,
                  isSelected: selected && !disabled,
                  onTap: () => store.setAccentColor(v),
                );
              }).toList(),
            ),
          ),
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
      trailing: isSelected ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
      onTap: onTap,
    );
  }
}

class _AccentColorDot extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccentColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isSelected ? 40 : 34,
      width: isSelected ? 40 : 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
        ),
      ),
    );
  }
}
