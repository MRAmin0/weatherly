class AccuCurrentConditions {
  final String weatherText;
  final double temperature;
  final double realFeel;
  final int relativeHumidity;
  final double dewPoint;
  final double windSpeed;
  final String windDirection;
  final int uvIndex;
  final String uvIndexText;
  final double visibility;
  final int cloudCover;
  final double pressure;
  final String pressureTendency;
  final double? rainLastHour; // PrecipitationSummary.Precipitation.Metric.Value
  final double?
  tempMin24h; // TemperatureSummary.Past24HourRange.Minimum.Metric.Value
  final double?
  tempMax24h; // TemperatureSummary.Past24HourRange.Maximum.Metric.Value
  final String link;

  AccuCurrentConditions({
    required this.weatherText,
    required this.temperature,
    required this.realFeel,
    required this.relativeHumidity,
    required this.dewPoint,
    required this.windSpeed,
    required this.windDirection,
    required this.uvIndex,
    required this.uvIndexText,
    required this.visibility,
    required this.cloudCover,
    required this.pressure,
    required this.pressureTendency,
    this.rainLastHour,
    this.tempMin24h,
    this.tempMax24h,
    required this.link,
  });

  factory AccuCurrentConditions.fromJson(Map<String, dynamic> json) {
    return AccuCurrentConditions(
      weatherText: json['WeatherText'] ?? '',
      temperature:
          (json['Temperature']?['Metric']?['Value'] as num?)?.toDouble() ?? 0.0,
      realFeel:
          (json['RealFeelTemperature']?['Metric']?['Value'] as num?)
              ?.toDouble() ??
          0.0,
      relativeHumidity: json['RelativeHumidity'] ?? 0,
      dewPoint:
          (json['DewPoint']?['Metric']?['Value'] as num?)?.toDouble() ?? 0.0,
      windSpeed:
          (json['Wind']?['Speed']?['Metric']?['Value'] as num?)?.toDouble() ??
          0.0,
      windDirection: json['Wind']?['Direction']?['English'] ?? '',
      uvIndex: json['UVIndex'] ?? 0,
      uvIndexText: json['UVIndexText'] ?? '',
      visibility:
          (json['Visibility']?['Metric']?['Value'] as num?)?.toDouble() ?? 0.0,
      cloudCover: json['CloudCover'] ?? 0,
      pressure:
          (json['Pressure']?['Metric']?['Value'] as num?)?.toDouble() ?? 0.0,
      pressureTendency: json['PressureTendency']?['LocalizedText'] ?? '',
      rainLastHour:
          (json['PrecipitationSummary']?['Precipitation']?['Metric']?['Value']
                  as num?)
              ?.toDouble(),
      tempMin24h:
          (json['TemperatureSummary']?['Past24HourRange']?['Minimum']?['Metric']?['Value']
                  as num?)
              ?.toDouble(),
      tempMax24h:
          (json['TemperatureSummary']?['Past24HourRange']?['Maximum']?['Metric']?['Value']
                  as num?)
              ?.toDouble(),
      link: json['Link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'WeatherText': weatherText,
      'Temperature': {
        'Metric': {'Value': temperature},
      },
      'RealFeelTemperature': {
        'Metric': {'Value': realFeel},
      },
      'RelativeHumidity': relativeHumidity,
      'DewPoint': {
        'Metric': {'Value': dewPoint},
      },
      'Wind': {
        'Speed': {
          'Metric': {'Value': windSpeed},
        },
        'Direction': {'English': windDirection},
      },
      'UVIndex': uvIndex,
      'UVIndexText': uvIndexText,
      'Visibility': {
        'Metric': {'Value': visibility},
      },
      'CloudCover': cloudCover,
      'Pressure': {
        'Metric': {'Value': pressure},
      },
      'PressureTendency': {'LocalizedText': pressureTendency},
      'PrecipitationSummary': {
        'Precipitation': {
          'Metric': {'Value': rainLastHour},
        },
      },
      'TemperatureSummary': {
        'Past24HourRange': {
          'Minimum': {
            'Metric': {'Value': tempMin24h},
          },
          'Maximum': {
            'Metric': {'Value': tempMax24h},
          },
        },
      },
      'Link': link,
    };
  }
}
