enum WeatherType {
  clear,
  clouds,
  rain,
  drizzle,
  thunderstorm,
  snow,
  mist,
  smoke,
  haze,
  fog,
  sand,
  dust,
  ash,
  squall,
  tornado,
  atmosphere,
  windy,
  unknown,
}

WeatherType mapWeatherType(String main) {
  switch (main.toLowerCase()) {
    case 'clear':
      return WeatherType.clear;
    case 'clouds':
      return WeatherType.clouds;
    case 'rain':
      return WeatherType.rain;
    case 'drizzle':
      return WeatherType.drizzle;
    case 'thunderstorm':
      return WeatherType.thunderstorm;
    case 'snow':
      return WeatherType.snow;
    case 'mist':
    case 'smoke':
    case 'haze':
    case 'fog':
    case 'sand':
    case 'dust':
    case 'ash':
    case 'squall':
    case 'tornado':
    case 'atmosphere':
      return WeatherType.mist;
    default:
      return WeatherType.unknown;
  }
}
