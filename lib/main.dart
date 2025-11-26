import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:device_preview/device_preview.dart';

import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'config/config_reader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return ChangeNotifierProvider(
            create: (_) => WeatherViewModel(),
            child: Consumer<WeatherViewModel>(
              builder: (context, viewModel, _) {
                final bool useSystem = viewModel.useSystemColor;

                // Light Theme
                ColorScheme lightScheme;
                if (useSystem && lightDynamic != null) {
                  lightScheme = lightDynamic.harmonized();
                } else {
                  lightScheme = ColorScheme.fromSeed(
                    seedColor: viewModel.seedColor,
                    brightness: Brightness.light,
                  );
                }

                // Dark Theme
                ColorScheme darkScheme;
                if (useSystem && darkDynamic != null) {
                  darkScheme = darkDynamic.harmonized();
                } else {
                  darkScheme = ColorScheme.fromSeed(
                    seedColor: viewModel.seedColor,
                    brightness: Brightness.dark,
                  );
                }

                return MaterialApp(
                  title: 'Weatherly',
                  debugShowCheckedModeBanner: false,

                  locale: Locale(viewModel.lang),

                  builder: (context, child) {
                    child = DevicePreview.appBuilder(context, child);
                    final isFarsi =
                        Localizations.localeOf(context).languageCode == 'fa';
                    return Directionality(
                      textDirection: isFarsi
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: child, // ✅ FIX: علامت '!' حذف شد
                    );
                  },

                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,

                  themeMode: viewModel.themeMode,

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

                  home: const SplashScreen(),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}
