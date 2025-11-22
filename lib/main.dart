import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/screens/weather_screen.dart';
import 'package:weatherly_app/weather_store.dart';
// import 'package:weatherly_app/config_reader.dart'; // این ایمپورت حذف شد

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ❌ حذف: await ConfigReader.initialize();
  // ❌ حذف: بخش چک کردن API Key حذف شد

  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
  final localeNotifier = ValueNotifier<Locale>(const Locale('fa'));

  runApp(
    DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        WeatherStore.systemColorAvailable =
            lightDynamic != null || darkDynamic != null;
        return ChangeNotifierProvider(
          create: (_) => WeatherStore(),
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, themeMode, _) {
              return ValueListenableBuilder<Locale>(
                valueListenable: localeNotifier,
                builder: (context, locale, _) {
                  final weatherStore = context.read<WeatherStore>();
                  // اگر زبان سیستم با زبان استور هماهنگ نبود، آن را آپدیت کن
                  if (weatherStore.currentLang != locale.languageCode) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      weatherStore.setLanguage(locale.languageCode);
                    });
                  }

                  return Consumer<WeatherStore>(
                    builder: (context, store, _) {
                      final seedColor = Color(store.accentColorValue);
                      final bool preferDynamic = store.useSystemColor;

                      final lightScheme = _resolveColorScheme(
                        dynamicScheme: lightDynamic,
                        brightness: Brightness.light,
                        seedColor: seedColor,
                        useDynamic: preferDynamic,
                      );

                      final darkScheme = _resolveColorScheme(
                        dynamicScheme: darkDynamic,
                        brightness: Brightness.dark,
                        seedColor: seedColor,
                        useDynamic: preferDynamic,
                      );

                      return MaterialApp(
                        title: 'Weatherly',
                        debugShowCheckedModeBanner: false,

                        // تنظیمات زبان و راست‌چین/چپ‌چین
                        locale: locale,
                        supportedLocales: AppLocalizations.supportedLocales,
                        localizationsDelegates:
                        AppLocalizations.localizationsDelegates,

                        // تنظیمات تم
                        themeMode: themeMode,
                        theme: _buildTheme(lightScheme),
                        darkTheme: _buildTheme(darkScheme),

                        // مدیریت جهت متن (RTL/LTR)
                        builder: (context, child) {
                          final currentLocale = Localizations.localeOf(context);
                          final textDirection =
                          currentLocale.languageCode == 'fa'
                              ? TextDirection.rtl
                              : TextDirection.ltr;
                          return Directionality(
                            textDirection: textDirection,
                            child: child!,
                          );
                        },

                        home: WeatherScreen(
                          currentThemeMode: themeMode,
                          onThemeChanged: (newMode) =>
                          themeNotifier.value = newMode,
                          onLocaleChanged: (newLocale) =>
                          localeNotifier.value = newLocale,
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

ColorScheme _resolveColorScheme({
  required ColorScheme? dynamicScheme,
  required Brightness brightness,
  required Color seedColor,
  required bool useDynamic,
}) {
  if (useDynamic && dynamicScheme != null) {
    return dynamicScheme.harmonized();
  }
  return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
}

ThemeData _buildTheme(ColorScheme colorScheme) {
  final isDark = colorScheme.brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Vazir', // یا هر فونتی که استفاده می‌کنید
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    // یک‌دست‌سازی پس‌زمینه و کارت‌ها
    scaffoldBackgroundColor: colorScheme.surface,
    cardColor: colorScheme.surfaceContainerHighest,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontFamily: 'Vazir',
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1F2C) : Colors.white,
      hintStyle: TextStyle(color: Colors.grey.shade600),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24.0),
        borderSide: isDark
            ? BorderSide.none
            : BorderSide(color: Colors.grey.shade300),
      ),
    ),

    textTheme: TextTheme(
      bodyMedium: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
      titleMedium: TextStyle(color: isDark ? Colors.white : Colors.black),
    ),
  );
}