import 'package:flutter/material.dart';
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
    const inputColor = Colors.white;
    final hintColor = Colors.white.withValues(alpha: 0.7);

    return Column(
      children: [
        // Search TextField
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            maxLength: 30,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearchPressed(),
            onChanged: viewModel.searchChanged,
            style: const TextStyle(
              color: inputColor,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: l10n.enterCityName,
              counterText: "",
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: inputColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: inputColor.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: inputColor, width: 1.5),
              ),
              hintStyle: TextStyle(
                color: hintColor,
                fontWeight: FontWeight.normal,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                color: inputColor,
                onPressed: onSearchPressed,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),

        // Suggestions List
        if (viewModel.suggestions.isNotEmpty && searchFocusNode.hasFocus)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: viewModel.suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = viewModel.suggestions[index];
                  final city = suggestion['name'] as String? ?? '';

                  return InkWell(
                    onTap: () {
                      searchController.text = city;
                      viewModel.fetchWeatherByCity(city);
                      searchFocusNode.unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: index < viewModel.suggestions.length - 1
                              ? BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.5,
                                )
                              : BorderSide.none,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withValues(alpha: 0.5),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
