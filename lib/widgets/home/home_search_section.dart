import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class HomeSearchSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyMedium?.color;
    final subtitleColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                maxLength: 30,
                onChanged: viewModel.searchChanged,
                textInputAction: TextInputAction.search,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[ء-يآ-یa-zA-Z\s]'),
                  ),
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
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      width: 1.4,
                    ),
                  ),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: onSearchPressed,
                  ),
                ),
                onSubmitted: (_) => onSearchPressed(),
              ),
            ),

            const SizedBox(height: 8),

            // --- SUGGESTIONS LIST (When typing) ---
            if (viewModel.suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: viewModel.suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = viewModel.suggestions[index];

                        final nameFa = suggestion['local_names']?['fa']
                            ?.toString();
                        final nameEn = suggestion['name']?.toString() ?? '';
                        final name = viewModel.lang == 'fa'
                            ? (nameFa ?? nameEn)
                            : nameEn;

                        final country = (suggestion['country'] ?? '')
                            .toString();
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
                          onTap: () async {
                            await viewModel.selectCitySuggestion(suggestion);
                            if (!context.mounted) return;
                            searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
