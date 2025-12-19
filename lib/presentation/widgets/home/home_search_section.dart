import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class HomeSearchSection extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final WeatherViewModel viewModel;
  final AppLocalizations l10n;
  final VoidCallback onSearchPressed;

  const HomeSearchSection({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.viewModel,
    required this.l10n,
    required this.onSearchPressed,
  });

  @override
  State<HomeSearchSection> createState() => _HomeSearchSectionState();
}

class _HomeSearchSectionState extends State<HomeSearchSection> {
  @override
  void initState() {
    super.initState();
    widget.searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.searchFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFocus = widget.searchFocusNode.hasFocus;

    return TapRegion(
      onTapOutside: (_) {
        if (hasFocus) {
          widget.searchFocusNode.unfocus();
        }
      },
      child: Column(
        children: [
          // Search TextField
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: hasFocus ? 0.25 : 0.15,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: hasFocus ? 0.3 : 0.1,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    focusNode: widget.searchFocusNode,
                    maxLength: 30,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => widget.onSearchPressed(),
                    onChanged: widget.viewModel.searchChanged,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.l10n.enterCityName,
                      counterText: "",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: hasFocus
                          ? IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.searchFocusNode.unfocus();
                                widget.searchController.clear();
                                widget.viewModel.searchChanged('');
                              },
                            )
                          : const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: widget.searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                widget.searchController.clear();
                                widget.viewModel.searchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Suggestions List
          if (widget.viewModel.suggestions.isNotEmpty && hasFocus)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[900]?.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 250),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: widget.viewModel.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = widget.viewModel.suggestions[index];
                    final city = suggestion['name'] as String? ?? '';
                    final country = suggestion['country'] as String? ?? '';
                    final displayText = country.isNotEmpty
                        ? '$country, $city'
                        : city;

                    return ListTile(
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(
                        displayText,
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        widget.viewModel.selectCitySuggestion(suggestion);
                        widget.searchFocusNode.unfocus();
                        widget.searchController.clear();
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
