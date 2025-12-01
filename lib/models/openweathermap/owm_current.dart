class OwmCurrent {
  final String description;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int cloudiness;
  final double pressure;
  final String weatherIcon;
  final String weatherMain;

  OwmCurrent({
    required this.description,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
    required this.cloudiness,
    required this.pressure,
    required this.weatherIcon,
    required this.weatherMain,
  });

  factory OwmCurrent.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List?)?.first ?? {};
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final clouds = json['clouds'] ?? {};

    return OwmCurrent(
      description: weather['description'] ?? '',
      weatherMain: weather['main'] ?? '',
      weatherIcon: weather['icon'] ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: main['humidity'] ?? 0,
      pressure: (main['pressure'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 0.0,
      cloudiness: clouds['all'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather': [
        {'description': description, 'main': weatherMain, 'icon': weatherIcon},
      ],
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'humidity': humidity,
        'pressure': pressure,
      },
      'wind': {'speed': windSpeed},
      'visibility': visibility,
      'clouds': {'all': cloudiness},
    };
  }
}
