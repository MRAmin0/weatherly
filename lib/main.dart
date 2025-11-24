import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'l10n/app_localizations.dart';
import 'screens/weather_screen.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'config/config_reader.dart'; // 1. Import ConfigReader

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize ConfigReader before running the app
  await ConfigReader.initialize();

  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final localeNotifier = ValueNotifier<Locale>(const Locale('fa'));

  runApp(
    DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return ChangeNotifierProvider(
          // 3. Pass the API key to the ViewModel (Optional, or ViewModel can read it directly)
          create: (_) => WeatherViewModel(),
          child: Consumer<WeatherViewModel>(
            builder: (context, viewModel, _) {
              // ... (Baghie kodhaye main shoma mesle ghabl)

              // Determine if we should use the system color
              final bool useSystem = viewModel.useSystemColor;

              // A. Define Light Color Scheme
              ColorScheme lightScheme;
              if (useSystem && lightDynamic != null) {
                lightScheme = lightDynamic.harmonized();
              } else {
                lightScheme = ColorScheme.fromSeed(
                  seedColor: viewModel.seedColor,
                  brightness: Brightness.light,
                );
              }

              // B. Define Dark Color Scheme
              ColorScheme darkScheme;
              if (useSystem && darkDynamic != null) {
                darkScheme = darkDynamic.harmonized();
              } else {
                darkScheme = ColorScheme.fromSeed(
                  seedColor: viewModel.seedColor,
                  brightness: Brightness.dark,
                );
              }

              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, themeMode, _) {
                  return ValueListenableBuilder<Locale>(
                    valueListenable: localeNotifier,
                    builder: (context, locale, _) {
                      return MaterialApp(
                        title: 'Weatherly',
                        debugShowCheckedModeBanner: false,
                        locale: locale,
                        supportedLocales: AppLocalizations.supportedLocales,
                        localizationsDelegates:
                            AppLocalizations.localizationsDelegates,
                        themeMode: themeMode,
                        theme: ThemeData(
                          useMaterial3: true,
                          fontFamily: 'Vazir',
                          colorScheme: lightScheme,
                        ),
                        darkTheme: ThemeData(
                          useMaterial3: true,
                          fontFamily: 'Vazir',
                          colorScheme: darkScheme,
                        ),
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
