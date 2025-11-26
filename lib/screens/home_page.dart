import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/services/network_service.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
// برای استفاده از WeatherType.clear

import 'package:weatherly_app/widgets/home/home_search_section.dart';
import 'package:weatherly_app/widgets/home/current_weather_section.dart';
import 'package:weatherly_app/widgets/home/details_row.dart';
// گرادینت از اینجا حذف شد و در فایل WeatherScreen قرار گرفت
import 'package:weatherly_app/widgets/home/weather_drawer.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkInternetOnStart();
    });

    _mainScrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _focusListener = () {
      widget.onSearchFocusChange(_searchFocusNode.hasFocus);
      if (mounted) setState(() {});
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
    if (!online && mounted) {
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

  Future<void> _performSearch(WeatherViewModel vm) async {
    FocusScope.of(context).unfocus();

    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _showSearchLoading = true;
      _searchLoadingStartedAt = DateTime.now();
    });

    await vm.fetchWeatherByCity(query);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final l10n = AppLocalizations.of(context)!;

    // --- لاجیک گرادینت حذف شد ---

    if (_showSearchLoading && !vm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        const minMs = 1200;
        final started = _searchLoadingStartedAt ?? DateTime.now();
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        final remain = (minMs - elapsed).clamp(0, minMs);

        if (remain > 0) {
          await Future.delayed(Duration(milliseconds: remain));
        }
        if (mounted) {
          setState(() => _showSearchLoading = false);
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // مهم: شفاف شد
      // استفاده از دراور جدا شده
      drawer: WeatherDrawer(vm: vm, l10n: l10n),

      // اپ‌بار شیشه‌ای
      appBar: AppBar(
        title: Text(l10n.weatherly),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),

      // بادی که دیگر کانتینر گرادینت ندارد
      body: Stack(
        children: [
          RefreshIndicator(
            color: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            onRefresh: () => vm.fetchWeatherByCity(
              vm.location.isNotEmpty ? vm.location : "Tehran",
            ),
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: _searchFocusNode.hasFocus
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        HomeSearchSection(
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          viewModel: vm,
                          l10n: l10n,
                          onSearchPressed: () => _performSearch(vm),
                        ),

                        if (!_searchFocusNode.hasFocus) ...[
                          const SizedBox(height: 24),
                          if (vm.isLoading && vm.location.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 100),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          else
                            _buildWeatherContent(context, vm, l10n),
                        ],

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_showSearchLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
  ) {
    // محتوای اصلی آب و هوا (کارت شیشه‌ای)
    if (vm.error != null) {
      return Center(
        child: Text(vm.error!, style: const TextStyle(color: Colors.white)),
      );
    }

    if (vm.location.isEmpty && !vm.isLoading) {
      return Center(
        child: Text(
          l10n.startBySearching,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (vm.location.isEmpty || vm.currentWeather == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        // افکت Glassmorphism
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CurrentWeatherSection(viewModel: vm, l10n: l10n),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(color: Colors.white.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 16),
          DetailsRow(viewModel: vm, l10n: l10n),
        ],
      ),
    );
  }
}
