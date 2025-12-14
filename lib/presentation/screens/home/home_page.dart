import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/data/services/network_service.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

import 'package:weatherly_app/presentation/widgets/home/home_search_section.dart';
import 'package:weatherly_app/presentation/widgets/home/current_weather_section.dart';
import 'package:weatherly_app/presentation/widgets/home/details_row.dart';
import 'package:weatherly_app/presentation/widgets/home/weather_drawer.dart';
import 'package:weatherly_app/presentation/widgets/animations/searching_radar.dart';
import 'package:weatherly_app/presentation/widgets/home/recent_cities_slider.dart';

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
  double _titleOpacity = 1.0;

  late final VoidCallback _focusListener;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _scrollController.addListener(_onScroll);

    _focusListener = () {
      widget.onSearchFocusChange(_searchFocusNode.hasFocus);
      if (mounted) setState(() {});
    };

    _searchFocusNode.addListener(_focusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetOnStart();
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    // Fade out from 0 to 100 pixels of scroll
    final newOpacity = (1.0 - (offset / 100)).clamp(0.0, 1.0);
    if (newOpacity != _titleOpacity) {
      setState(() {
        _titleOpacity = newOpacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
    });

    await vm.fetchWeatherByCity(query);
    _searchController.clear();

    if (mounted) {
      setState(() {
        _showSearchOverlay = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final l10n = AppLocalizations.of(context)!;

    final bool isInitialLoading =
        vm.isLoading && (vm.location.isEmpty || vm.currentWeather == null);

    return Scaffold(
      key: _scaffoldKey,
      drawer: WeatherDrawer(vm: vm, l10n: l10n),
      body: Stack(
        children: [
          RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surface,
            onRefresh: vm.refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Custom AppBar area (formerly SliverAppBar)
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  // --- تغییر: دکمه منو اومد اول (سمت راست در فارسی) ---
                                  IconButton(
                                    icon: const Icon(Icons.menu),
                                    onPressed: () {
                                      _scaffoldKey.currentState?.openDrawer();
                                    },
                                  ),

                                  Expanded(
                                    child: Center(
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        opacity: 1.0, // Always visible now
                                        child: Text(
                                          l10n.localeName == 'fa'
                                              ? 'خانه'
                                              : 'Home',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // --- تغییر: فضای خالی رفت آخر (برای قرینه شدن) ---
                                  const SizedBox(width: 48),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          HomeSearchSection(
                            searchController: _searchController,
                            searchFocusNode: _searchFocusNode,
                            viewModel: vm,
                            l10n: l10n,
                            onSearchPressed: () => _performSearch(vm),
                          ),

                          const SizedBox(height: 16),
                          const RecentCitiesSlider(),

                          if (!_searchFocusNode.hasFocus) ...[
                            const SizedBox(height: 16),
                            if (isInitialLoading)
                              const SizedBox(
                                height: 400,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              // Use simple container, logic matches original but no Expanded needed if content is small
                              // or use Spacer to balance?
                              // The user wants it to "Fit in one page".
                              // We will let it take natural size.
                              _buildWeatherContent(context, vm, l10n),
                          ],
                          // Add some bottom padding for safety but not 120
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_showSearchOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(
                  0.7,
                ), // Slightly darker for better contrast
                child: SearchingRadar(
                  message: l10n.localeName == 'fa'
                      ? 'در حال پیدا کردن ${vm.location.isEmpty ? 'شهر' : vm.location}...'
                      : 'Finding ${vm.location.isEmpty ? 'City' : vm.location}...',
                ),
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
    if (vm.error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Text(
            vm.error!,
            style: const TextStyle(color: Colors.redAccent),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (vm.currentWeather == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 80),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final child = Column(
      children: [
        CurrentWeatherSection(viewModel: vm, l10n: l10n),
        const SizedBox(height: 18),
        Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
        const SizedBox(height: 18),
        DetailsRow(viewModel: vm, l10n: l10n),
      ],
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
