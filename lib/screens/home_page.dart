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
      child: Column(
        children: [
          // --- هدر دراور ---
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: SizedBox(
              width: double.infinity,
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
          ),

          // --- لیست آیتم‌ها ---
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ---------------- 1. بخش مکان‌های سنجاق شده ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 10),
                  child: Text(
                    l10n.pinnedLocations,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // آیتم شهر پین شده (با استایل ListTile برای داشتن دکمه حذف)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    // اگر شهر فعلی همان شهر پین شده است، رنگی شود
                    tileColor:
                        (vm.location.toLowerCase() ==
                            vm.defaultCity.toLowerCase())
                        ? theme.colorScheme.secondaryContainer
                        : null,
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 16,
                      end: 8,
                    ),

                    leading: Icon(
                      Icons.push_pin, // پین توپر برای نشان دادن وضعیت
                      color: theme.colorScheme.primary,
                    ),

                    title: Text(
                      vm.defaultCity,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    onTap: () {
                      vm.fetchWeatherByCity(vm.defaultCity);
                      Navigator.pop(context);
                    },

                    // دکمه حذف پین (ریست به حالت اولیه)
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline, // سطل آشغال
                        size: 20,
                        color: theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                      tooltip: 'حذف پین',
                      onPressed: () {
                        // وقتی پین حذف شود، شهر پیش‌فرض به تهران (یا هر شهر امن دیگر) برمی‌گردد
                        vm.setDefaultCity('Tehran');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.localeName == 'fa'
                                  ? 'مکان پیش‌فرض بازنشانی شد'
                                  : 'Default location reset',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Divider(indent: 28, endIndent: 28, height: 32),

                // ---------------- 2. بخش مکان‌های اخیر ----------------
                if (vm.recent.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                    child: Text(
                      l10n.recentLocations,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  ...vm.recent.map((city) {
                    final isSelected =
                        vm.location.toLowerCase() == city.toLowerCase();
                    // چک میکنیم آیا این شهر در لیست اخیر، همانی است که پین شده؟
                    final isPinned =
                        city.toLowerCase() == vm.defaultCity.toLowerCase();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        tileColor: isSelected
                            ? theme.colorScheme.secondaryContainer
                            : null,
                        contentPadding: const EdgeInsetsDirectional.only(
                          start: 16,
                          end: 8,
                        ),

                        leading: Icon(
                          Icons.history,
                          color: isSelected
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSurfaceVariant,
                        ),

                        title: Text(
                          city,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        onTap: () {
                          vm.fetchWeatherByCity(city);
                          Navigator.pop(context);
                        },

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // دکمه پین
                            IconButton(
                              icon: Icon(
                                // اگر پین شده بود توپر، وگرنه توخالی
                                isPinned
                                    ? Icons.push_pin
                                    : Icons.push_pin_outlined,
                                size: 20,
                                color: isPinned
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.primary.withValues(
                                        alpha: 0.7,
                                      ),
                              ),
                              tooltip: 'سنجاق کردن',
                              onPressed: () {
                                vm.setDefaultCity(city);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('$city پین شد'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),

                            // دکمه حذف (سطل آشغال)
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline, // آیکون جدید سطل آشغال
                                size: 20,
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              tooltip: 'حذف از تاریخچه',
                              onPressed: () {
                                vm.removeRecent(city);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
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
