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
    // رنگ‌های آیکون و متن باید سفید باشند چون پس‌زمینه رنگی است
    const inputColor = Colors.white;
    final hintColor = Colors.white.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        maxLength: 30,
        // اکشن سرچ روی کیبورد
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSearchPressed(),
        onChanged: viewModel.searchChanged,

        // استایل متن ورودی
        style: TextStyle(color: inputColor, fontWeight: FontWeight.w600),

        decoration: InputDecoration(
          hintText: l10n.enterCityName,
          counterText: "",

          // --- تغییرات برای افکت شیشه‌ای ---
          filled: true,
          // ✅ رنگ نیمه‌شفاف برای پر کردن
          fillColor: Colors.white.withValues(alpha: 0.15),

          // ✅ استایل Border
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: inputColor.withValues(alpha: 0.3), // حاشیه محو
              width: 1.0,
            ),
          ),

          // border در حالت عادی
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: inputColor.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),

          // border در حالت فوکوس
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: inputColor, // حاشیه سفید کامل
              width: 1.5,
            ),
          ),

          // استایل Hint
          hintStyle: TextStyle(color: hintColor, fontWeight: FontWeight.normal),

          // آیکون سرچ
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            color: inputColor,
            onPressed: onSearchPressed,
          ),

          // پدینگ داخلی
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
