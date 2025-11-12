import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/utils/weather_formatters.dart';
import 'package:weatherly_app/weather_store.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onSearchFocusChange;

  const HomePage({super.key, required this.onSearchFocusChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 👇 State های محلی (Local State)
  late final ScrollController _mainScrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final VoidCallback _focusListener;

  bool _showSearchLoading = false;
  DateTime? _searchLoadingStartedAt;
  bool _shownLocationDeniedToast = false;

  @override
  void initState() {
    super.initState();
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

    // ... (منطق اسنک‌بار و لودینگ)
    if (store.locationPermissionDenied && !_shownLocationDeniedToast) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        setState(() => _shownLocationDeniedToast = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'دسترسی به موقعیت غیرفعال است. لطفاً دستی سرچ کن یا مجوز را بده.',
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'درخواست دوباره؟',
              onPressed: () {
                store.fetchByCurrentLocation();
              },
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
      appBar: AppBar(title: const Text('هواشناسی')),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: store.handleRefresh,
            child: SingleChildScrollView(
              controller: _mainScrollController,
              // 👇 اگر جستجو فعاله، اسکرول قفل می‌شه
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
                      _buildSearchSection(context, store),

                      // 👇 محتوای اصلی فقط زمانی نمایش داده می‌شه
                      //    که جستجو فعال نباشه
                      if (!_searchFocusNode.hasFocus) ...[
                        const SizedBox(height: 24),
                        if (store.isLoading && store.location.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 100),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          _buildWeatherContent(context, store),
                      ],

                      const SizedBox(height: 120), // فاصله امن پایین
                    ],
                  ),
                ),
              ),
            ),
          ),

          // اورلی لودینگ (حالا بخشی از state محلی است)
          if (_showSearchLoading)
            IgnorePointer(
              ignoring: true,
              child: AnimatedOpacity(
                opacity: 0.9,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withAlpha(89), // (Opacity 0.35)
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54, // (Opacity 0.5)
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(width: 12),
                          CircularProgressIndicator(
                            color: Colors.white70,
                            strokeWidth: 2.5,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'در حال جستجو...',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 12),
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

  // 🔍 بخش جستجو
  Widget _buildSearchSection(BuildContext context, WeatherStore store) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyMedium?.color;
    final subtitleColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withAlpha(179); // (Opacity 0.7)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SizedBox(
        width: math.min(MediaQuery.of(context).size.width * 0.9, 720.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. نوار جستجو
            TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              maxLength: 30,
              onChanged: store.onSearchChanged,
              textInputAction: TextInputAction.search,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[ء-يآ-یa-zA-Z\s]')),
              ],
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'نام شهر را وارد کنید...',
                counterText: "",
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(store),
                ),
              ),
              onSubmitted: (_) => _performSearch(store),
            ),
            const SizedBox(height: 8),

            // 2. لیست پیشنهادات
            if (store.suggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  interactive: true,
                  thickness: 3,
                  radius: const Radius.circular(8),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: store.suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = store.suggestions[index];
                      final nameFa =
                          (suggestion['local_names']?['fa'] ??
                                  suggestion['name'] ??
                                  '')
                              .toString();
                      final country = (suggestion['country'] ?? '').toString();
                      final state = (suggestion['state'] ?? '').toString();
                      final subtitle = [
                        if (state.isNotEmpty && state != nameFa) state,
                        if (country.isNotEmpty) country,
                      ].join(' • ');

                      return ListTile(
                        title: Text(
                          nameFa.isNotEmpty ? nameFa : 'ناشناخته',
                          style: TextStyle(color: textColor),
                        ),
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

            // 3. جستجوهای اخیر
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
                child: Builder(
                  builder: (context) {
                    final titleColor = textColor;
                    final actionColor = subtitleColor;
                    final chipBg = isDark
                        ? Colors.white.withAlpha(31) // (Opacity 0.12)
                        : Colors.black.withAlpha(20); // (Opacity 0.08)
                    final chipText = textColor;
                    final chipDelete = subtitleColor;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'جستجوهای اخیر',
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: store.clearRecentSearches,
                              child: Text(
                                'پاک کردن',
                                style: TextStyle(color: actionColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (
                              int i = 0;
                              i < store.recentSearches.length;
                              i++
                            )
                              InputChip(
                                label: Text(
                                  store.recentSearches[i],
                                  style: TextStyle(color: chipText),
                                ),
                                backgroundColor: chipBg,
                                onPressed: () {
                                  store.searchAndFetchByCityName(
                                    store.recentSearches[i],
                                  );
                                  FocusScope.of(context).unfocus();
                                },
                                onDeleted: () => store.removeRecentAt(i),
                                deleteIconColor: chipDelete,
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🌡 بخش محتوای وضعیت هوا
  Widget _buildWeatherContent(BuildContext context, WeatherStore store) {
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: Text(
            'برای شروع، شهر مورد نظر را جستجو کنید.',
            style: TextStyle(fontSize: 16),
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
        _buildCurrentWeatherSection(context, store),

        if (store.showAirQuality) ...[
          const SizedBox(height: 16),
          _buildAirQualitySection(context, store),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  // 🌤 وضعیت فعلی
  Widget _buildCurrentWeatherSection(BuildContext context, WeatherStore store) {
    final tempC = store.temperature;
    final temp = store.useCelsius
        ? tempC
        : (tempC != null ? (tempC * 9 / 5) + 32 : null);

    final textTheme = Theme.of(context).textTheme;
    final iconColor = textTheme.bodyMedium?.color?.withAlpha(
      204,
    ); // (Opacity 0.8)

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
                  toPersianDigits('${temp?.toStringAsFixed(1) ?? '--'}°'),
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 56,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  store.location,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      translateWeather(store.weatherType),
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

  // 🌫 بخش کیفیت هوا
  Widget _buildAirQualitySection(BuildContext context, WeatherStore store) {
    final aqi = store.airQualityIndex ?? 0;
    final color = statusColorForAqi(aqi);
    final status = labelForAqi(aqi);
    final progress = (aqi / 500.0).clamp(0.0, 1.0);

    return RepaintBoundary(
      child: Center(
        child: SizedBox(
          width: math.min(MediaQuery.of(context).size.width, 900.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.air_rounded, color: color, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شاخص کیفیت هوا (AQI)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: color.withAlpha(51),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        toPersianDigits('AQI $aqi'),
                        style: TextStyle(
                          color: color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.withAlpha(51),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toPersianDigits('0'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(153),
                          ),
                    ),
                    Text(
                      toPersianDigits('500'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(153),
                          ),
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

}
