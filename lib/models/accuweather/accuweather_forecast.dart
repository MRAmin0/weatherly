class AccuDailyForecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final int dayIcon;
  final int nightIcon;
  final String phrase;
  final int precipitationProbability;
  final String dayIconPhrase;
  final String nightIconPhrase;

  AccuDailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.dayIcon,
    required this.nightIcon,
    required this.phrase,
    required this.precipitationProbability,
    required this.dayIconPhrase,
    required this.nightIconPhrase,
  });

  factory AccuDailyForecast.fromJson(Map<String, dynamic> json) {
    return AccuDailyForecast(
      date: json['Date'] ?? '',
      minTemp:
          (json['Temperature']?['Minimum']?['Value'] as num?)?.toDouble() ??
          0.0,
      maxTemp:
          (json['Temperature']?['Maximum']?['Value'] as num?)?.toDouble() ??
          0.0,
      dayIcon: json['Day']?['Icon'] ?? 0,
      nightIcon: json['Night']?['Icon'] ?? 0,
      phrase: json['Day']?['IconPhrase'] ?? '',
      precipitationProbability: json['Day']?['PrecipitationProbability'] ?? 0,
      dayIconPhrase: json['Day']?['IconPhrase'] ?? '',
      nightIconPhrase: json['Night']?['IconPhrase'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Date': date,
      'Temperature': {
        'Minimum': {'Value': minTemp},
        'Maximum': {'Value': maxTemp},
      },
      'Day': {
        'Icon': dayIcon,
        'IconPhrase': dayIconPhrase,
        'PrecipitationProbability': precipitationProbability,
      },
      'Night': {'Icon': nightIcon, 'IconPhrase': nightIconPhrase},
    };
  }
}
