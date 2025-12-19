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
    final inputColor = theme.colorScheme.onSurface;
    final hintColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextField(
              controller: widget.searchController,
              focusNode: widget.searchFocusNode,
              maxLength: 30,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => widget.onSearchPressed(),
              onChanged: widget.viewModel.searchChanged,
              style: TextStyle(color: inputColor, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: widget.l10n.enterCityName,
                counterText: "",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.4,
                ),
                prefixIcon: hasFocus
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          widget.searchFocusNode.unfocus();
                          widget.searchController.clear();
                          widget.viewModel.searchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: inputColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: inputColor.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                hintStyle: TextStyle(
                  color: hintColor,
                  fontWeight: FontWeight.normal,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  color: inputColor,
                  onPressed: widget.onSearchPressed,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          // Suggestions List
          if (widget.viewModel.suggestions.isNotEmpty && hasFocus)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
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
