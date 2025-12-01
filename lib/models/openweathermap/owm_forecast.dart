class OwmForecast {
  final int timestamp;
  final double temperature;
  final double feelsLike;
  final String weatherIcon;
  final String weatherDescription;
  final int humidity;
  final double windSpeed;
  final int cloudiness;
  final double? rain3h;

  OwmForecast({
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.weatherIcon,
    required this.weatherDescription,
    required this.humidity,
    required this.windSpeed,
    required this.cloudiness,
    this.rain3h,
  });

  factory OwmForecast.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List?)?.first ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final clouds = json['clouds'] ?? {};
    final rain = json['rain'] as Map<String, dynamic>?;

    return OwmForecast(
      timestamp: json['dt'] ?? 0,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      weatherIcon: weather['icon'] ?? '',
      weatherDescription: weather['description'] ?? '',
      humidity: main['humidity'] ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      cloudiness: clouds['all'] ?? 0,
      rain3h: (rain?['3h'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': timestamp,
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
      },
      'weather': [
        {'icon': weatherIcon, 'description': weatherDescription},
      ],
      'wind': {'speed': windSpeed},
      'clouds': {'all': cloudiness},
      if (rain3h != null) 'rain': {'3h': rain3h},
    };
  }

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
