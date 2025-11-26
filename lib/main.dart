import 'package:flutter/foundation.dart'; // برای kReleaseMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:device_preview/device_preview.dart'; // 1. ایمپورت پکیج Device Preview

import 'l10n/app_localizations.dart';
import 'screens/weather_screen.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'config/config_reader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final localeNotifier = ValueNotifier<Locale>(const Locale('fa'));

  runApp(
    // 2. رپ کردن کل برنامه با DevicePreview
    DevicePreview(
      enabled: !kReleaseMode, // فقط در حالت دیباگ فعال باشد
      builder: (context) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          return ChangeNotifierProvider(
            create: (_) => WeatherViewModel(),
            child: Consumer<WeatherViewModel>(
              builder: (context, viewModel, _) {
                final bool useSystem = viewModel.useSystemColor;

                ColorScheme lightScheme;
                if (useSystem && lightDynamic != null) {
                  lightScheme = lightDynamic.harmonized();
                } else {
                  lightScheme = ColorScheme.fromSeed(
                    seedColor: viewModel.seedColor,
                    brightness: Brightness.light,
                  );
                }

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
                          builder: (context, child) {
                            // الف: ابتدا بیلدر DevicePreview را صدا می‌زنیم
                            child = DevicePreview.appBuilder(context, child);
                            // ب: سپس منطق Directionality خودتان را اعمال می‌کنیم
                            final isFarsi =
                                Localizations.localeOf(context).languageCode ==
                                'fa';
                            return Directionality(
                              textDirection: isFarsi
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: child,
                            );
                          },

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
    ),
  );
}
