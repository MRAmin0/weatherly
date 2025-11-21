// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'هوانما';

  @override
  String get settings => 'تنظیمات';

  @override
  String get language => 'زبان';

  @override
  String get developer => 'توسعه‌دهنده';

  @override
  String get reportAnIssue => 'گزارش مشکل';

  @override
  String get contactViaEmail => 'ارتباط با ایمیل';

  @override
  String get changelog => 'تغییرات نسخه‌ها';

  @override
  String get appVersion => 'نسخه برنامه';

  @override
  String get versionHistory => 'تاریخچه نسخه‌ها';

  @override
  String get readingVersion => 'در حال خواندن نسخه...';

  @override
  String get aboutApp => 'درباره برنامه';

  @override
  String get appDescription => 'ودرلی به شما کمک می‌کند وضعیت آب‌وهوا را با رابط کاربری زیبا مشاهده کنید.';

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
  String get english => 'انگلیسی';

  @override
  String get displayMode => 'حالت نمایش';

  @override
  String get system => 'مطابق سیستم';

  @override
  String get light => 'روشن';

  @override
  String get dark => 'تاریک';

  @override
  String get advancedSettings => 'تنظیمات پیشرفته';

  @override
  String get themeAccentColor => 'تم رابط کاربری';

  @override
  String get customizeThemeDescription => 'رنگ دلخواهت را برای هوانما انتخاب کن.';

  @override
  String get useSystemColor => 'استفاده از رنگ سیستم';

  @override
  String get useSystemColorDescription => 'در صورت پشتیبانی، از رنگ‌های پویا متریال یو استفاده کن.';

  @override
  String get systemColorNotAvailable => 'رنگ‌های پویا در این دستگاه پشتیبانی نمی‌شوند.';

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
  String get setCurrentCityAsDefault => 'تنظیم شهر فعلی به‌عنوان پیش‌فرض';

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
  String get nothingFound => 'موردی پیدا نشد';

  @override
  String get clearAll => 'حذف همه';

  @override
  String get locationPermissionDenied => 'دسترسی به موقعیت مکانی شما غیرفعال می‌باشد';

  @override
  String get requestAgain => 'درخواست مجدد';

  @override
  String get dontShowAgain => 'دیگر نشان نده';

  @override
  String get weatherly => 'هوانما';

  @override
  String get searching => 'در حال جستجو...';

  @override
  String get enterCityName => 'نام شهر را وارد کنید';

  @override
  String get unknown => 'نامشخص';

  @override
  String get clear => 'پاک کردن';

  @override
  String get startBySearching => 'برای مشاهده وضعیت هوا، نام یک شهر را جستجو کنید.';

  @override
  String get forecastSearchPrompt => 'برای مشاهده پیش‌بینی، ابتدا شهر مورد نظر را جستجو کنید.';

  @override
  String get fiveDayForecast => 'پیش‌بینی ۵ روز آینده';

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
  String get aqiRecommendationNormal => 'با خیال راحت فعالیت‌های بیرونی انجام دهید.';

  @override
  String get aqiStatusGood => 'خوب';

  @override
  String get aqiRecommendationCaution => 'گروه‌های حساس فعالیت طولانی بیرون را کاهش دهند.';

  @override
  String get aqiStatusModerate => 'متوسط';

  @override
  String get aqiRecommendationAvoid => 'فعالیت سنگین بیرون را کمتر کنید.';

  @override
  String get aqiStatusPoor => 'ضعیف';

  @override
  String get aqiRecommendationMask => 'در صورت امکان از ماسک هنگام خروج استفاده کنید.';

  @override
  String get aqiStatusVeryPoor => 'خیلی ضعیف';

  @override
  String get aqiRecommendationNoActivity => 'از فعالیت‌های بیرونی خودداری کنید.';
}
