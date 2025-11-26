// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'ودرلی';

  @override
  String get settings => 'تنظیمات';

  @override
  String get language => 'زبان';

  @override
  String get developer => 'توسعه‌دهنده';

  @override
  String get developerName => 'امین مناجاتی';

  @override
  String get reportAnIssue => 'گزارش مشکل';

  @override
  String get contactViaEmail => 'تماس از طریق ایمیل';

  @override
  String get changelog => 'تغییرات';

  @override
  String get appVersion => 'نسخه برنامه';

  @override
  String get versionHistory => 'تاریخچه نسخه‌ها';

  @override
  String get readingVersion => 'در حال خواندن نسخه...';

  @override
  String get aboutApp => 'درباره برنامه';

  @override
  String get appDescription =>
      'ودرلی به شما کمک می‌کند وضعیت آب‌وهوا را با رابط کاربری زیبا چک کنید.';

  @override
  String get projectOnGithub => 'پروژه در گیت‌هاب';

  @override
  String get close => 'بستن';

  @override
  String get home => 'خانه';

  @override
  String get forecast => 'پیش‌بینی';

  @override
  String get persian => 'فارسی';

  @override
  String get english => 'English';

  @override
  String get displayMode => 'حالت نمایش';

  @override
  String get system => 'سیستم';

  @override
  String get light => 'روشن';

  @override
  String get dark => 'تاریک';

  @override
  String get advancedSettings => 'تنظیمات پیشرفته';

  @override
  String get themeAccentColor => 'رنگ پوسته';

  @override
  String get customizeThemeDescription =>
      'رنگی را برای شخصی‌سازی ودرلی انتخاب کنید.';

  @override
  String get useSystemColor => 'استفاده از رنگ سیستم';

  @override
  String get useSystemColorDescription =>
      'استفاده از رنگ‌های متریال Dynamic در صورت موجود بودن.';

  @override
  String get systemColorNotAvailable =>
      'رنگ‌های داینامیک در این دستگاه پشتیبانی نمی‌شود.';

  @override
  String get showHourlyTemperature => 'نمایش دمای ساعتی';

  @override
  String get showAirQuality => 'نمایش کیفیت هوا';

  @override
  String get temperatureUnitCelsius => 'واحد دما (°C)';

  @override
  String get celsiusFahrenheit => 'تغییر بین سلسیوس و فارنهایت';

  @override
  String get defaultCity => 'شهر پیش‌فرض';

  @override
  String get setCurrentCityAsDefault => 'تنظیم شهر فعلی به عنوان پیش‌فرض';

  @override
  String currentCity(Object city) {
    return 'شهر فعلی: $city';
  }

  @override
  String defaultCitySetTo(Object city) {
    return 'شهر پیش‌فرض روی $city تنظیم شد';
  }

  @override
  String get goToDefaultCity => 'رفتن به شهر پیش‌فرض';

  @override
  String currentDefault(Object city) {
    return 'پیش‌فرض فعلی: $city';
  }

  @override
  String get recentSearches => 'جستجوهای اخیر';

  @override
  String get nothingFound => 'چیزی پیدا نشد';

  @override
  String get clearAll => 'پاک کردن همه';

  @override
  String get locationPermissionDenied => 'دسترسی موقعیت مکانی غیرفعال است.';

  @override
  String get requestAgain => 'درخواست مجدد';

  @override
  String get dontShowAgain => 'دیگر نشان نده';

  @override
  String get weatherly => 'ودرلی';

  @override
  String get searching => 'در حال جستجو...';

  @override
  String get enterCityName => 'نام شهر را وارد کنید';

  @override
  String get unknown => 'نامشخص';

  @override
  String get clear => 'پاک کردن';

  @override
  String get startBySearching =>
      'برای مشاهده جزئیات آب‌وهوا، نام شهری را جستجو کنید.';

  @override
  String get forecastSearchPrompt =>
      'برای مشاهده پیش‌بینی، ابتدا یک شهر را جستجو کنید.';

  @override
  String get fiveDayForecast => 'چشم‌انداز ۵ روزه';

  @override
  String get hourlyTemperatureTitle => 'دمای ساعتی';

  @override
  String get dailyForecastTitle => 'پیش‌بینی روزانه';

  @override
  String get today => 'امروز';

  @override
  String get airQualityIndex => 'شاخص کیفیت هوا';

  @override
  String get airQualityGuide => 'راهنمای کیفیت هوا';

  @override
  String get aqiStatusVeryGood => 'بسیار خوب';

  @override
  String get aqiRecommendationNormal => 'از فعالیت‌های خارج از منزل لذت ببرید.';

  @override
  String get aqiStatusGood => 'خوب';

  @override
  String get aqiRecommendationCaution =>
      'گروه‌های حساس باید فعالیت طولانی‌مدت در فضای باز را محدود کنند.';

  @override
  String get aqiStatusModerate => 'متوسط';

  @override
  String get aqiRecommendationAvoid =>
      'بهتر است فعالیت سنگین در فضای باز را کاهش دهید.';

  @override
  String get aqiStatusPoor => 'ناسالم';

  @override
  String get aqiRecommendationMask =>
      'در صورت امکان در فضای باز از ماسک استفاده کنید.';

  @override
  String get aqiStatusVeryPoor => 'بسیار ناسالم';

  @override
  String get aqiRecommendationNoActivity =>
      'از فعالیت در فضای باز خودداری کنید.';

  @override
  String get themeColor => 'رنگ پوسته';

  @override
  String get systemColorSubtitle => 'استفاده از رنگ‌های پس‌زمینه (اندروید ۱۲+)';

  @override
  String get chooseStaticColor => 'یا یک رنگ ثابت انتخاب کنید';

  @override
  String get menu => 'منو';

  @override
  String get pinnedLocations => 'مکان‌های سنجاق‌شده';

  @override
  String get recentLocations => 'مکان‌های اخیر';
}
