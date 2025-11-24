import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'l10n/app_localizations.dart';
import 'screens/weather_screen.dart';
import 'viewmodels/weather_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Simple state management for ThemeMode and Locale (local UI toggles)
  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final localeNotifier = ValueNotifier<Locale>(const Locale('fa'));

  runApp(
    // 1. Wrap with DynamicColorBuilder to get system colors (Android 12+)
    DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ChangeNotifierProvider(
          create: (_) => WeatherViewModel(),
          // 2. Consume ViewModel to listen for seedColor or useSystemColor changes
          child: Consumer<WeatherViewModel>(
            builder: (context, viewModel, _) {
              // --- THEME GENERATION LOGIC ---

              // Determine if we should use the system color
              final bool useSystem = viewModel.useSystemColor;

              // A. Define Light Color Scheme
              ColorScheme lightScheme;
              if (useSystem && lightDynamic != null) {
                // Use Android System Color
                lightScheme = lightDynamic.harmonized();
              } else {
                // Use Custom Seed Color
                lightScheme = ColorScheme.fromSeed(
                  seedColor: viewModel.seedColor,
                  brightness: Brightness.light,
                );
              }

              // B. Define Dark Color Scheme
              ColorScheme darkScheme;
              if (useSystem && darkDynamic != null) {
                // Use Android System Color
                darkScheme = darkDynamic.harmonized();
              } else {
                // Use Custom Seed Color
                darkScheme = ColorScheme.fromSeed(
                  seedColor: viewModel.seedColor,
                  brightness: Brightness.dark,
                );
              }

              // --- APP STRUCTURE ---

              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, themeMode, _) {
                  return ValueListenableBuilder<Locale>(
                    valueListenable: localeNotifier,
                    builder: (context, locale, _) {
                      return MaterialApp(
                        title: 'Weatherly',
                        debugShowCheckedModeBanner: false,

                        // Localization
                        locale: locale,
                        supportedLocales: AppLocalizations.supportedLocales,
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,

                        // Theme Mode (System, Light, Dark)
                        themeMode: themeMode,

                        // Apply Light Theme
                        theme: ThemeData(
                          useMaterial3: true,
                          fontFamily: 'Vazir',
                          colorScheme: lightScheme,
                        ),

                        // Apply Dark Theme
                        darkTheme: ThemeData(
                          useMaterial3: true,
                          fontFamily: 'Vazir',
                          colorScheme: darkScheme,
                        ),

                        // RTL/LTR Direction Support
                        builder: (context, child) {
                          final isFarsi =
                              Localizations.localeOf(context).languageCode ==
                              'fa';
                          return Directionality(
                            textDirection: isFarsi
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            child: child!,
                          );
                        },

                        home: WeatherScreen(
                          currentThemeMode: themeMode,
                          onThemeChanged: (m) => themeNotifier.value = m,
                          onLocaleChanged: (loc) {
                            localeNotifier.value = loc;
                            // Update API language preference in ViewModel
                            viewModel.setLang(loc.languageCode);
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    ),
  );
}
