import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/weather_store.dart';
import 'package:weatherly_app/screens/about_screen.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';

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
  static const List<int> _accentColorOptions = [
    0xFF1E88E5, // Blue
    0xFF00897B, // Teal
    0xFF8E24AA, // Purple
    0xFFF4511E, // Deep Orange
    0xFF6D4C41, // Brown
    0xFF3949AB, // Indigo
    0xFFFFB300, // Amber
    0xFF546E7A, // Blue Grey
    0xFFD81B60, // Pink
    0xFF43A047, // Green
    0xFF039BE5, // Light Blue
    0xFFFF7043, // Orange
  ];
  void _showLanguageDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                  Navigator.of(context).pop();
                },
              ),
              _LanguageOptionTile(
                flag: '🇬🇧',
                label: l10n.english,
                isSelected: l10n.localeName == 'en',
                onTap: () {
                  widget.onLocaleChanged(const Locale('en'));
                  Navigator.of(context).pop();
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.language),
              subtitle: Text(
                l10n.localeName == 'fa' ? l10n.persian : l10n.english,
              ),
              onTap: () => _showLanguageDialog(l10n),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.displayMode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(height: 24),
                Center(
                  child: ToggleButtons(
                    isSelected: [
                      widget.currentThemeMode == ThemeMode.system,
                      widget.currentThemeMode == ThemeMode.light,
                      widget.currentThemeMode == ThemeMode.dark,
                    ],
                    onPressed: (index) =>
                        widget.onThemeChanged(ThemeMode.values[index]),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      minWidth: 56,
                    ),
                    children: [
                      Tooltip(
                        message: l10n.system,
                        child: const Icon(Icons.phone_iphone),
                      ),
                      Tooltip(
                        message: l10n.light,
                        child: const Icon(Icons.light_mode),
                      ),
                      Tooltip(
                        message: l10n.dark,
                        child: const Icon(Icons.dark_mode),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.showHourlyTemperature),
                  value: store.showHourly,
                  onChanged: (val) => store.updatePreference('showHourly', val),
                ),
                SwitchListTile(
                  title: Text(l10n.showAirQuality),
                  value: store.showAirQuality,
                  onChanged: (val) =>
                      store.updatePreference('showAirQuality', val),
                ),
                SwitchListTile(
                  title: Text(l10n.temperatureUnitCelsius),
                  subtitle: Text(l10n.celsiusFahrenheit),
                  value: store.useCelsius,
                  onChanged: (val) => store.updatePreference('useCelsius', val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                  child: Text(
                    l10n.defaultCity,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(),
                ListTile(
                  title: Text(l10n.setCurrentCityAsDefault),
                  subtitle: Text(l10n.currentCity(store.location)),
                  trailing: const Icon(Icons.push_pin_outlined),
                  onTap: () {
                    store.updatePreference('defaultCity', store.location);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.defaultCitySetTo(store.location)),
                      ),
                    );
                  },
                ),
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
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(l10n.advancedSettings),
              childrenPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.useSystemColor),
                  subtitle: WeatherStore.systemColorAvailable
                      ? Text(l10n.useSystemColorDescription)
                      : Text(
                          l10n.systemColorNotAvailable,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withAlpha(200),
                              ),
                        ),
                  value: store.useSystemColor,
                  onChanged: WeatherStore.systemColorAvailable
                      ? (val) => store.updatePreference('useSystemColor', val)
                      : null,
                ),
                const SizedBox(height: 12),
                _buildAccentPicker(store, l10n),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(l10n.recentSearches),
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
                        key: ValueKey('recent_${i}_${store.recentSearches[i]}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => store.removeRecentAt(i),
                        child: ListTile(
                          title: Text(store.recentSearches[i]),
                          onTap: () async {
                            await store.searchAndFetchByCityName(
                              store.recentSearches[i],
                            );
                            widget.onGoToRecentCity();
                          },
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: Text(l10n.clearAll),
                    trailing: const Icon(
                      Icons.cleaning_services_outlined,
                      color: Colors.redAccent,
                    ),
                    onTap: store.clearRecentSearches,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.aboutApp),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentPicker(WeatherStore store, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final disabled = store.useSystemColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.themeAccentColor, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l10n.customizeThemeDescription,
          style: textTheme.bodySmall?.copyWith(
            color: textTheme.bodySmall?.color?.withAlpha(180),
          ),
        ),
        const SizedBox(height: 16),
        IgnorePointer(
          ignoring: disabled,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: disabled ? 0.35 : 1,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accentColorOptions.map((value) {
                final color = Color(value);
                final isSelected = store.accentColorValue == value;
                return _AccentColorDot(
                  color: color,
                  isSelected: isSelected && !disabled,
                  onTap: () => store.setAccentColor(value),
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
  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Text(flag, style: textTheme.headlineSmall),
      title: Text(label, style: textTheme.titleMedium),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _AccentColorDot extends StatelessWidget {
  const _AccentColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: isSelected ? 42 : 36,
      width: isSelected ? 42 : 36,
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
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
