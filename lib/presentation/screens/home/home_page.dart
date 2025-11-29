import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/data/services/network_service.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

import 'package:weatherly_app/presentation/widgets/home/home_search_section.dart';
import 'package:weatherly_app/presentation/widgets/home/current_weather_section.dart';
import 'package:weatherly_app/presentation/widgets/home/details_row.dart';
import 'package:weatherly_app/presentation/widgets/home/weather_drawer.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onSearchFocusChange;

  const HomePage({super.key, required this.onSearchFocusChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  bool _showSearchOverlay = false;
  DateTime? _searchStartTime;

  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _focusListener = () {
      widget.onSearchFocusChange(_searchFocusNode.hasFocus);
      if (mounted) setState(() {});
    };
    _searchFocusNode.addListener(_focusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetOnStart();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.removeListener(_focusListener);
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkInternetOnStart() async {
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
      _showSearchOverlay = true;
      _searchStartTime = DateTime.now();
    });

    await vm.fetchWeatherByCity(query);
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // کنترل زمان نمایش لودینگ سرچ
    if (_showSearchOverlay && !vm.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        const minMs = 900;
        final started = _searchStartTime ?? DateTime.now();
        final elapsed = DateTime.now().difference(started).inMilliseconds;
        final remain = (minMs - elapsed).clamp(0, minMs);
        if (remain > 0) await Future.delayed(Duration(milliseconds: remain));

        if (mounted) setState(() => _showSearchOverlay = false);
      });
    }

    final bool isInitialLoading =
        vm.isLoading && (vm.location.isEmpty || vm.currentWeather == null);

    return Scaffold(
      key: _scaffoldKey,
      drawer: WeatherDrawer(vm: vm, l10n: l10n),

      backgroundColor: theme.colorScheme.surface, //⭐ پس‌زمینه درست
      // AppBar استاندارد و هماهنگ با Material3
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          l10n.weatherly,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          RefreshIndicator(
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceVariant,
            onRefresh: vm.refresh,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: _searchFocusNode.hasFocus
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
                  bottom: 40,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),

                        // بخش سرچ
                        HomeSearchSection(
                          searchController: _searchController,
                          searchFocusNode: _searchFocusNode,
                          viewModel: vm,
                          l10n: l10n,
                          onSearchPressed: () => _performSearch(vm),
                        ),

                        if (!_searchFocusNode.hasFocus) ...[
                          const SizedBox(height: 24),
                          if (isInitialLoading)
                            const _CenteredLoader()
                          else
                            _buildWeatherContent(context, vm, l10n, theme),
                        ],

                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // لودینگ Overlay هنگام سرچ
          if (_showSearchOverlay)
            Container(
              color: Colors.black.withValues(alpha: 0.28),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (vm.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Text(
            vm.error!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (vm.location.isEmpty && vm.currentWeather == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Text(
            l10n.startBySearching,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (vm.currentWeather == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // ⭐ کارت شیشه‌ای زیبا
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CurrentWeatherSection(viewModel: vm, l10n: l10n),
          const SizedBox(height: 18),
          Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 18),
          DetailsRow(viewModel: vm, l10n: l10n),
        ],
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
