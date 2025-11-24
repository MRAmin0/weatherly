import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/services/network_service.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

import 'package:weatherly_app/widgets/home/home_search_section.dart';
// This import MUST exist for CurrentWeatherSection to be found
import 'package:weatherly_app/widgets/home/current_weather_section.dart';
import 'package:weatherly_app/widgets/home/details_row.dart';

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
      drawer: _buildDrawer(context, vm, l10n),
      appBar: AppBar(title: Text(l10n.weatherly), centerTitle: true),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => vm.fetchWeatherByCity(
              vm.location.isNotEmpty ? vm.location : "Tehran",
            ),
            child: SingleChildScrollView(
              controller: _mainScrollController,
              physics: _searchFocusNode.hasFocus
                  ? const NeverScrollableScrollPhysics()
                  : const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            child: CircularProgressIndicator(),
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
    final theme = Theme.of(context);

    if (vm.error != null) {
      return Center(child: Text(vm.error!));
    }

    if (vm.location.isEmpty && !vm.isLoading) {
      return Center(child: Text(l10n.startBySearching));
    }

    if (vm.location.isEmpty || vm.currentWeather == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 100),
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // This is the line causing the error.
          // Ensure CurrentWeatherSection class is defined in the imported file.
          CurrentWeatherSection(viewModel: vm, l10n: l10n),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          DetailsRow(viewModel: vm, l10n: l10n),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WeatherViewModel vm,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.cloud_circle_rounded,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.weatherly,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
            child: Text(
              l10n.pinnedLocations,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.push_pin_outlined),
            selectedIcon: const Icon(Icons.push_pin),
            label: Text(vm.defaultCity),
            onTap: () {
              vm.fetchWeatherByCity(vm.defaultCity);
              Navigator.pop(context);
            },
            isSelected: vm.location == vm.defaultCity,
          ),
          const Divider(indent: 28, endIndent: 28),
          if (vm.recent.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Text(
                l10n.recentLocations,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
            ...vm.recent.map((city) {
              final isSelected = vm.location == city;
              return NavigationDrawerDestination(
                icon: const Icon(Icons.history),
                selectedIcon: const Icon(Icons.history),
                label: Text(city),
                isSelected: isSelected,
                onTap: () {
                  vm.fetchWeatherByCity(city);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

class NavigationDrawerDestination extends StatelessWidget {
  final Widget icon;
  final Widget selectedIcon;
  final Widget label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationDrawerDestination({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        tileColor: isSelected ? theme.colorScheme.secondaryContainer : null,
        leading: isSelected ? selectedIcon : icon,
        title: DefaultTextStyle(
          style: theme.textTheme.labelLarge!.copyWith(
            color: isSelected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
          child: label,
        ),
        onTap: onTap,
        iconColor: isSelected
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
