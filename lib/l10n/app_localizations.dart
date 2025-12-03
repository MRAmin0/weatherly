import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fa'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Weatherly'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @developerName.
  ///
  /// In en, this message translates to:
  /// **'Amin Monajati'**
  String get developerName;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportAnIssue;

  /// No description provided for @contactViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact via email'**
  String get contactViaEmail;

  /// No description provided for @changelog.
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @versionHistory.
  ///
  /// In en, this message translates to:
  /// **'Version History'**
  String get versionHistory;

  /// No description provided for @readingVersion.
  ///
  /// In en, this message translates to:
  /// **'Reading version...'**
  String get readingVersion;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Weatherly helps you check weather conditions with beautiful UI.'**
  String get appDescription;

  /// No description provided for @projectOnGithub.
  ///
  /// In en, this message translates to:
  /// **'Project on GitHub'**
  String get projectOnGithub;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @forecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get forecast;

  /// No description provided for @persian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get persian;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get displayMode;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced settings'**
  String get advancedSettings;

  /// No description provided for @themeAccentColor.
  ///
  /// In en, this message translates to:
  /// **'UI theme color'**
  String get themeAccentColor;

  /// No description provided for @customizeThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a color you like to personalize Weatherly.'**
  String get customizeThemeDescription;

  /// No description provided for @useSystemColor.
  ///
  /// In en, this message translates to:
  /// **'Use System Color'**
  String get useSystemColor;

  /// No description provided for @useSystemColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Material You dynamic colors when available.'**
  String get useSystemColorDescription;

  /// No description provided for @systemColorNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Dynamic colors not supported on this device.'**
  String get systemColorNotAvailable;

  /// No description provided for @showHourlyTemperature.
  ///
  /// In en, this message translates to:
  /// **'Show hourly temperature'**
  String get showHourlyTemperature;

  /// No description provided for @showAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Show air quality'**
  String get showAirQuality;

  /// No description provided for @temperatureUnitCelsius.
  ///
  /// In en, this message translates to:
  /// **'Temperature unit (°C)'**
  String get temperatureUnitCelsius;

  /// No description provided for @celsiusFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Toggle between Celsius and Fahrenheit'**
  String get celsiusFahrenheit;

  /// No description provided for @defaultCity.
  ///
  /// In en, this message translates to:
  /// **'Default city'**
  String get defaultCity;

  /// No description provided for @setCurrentCityAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set current city as default'**
  String get setCurrentCityAsDefault;

  /// No description provided for @currentCity.
  ///
  /// In en, this message translates to:
  /// **'Current city: {city}'**
  String currentCity(Object city);

  /// No description provided for @defaultCitySetTo.
  ///
  /// In en, this message translates to:
  /// **'Default city set to {city}'**
  String defaultCitySetTo(Object city);

  /// No description provided for @goToDefaultCity.
  ///
  /// In en, this message translates to:
  /// **'Go to default city'**
  String get goToDefaultCity;

  /// No description provided for @currentDefault.
  ///
  /// In en, this message translates to:
  /// **'Current default: {city}'**
  String currentDefault(Object city);

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are currently disabled.'**
  String get locationPermissionDenied;

  /// No description provided for @requestAgain.
  ///
  /// In en, this message translates to:
  /// **'Request again'**
  String get requestAgain;

  /// No description provided for @dontShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show again'**
  String get dontShowAgain;

  /// No description provided for @weatherly.
  ///
  /// In en, this message translates to:
  /// **'Weatherly'**
  String get weatherly;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @enterCityName.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get enterCityName;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @startBySearching.
  ///
  /// In en, this message translates to:
  /// **'Start by searching for a city to see weather details.'**
  String get startBySearching;

  /// No description provided for @forecastSearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search for a city first to see the forecast.'**
  String get forecastSearchPrompt;

  /// No description provided for @fiveDayForecast.
  ///
  /// In en, this message translates to:
  /// **'5-day outlook'**
  String get fiveDayForecast;

  /// No description provided for @hourlyTemperatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Hourly temperature'**
  String get hourlyTemperatureTitle;

  /// No description provided for @dailyForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily forecast'**
  String get dailyForecastTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @airQualityIndex.
  ///
  /// In en, this message translates to:
  /// **'Air Quality Index'**
  String get airQualityIndex;

  /// No description provided for @airQualityGuide.
  ///
  /// In en, this message translates to:
  /// **'Air quality guide'**
  String get airQualityGuide;

  /// No description provided for @aqiStatusVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get aqiStatusVeryGood;

  /// No description provided for @aqiRecommendationNormal.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your outdoor activities.'**
  String get aqiRecommendationNormal;

  /// No description provided for @aqiStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get aqiStatusGood;

  /// No description provided for @aqiRecommendationCaution.
  ///
  /// In en, this message translates to:
  /// **'Sensitive groups should limit extended outdoor exertion.'**
  String get aqiRecommendationCaution;

  /// No description provided for @aqiStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiStatusModerate;

  /// No description provided for @aqiRecommendationAvoid.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing heavy outdoor activity.'**
  String get aqiRecommendationAvoid;

  /// No description provided for @aqiStatusPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get aqiStatusPoor;

  /// No description provided for @aqiRecommendationMask.
  ///
  /// In en, this message translates to:
  /// **'Wear a mask outdoors if possible.'**
  String get aqiRecommendationMask;

  /// No description provided for @aqiStatusVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very poor'**
  String get aqiStatusVeryPoor;

  /// No description provided for @aqiRecommendationNoActivity.
  ///
  /// In en, this message translates to:
  /// **'Avoid outdoor activities.'**
  String get aqiRecommendationNoActivity;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @systemColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use wallpaper colors (Android 12+)'**
  String get systemColorSubtitle;

  /// No description provided for @chooseStaticColor.
  ///
  /// In en, this message translates to:
  /// **'Or choose a static color'**
  String get chooseStaticColor;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @pinnedLocations.
  ///
  /// In en, this message translates to:
  /// **'Pinned Locations'**
  String get pinnedLocations;

  /// No description provided for @recentLocations.
  ///
  /// In en, this message translates to:
  /// **'Recent Locations'**
  String get recentLocations;

  /// No description provided for @weatherProvider.
  ///
  /// In en, this message translates to:
  /// **'Weather Provider'**
  String get weatherProvider;

  /// No description provided for @weatherProviderDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred weather data source'**
  String get weatherProviderDescription;

  /// No description provided for @accuweather.
  ///
  /// In en, this message translates to:
  /// **'AccuWeather'**
  String get accuweather;

  /// No description provided for @openweathermap.
  ///
  /// In en, this message translates to:
  /// **'OpenWeatherMap'**
  String get openweathermap;

  /// No description provided for @displayEffects.
  ///
  /// In en, this message translates to:
  /// **'Display Effects'**
  String get displayEffects;

  /// No description provided for @blurEnabled.
  ///
  /// In en, this message translates to:
  /// **'Blur enabled'**
  String get blurEnabled;

  /// No description provided for @blurDisabled.
  ///
  /// In en, this message translates to:
  /// **'Blur disabled'**
  String get blurDisabled;

  /// No description provided for @blurDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable glass blur background'**
  String get blurDescription;

  /// No description provided for @materialDescription.
  ///
  /// In en, this message translates to:
  /// **'Disable blur and use Material surfaces'**
  String get materialDescription;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['fa', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fa': return AppLocalizationsFa();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
