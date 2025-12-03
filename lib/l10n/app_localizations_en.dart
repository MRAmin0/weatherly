// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Weatherly';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get developer => 'Developer';

  @override
  String get developerName => 'Amin Monajati';

  @override
  String get reportAnIssue => 'Report an issue';

  @override
  String get contactViaEmail => 'Contact via email';

  @override
  String get changelog => 'Changelog';

  @override
  String get appVersion => 'App Version';

  @override
  String get versionHistory => 'Version History';

  @override
  String get readingVersion => 'Reading version...';

  @override
  String get aboutApp => 'About the App';

  @override
  String get appDescription => 'Weatherly helps you check weather conditions with beautiful UI.';

  @override
  String get projectOnGithub => 'Project on GitHub';

  @override
  String get close => 'Close';

  @override
  String get home => 'Home';

  @override
  String get forecast => 'Forecast';

  @override
  String get persian => 'Persian';

  @override
  String get english => 'English';

  @override
  String get displayMode => 'Display mode';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get advancedSettings => 'Advanced settings';

  @override
  String get themeAccentColor => 'UI theme color';

  @override
  String get customizeThemeDescription => 'Pick a color you like to personalize Weatherly.';

  @override
  String get useSystemColor => 'Use System Color';

  @override
  String get useSystemColorDescription => 'Use Material You dynamic colors when available.';

  @override
  String get systemColorNotAvailable => 'Dynamic colors not supported on this device.';

  @override
  String get showHourlyTemperature => 'Show hourly temperature';

  @override
  String get showAirQuality => 'Show air quality';

  @override
  String get temperatureUnitCelsius => 'Temperature unit (°C)';

  @override
  String get celsiusFahrenheit => 'Toggle between Celsius and Fahrenheit';

  @override
  String get defaultCity => 'Default city';

  @override
  String get setCurrentCityAsDefault => 'Set current city as default';

  @override
  String currentCity(Object city) {
    return 'Current city: $city';
  }

  @override
  String defaultCitySetTo(Object city) {
    return 'Default city set to $city';
  }

  @override
  String get goToDefaultCity => 'Go to default city';

  @override
  String currentDefault(Object city) {
    return 'Current default: $city';
  }

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get clearAll => 'Clear all';

  @override
  String get locationPermissionDenied => 'Location permissions are currently disabled.';

  @override
  String get requestAgain => 'Request again';

  @override
  String get dontShowAgain => 'Don\'t show again';

  @override
  String get weatherly => 'Weatherly';

  @override
  String get searching => 'Searching...';

  @override
  String get enterCityName => 'Enter city name';

  @override
  String get unknown => 'Unknown';

  @override
  String get clear => 'Clear';

  @override
  String get startBySearching => 'Start by searching for a city to see weather details.';

  @override
  String get forecastSearchPrompt => 'Search for a city first to see the forecast.';

  @override
  String get fiveDayForecast => '5-day outlook';

  @override
  String get hourlyTemperatureTitle => 'Hourly temperature';

  @override
  String get dailyForecastTitle => 'Daily forecast';

  @override
  String get today => 'Today';

  @override
  String get airQualityIndex => 'Air Quality Index';

  @override
  String get airQualityGuide => 'Air quality guide';

  @override
  String get aqiStatusVeryGood => 'Very good';

  @override
  String get aqiRecommendationNormal => 'Enjoy your outdoor activities.';

  @override
  String get aqiStatusGood => 'Good';

  @override
  String get aqiRecommendationCaution => 'Sensitive groups should limit extended outdoor exertion.';

  @override
  String get aqiStatusModerate => 'Moderate';

  @override
  String get aqiRecommendationAvoid => 'Consider reducing heavy outdoor activity.';

  @override
  String get aqiStatusPoor => 'Poor';

  @override
  String get aqiRecommendationMask => 'Wear a mask outdoors if possible.';

  @override
  String get aqiStatusVeryPoor => 'Very poor';

  @override
  String get aqiRecommendationNoActivity => 'Avoid outdoor activities.';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get systemColorSubtitle => 'Use wallpaper colors (Android 12+)';

  @override
  String get chooseStaticColor => 'Or choose a static color';

  @override
  String get menu => 'Menu';

  @override
  String get pinnedLocations => 'Pinned Locations';

  @override
  String get recentLocations => 'Recent Locations';

  @override
  String get weatherProvider => 'Weather Provider';

  @override
  String get weatherProviderDescription => 'Choose your preferred weather data source';

  @override
  String get accuweather => 'AccuWeather';

  @override
  String get openweathermap => 'OpenWeatherMap';

  @override
  String get displayEffects => 'Display Effects';

  @override
  String get blurEnabled => 'Blur enabled';

  @override
  String get blurDisabled => 'Blur disabled';

  @override
  String get blurDescription => 'Enable glass blur background';

  @override
  String get materialDescription => 'Disable blur and use Material surfaces';
}
