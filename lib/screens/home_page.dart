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

class _HomePageState extends State<HomePage> {
  late final ScrollController _mainScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final VoidCallback _focusListener;

  bool _showSearchLoading = false;
  DateTime? _searchLoadingStartedAt;
  bool _shownLocationDeniedToast = false;
  bool _showAqiGuide = false;

  @override
  void initState() {
    super.initState();
    // چک کردن اینترنت بعد از ساخت ویجت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInternetOnStart();
    });
    _mainScrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

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

        // --- قسمت اصلاح شده: تشخیص رنگ انتخابی کاربر ---
        final buttonColor = store.useSystemColor
            ? colorScheme.primary
            : Color(store.accentColorValue);

        // برای رنگ متن دکمه، اگر کاستوم بود سفید می‌گذاریم، اگر سیستم بود از تم می‌گیریم
        final buttonTextColor = store.useSystemColor
            ? colorScheme.onPrimary
            : Colors.white;
        // -----------------------------------------------

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
            duration: const Duration(
              seconds: 10,
            ), // زمان را کمی بیشتر کردم تا کاربر ببیند
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // گردی گوشه خود اسنک‌بار
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
                    // دکمه اول: دیگر نشان نده
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
                    // دکمه دوم: درخواست مجدد
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
                    // --- بخش تکراری حذف شد ---
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

                      const SizedBox(height: 120), // Safe bottom space
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
      child: SizedBox(
        width: math.min(MediaQuery.of(context).size.width * 0.9, 720.0),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            store.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    if (store.location.isEmpty && !store.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Text(
            l10n.startBySearching,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
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
        if (store.showAirQuality) ...[
          const SizedBox(height: 16),
          _buildAirQualitySection(context, store, l10n),
        ],
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

    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: math.min(MediaQuery.of(context).size.width, 900.0),
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
                    if (store.weatherType != WeatherType.unknown)
                      SvgPicture.asset(
                        weatherIconAsset(
                          weatherTypeToApiName(store.weatherType),
                        ),
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          iconColor ?? Colors.white,
                          BlendMode.srcIn,
                        ),
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

  Widget _buildAirQualitySection(
    BuildContext context,
    WeatherStore store,
    AppLocalizations l10n,
  ) {
    final aqi = store.airQualityIndex ?? 0;
    final status = labelForAqi(aqi, l10n);
    final severityColor = statusColorForAqi(aqi);
    final progress = (aqi / 500.0).clamp(0.0, 1.0);
    final aqiString = l10n.localeName == 'fa'
        ? toPersianDigits('AQI $aqi')
        : 'AQI $aqi';

    final scheme = Theme.of(context).colorScheme;
    final accentColor = scheme.primary;

    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: math.min(MediaQuery.of(context).size.width, 900.0),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _showAqiGuide = !_showAqiGuide),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.air_rounded, color: accentColor, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.airQualityIndex,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: severityColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withAlpha(230),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withAlpha(40),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              aqiString,
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _showAqiGuide
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: scheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.localeName == 'fa'
                                ? toPersianDigits('0')
                                : '0',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          Text(
                            l10n.localeName == 'fa'
                                ? toPersianDigits('500')
                                : '500',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showAqiGuide
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _buildAqiGuideTable(context, l10n),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAqiGuideTable(BuildContext context, AppLocalizations l10n) {
    final aqiRanges = [
      {
        'label': l10n.aqiStatusVeryGood,
        'range': '0 - 25',
        'color': const Color(0xFF00E400),
        'recommendation': l10n.aqiRecommendationNormal,
      },
      {
        'label': l10n.aqiStatusGood,
        'range': '26 - 37',
        'color': const Color(0xFF7CB342),
        'recommendation': l10n.aqiRecommendationCaution,
      },
      {
        'label': l10n.aqiStatusModerate,
        'range': '38 - 50',
        'color': const Color(0xFFFFC107),
        'recommendation': l10n.aqiRecommendationAvoid,
      },
      {
        'label': l10n.aqiStatusPoor,
        'range': '51 - 90',
        'color': const Color(0xFFFF7E00),
        'recommendation': l10n.aqiRecommendationMask,
      },
      {
        'label': l10n.aqiStatusVeryPoor,
        'range': '90+',
        'color': const Color(0xFFFF0000),
        'recommendation': l10n.aqiRecommendationNoActivity,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.airQualityGuide,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...aqiRanges.map((item) {
            final color = item['color'] as Color;
            final label = item['label'] as String;
            final range = l10n.localeName == 'fa'
                ? toPersianDigits(item['range'] as String)
                : item['range'] as String;
            final recommendation = item['recommendation'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(102), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Icon(
                      _getAqiEmoji(color),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                range,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color?.withAlpha(179),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getAqiEmoji(Color color) {
    if (color == const Color(0xFF00E400) || color == const Color(0xFF7CB342)) {
      return Icons.sentiment_very_satisfied;
    } else if (color == const Color(0xFFFFC107)) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }
}

// توابع کمکی که باید به فایل weather_formatters.dart منتقل شوند
String labelForAqi(int aqi, AppLocalizations l10n) {
  if (aqi <= 25) return l10n.aqiStatusVeryGood;
  if (aqi <= 37) return l10n.aqiStatusGood;
  if (aqi <= 50) return l10n.aqiStatusModerate;
  if (aqi <= 90) return l10n.aqiStatusPoor;
  return l10n.aqiStatusVeryPoor;
}
