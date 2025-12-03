class CitySearchResult {
  final String key;
  final String localizedName;
  final String countryId;
  final String administrativeAreaId;

  CitySearchResult({
    required this.key,
    required this.localizedName,
    required this.countryId,
    required this.administrativeAreaId,
  });

  factory CitySearchResult.fromJson(Map<String, dynamic> json) {
    return CitySearchResult(
      key: json['Key'] ?? '',
      localizedName: json['LocalizedName'] ?? '',
      countryId: json['Country']?['ID'] ?? '',
      administrativeAreaId: json['AdministrativeArea']?['ID'] ?? '',
    );
  }
}

class CurrentConditions {
  final String weatherText;
  final bool hasPrecipitation;
  final double temperatureMetric;
  final String temperatureUnit;

  CurrentConditions({
    required this.weatherText,
    required this.hasPrecipitation,
    required this.temperatureMetric,
    required this.temperatureUnit,
  });

  factory CurrentConditions.fromJson(Map<String, dynamic> json) {
    return CurrentConditions(
      weatherText: json['WeatherText'] ?? '',
      hasPrecipitation: json['HasPrecipitation'] ?? false,
      temperatureMetric:
          json['Temperature']?['Metric']?['Value']?.toDouble() ?? 0.0,
      temperatureUnit: json['Temperature']?['Metric']?['Unit'] ?? 'C',
    );
  }
}

class DailyForecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String dayIconPhrase;
  final String nightIconPhrase;

  DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.dayIconPhrase,
    required this.nightIconPhrase,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: json['Date'] ?? '',
      minTemp: json['Temperature']?['Minimum']?['Value']?.toDouble() ?? 0.0,
      maxTemp: json['Temperature']?['Maximum']?['Value']?.toDouble() ?? 0.0,
      dayIconPhrase: json['Day']?['IconPhrase'] ?? '',
      nightIconPhrase: json['Night']?['IconPhrase'] ?? '',
    );
  }
}
