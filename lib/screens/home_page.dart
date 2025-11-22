import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/models/weather_models.dart';
import 'package:weatherly_app/services/network_service.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/weather_store.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onSearchFocusChange;

  const HomePage({super.key, required this.onSearchFocusChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final ScrollController _mainScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final VoidCallback _focusListener;

  late final AnimationController _sunController;

  bool _showSearchLoading = false;
  DateTime? _searchLoadingStartedAt;
  bool _shownLocationDeniedToast = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInternetOnStart();
    });
    _mainScrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _sunController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _focusListener = () {
      widget.onSearchFocusChange(_searchFocusNode.hasFocus);
      if (mounted) {
        setState(() {});
      }
    };
    _searchFocusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.removeListener(_focusListener);
    _searchFocusNode.dispose();
    _sunController.dispose();
    super.dispose();
  }

  void checkInternetOnStart() async {
    final online = await NetworkService.hasInternet();
    if (!online) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("عدم اتصال به اینترنت"),
          content: Text(
            "برای استفاده از برنامه، اتصال اینترنت خود را بررسی کنید.",
          ),
        ),
      );
    }
  }

  Future<void> _performSearch(WeatherStore store) async {
    FocusScope.of(context).unfocus();
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _showSearchLoading = true;
      _searchLoadingStartedAt = DateTime.now();
    });

    await store.searchAndFetchByCityName(query);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<WeatherStore>();
    final l10n = AppLocalizations.of(context)!;

    if (store.locationPermissionDenied &&
        !_shownLocationDeniedToast &&
        !store.hideLocationPermissionPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() => _shownLocationDeniedToast = true);
        final messenger = ScaffoldMessenger.of(context);
        final colorScheme = Theme.of(context).colorScheme;

        final buttonColor = store.useSystemColor
            ? colorScheme.primary
            : Color(store.accentColorValue);

        final buttonTextColor = store.useSystemColor
            ? colorScheme.onPrimary
            : Colors.white;

        final snackWidth = math.min(
          MediaQuery.of(context).size.width * 0.9,
          360.0,
        );
        final snackBackground = colorScheme.surfaceContainerHighest;
        final snackTextColor = colorScheme.onSurfaceVariant;
        messenger.showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: snackWidth,
            backgroundColor: snackBackground,
            duration: const Duration(seconds: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationPermissionDenied,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: snackTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: buttonTextColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        onPressed: () async {
                          await store.setHideLocationPermissionPrompt(true);
                          messenger.hideCurrentSnackBar();
                        },
                        child: Text(l10n.dontShowAgain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          store.fetchByCurrentLocation();
                          messenger.hideCurrentSnackBar();
                        },
                        child: Text(l10n.requestAgain),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    }
    if (!store.locationPermissionDenied && _shownLocationDeniedToast) {
      setState(() => _shownLocationDeniedToast = false);
    }
    if (_showSearchLoading && !store.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        const minMs = 1200;
        final started = _searchLoadingStartedAt ?? DateTime.now();
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        final remain = (minMs - elapsed).clamp(0, minMs);
        if (remain > 0) {
          await Future.delayed(Duration(milliseconds: remain));
        }
        if (context.mounted) {
          setState(() => _showSearchLoading = false);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.weatherly)),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: store.handleRefresh,
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: _searchFocusNode.hasFocus
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildSearchSection(context, store, l10n),

                      if (!_searchFocusNode.hasFocus) ...[
                        const SizedBox(height: 24),
                        if (store.isLoading && store.location.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          _buildWeatherContent(context, store, l10n),
                      ],

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showSearchLoading)
            Container(
              color: Colors.black.withAlpha(89),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 12),
                      const CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2.5,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.searching,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      ) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final subtitleColor = textColor?.withAlpha(179);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              maxLength: 30,
              onChanged: store.onSearchChanged,
              textInputAction: TextInputAction.search,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[ء-يآ-یa-zA-Z\s]')),
              ],
              textAlign: l10n.localeName == 'fa'
                  ? TextAlign.right
                  : TextAlign.left,
              decoration: InputDecoration(
                hintText: l10n.enterCityName,
                counterText: "",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withAlpha(180),
                    width: 1.4,
                  ),
                ),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(store),
                ),
              ),
              onSubmitted: (_) => _performSearch(store),
            ),
            const SizedBox(height: 8),
            if (store.suggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: store.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = store.suggestions[index];
                      final name = store.currentLang == 'fa'
                          ? (suggestion['local_names']?['fa'] ??
                          suggestion['name'] ??
                          l10n.unknown)
                          .toString()
                          : (suggestion['name'] ?? l10n.unknown).toString();
                      final country = (suggestion['country'] ?? '').toString();
                      final state = (suggestion['state'] ?? '').toString();
                      final subtitle = [
                        if (state.isNotEmpty && state != name) state,
                        if (country.isNotEmpty) country,
                      ].join(' • ');

                      return ListTile(
                        title: Text(name, style: TextStyle(color: textColor)),
                        subtitle: Text(
                          subtitle,
                          style: TextStyle(color: subtitleColor),
                        ),
                        onTap: () {
                          store.selectCity(suggestion);
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (store.recentSearches.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.recentSearches,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: store.clearRecentSearches,
                          child: Text(
                            l10n.clear,
                            style: TextStyle(color: subtitleColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < store.recentSearches.length; i++)
                          InputChip(
                            label: Text(
                              store.recentSearches[i],
                              style: TextStyle(color: textColor),
                            ),
                            backgroundColor: isDark
                                ? Colors.white.withAlpha(31)
                                : Colors.black.withAlpha(20),
                            onPressed: () {
                              store.searchAndFetchByCityName(
                                store.recentSearches[i],
                              );
                              FocusScope.of(context).unfocus();
                            },
                            onDeleted: () => store.removeRecentAt(i),
                            deleteIconColor: subtitleColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      ) {
    if (store.errorMessage != null) {
      return Center(child: Text(store.errorMessage!));
    }
    if (store.location.isEmpty && !store.isLoading) {
      return Center(child: Text(l10n.startBySearching));
    }
    if (store.location.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildCurrentWeatherSection(context, store, l10n),
        const SizedBox(height: 16),
        _buildDetailsRow(context, store, l10n),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCurrentWeatherSection(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      ) {
    final tempC = store.temperature;
    final temp = store.useCelsius
        ? tempC
        : (tempC != null ? (tempC * 9 / 5) + 32 : null);
    final unitSymbol = store.useCelsius ? '°C' : '°F';
    final tempString = temp?.toStringAsFixed(0) ?? '--';

    final textTheme = Theme.of(context).textTheme;
    final iconColor = textTheme.bodyMedium?.color?.withAlpha(204);

    final isClear = store.weatherType == WeatherType.clear;

    return RepaintBoundary(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  l10n.localeName == 'fa'
                      ? toPersianDigits('$tempString$unitSymbol')
                      : '$tempString$unitSymbol',
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 64,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  store.location,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // اینجا اگر نوع هوا مشخص بود (حتی ریزگرد)، آیکون نمایش داده می‌شود
                    if (store.weatherType != WeatherType.unknown)
                      isClear
                          ? RotationTransition(
                        turns: _sunController,
                        child: SvgPicture.asset(
                          weatherIconAsset(
                            weatherTypeToApiName(store.weatherType),
                          ),
                          width: 42, // آیکون بزرگتر شد (سایز ایموجی)
                          height: 42,
                        ),
                      )
                          : SvgPicture.asset(
                        weatherIconAsset(
                          weatherTypeToApiName(store.weatherType),
                        ),
                        width: 42, // آیکون بزرگتر شد
                        height: 42,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      store.weatherDescription,
                      style: textTheme.titleLarge?.copyWith(color: iconColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsRow(
      BuildContext context,
      WeatherStore store,
      AppLocalizations l10n,
      ) {
    final aqi = store.airQualityIndex ?? 0;
    final aqiColor = statusColorForAqi(aqi);
    final aqiText = labelForAqi(aqi, l10n);

    final humidity = l10n.localeName == 'fa'
        ? toPersianDigits("${store.humidity}%")
        : "${store.humidity}%";

    final windVal = store.windSpeed.toStringAsFixed(1);
    final windUnit = l10n.localeName == 'fa' ? "کیلومتر/ساعت" : "km/h";

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // کارت ۱ (سمت راست در فارسی): کیفیت هوا
            Expanded(
              child: _buildDetailItem(
                context,
                icon: Icons.air,
                iconColor: aqiColor,
                title: l10n.airQualityIndex,
                value: l10n.localeName == 'fa' ? toPersianDigits('$aqi') : '$aqi',
                footer: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: aqiColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    aqiText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: aqiColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // کارت ۲ (وسط): باد
            Expanded(
              child: _buildDetailItem(
                context,
                icon: Icons.wind_power,
                iconColor: Colors.blueAccent,
                title: l10n.localeName == 'fa' ? "باد" : "Wind",
                value: l10n.localeName == 'fa' ? toPersianDigits(windVal) : windVal,
                footer: Text(
                  windUnit,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(150),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // کارت ۳ (چپ در فارسی): رطوبت
            Expanded(
              child: _buildDetailItem(
                context,
                icon: Icons.water_drop_outlined,
                iconColor: Colors.lightBlue,
                title: l10n.localeName == 'fa' ? "رطوبت" : "Humidity",
                value: humidity,
                footer: const SizedBox(height: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String value,
        required Widget footer,
      }) {
    final theme = Theme.of(context);
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withAlpha(15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 6),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(130),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 26,
                height: 1.0,
              ),
            ),
          ),
          SizedBox(
            height: 24,
            child: Center(child: footer),
          ),
        ],
      ),
    );
  }
}