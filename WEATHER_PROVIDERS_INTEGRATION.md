# AccuWeather & OpenWeatherMap Integration

## Overview

This document describes the integration of two separate weather providers into the Weatherly Flutter app:

1. **AccuWeather API** - Current Conditions + 5-Day Forecast
2. **OpenWeatherMap API** - Current Weather + 5-Day/3-Hour Forecast

## Folder Structure

```
lib/
 ├─ data/
 │   └─ services/
 │        ├─ accuweather_service.dart          ✓ Created
 │        └─ openweathermap_service.dart       ✓ Created
 │
 ├─ models/
 │    ├─ accuweather/
 │    │     ├─ accuweather_current.dart        ✓ Created
 │    │     └─ accuweather_forecast.dart       ✓ Created
 │    └─ openweathermap/
 │          ├─ owm_current.dart                ✓ Created
 │          └─ owm_forecast.dart               ✓ Created
 │
 ├─ viewmodels/
 │    ├─ accuweather_viewmodel.dart            ✓ Created
 │    └─ openweathermap_viewmodel.dart         ✓ Created
 │
 └─ presentation/
      └─ screens/
            ├─ accuweather_screen.dart          ✓ Created
            └─ openweathermap_screen.dart       ✓ Created
```

## Implementation Details

### 1. AccuWeather Integration

#### Models (`lib/models/accuweather/`)

- **accuweather_current.dart**: Current conditions model with fields:

  - weatherText, temperature, realFeel, humidity, dewPoint
  - windSpeed, windDirection, uvIndex, visibility, cloudCover
  - pressure, pressureTendency, rainLastHour, tempMin24h, tempMax24h

- **accuweather_forecast.dart**: Daily forecast model with fields:
  - date, minTemp, maxTemp, dayIcon, nightIcon
  - phrase, precipitationProbability

#### Service (`lib/data/services/accuweather_service.dart`)

- `getCurrent(String locationKey)` - Fetches current conditions with details=true
- `getForecast5Day(String locationKey)` - Fetches 5-day forecast with metric units
- Uses ConfigReader for API key management
- Includes timeout handling (10 seconds)

#### ViewModel (`lib/viewmodels/accuweather_viewmodel.dart`)

- Extends ChangeNotifier for state management
- Manages loading, error, current conditions, and forecast state
- Hardcoded location key: 210841 (Tehran)
- Fetches both current and forecast in parallel

#### Screen (`lib/presentation/screens/accuweather_screen.dart`)

- Displays current conditions in a card with all details
- Shows 5-day forecast list with min/max temps and precipitation
- Includes pull-to-refresh functionality
- Error handling with retry button

### 2. OpenWeatherMap Integration

#### Models (`lib/models/openweathermap/`)

- **owm_current.dart**: Current weather model with fields:

  - description, temperature, feelsLike, humidity
  - windSpeed, visibility, cloudiness, pressure

- **owm_forecast.dart**: Forecast model with fields:
  - timestamp, temperature, feelsLike, weatherIcon
  - weatherDescription, humidity, windSpeed, cloudiness, rain3h

#### Service (`lib/data/services/openweathermap_service.dart`)

- `getCurrent(double lat, double lon)` - Fetches current weather
- `getForecast(double lat, double lon)` - Fetches 5-day/3-hour forecast
- Uses metric units
- Includes timeout handling (10 seconds)

#### ViewModel (`lib/viewmodels/openweathermap_viewmodel.dart`)

- Extends ChangeNotifier for state management
- Manages loading, error, current weather, and forecast state
- Default coordinates: Tehran (35.6892, 51.3890)
- Fetches both current and forecast in parallel

#### Screen (`lib/presentation/screens/openweathermap_screen.dart`)

- Displays current weather with all details
- Shows 5-day/3-hour forecast grouped by day
- Includes weather icons based on icon codes
- Pull-to-refresh functionality
- Error handling with retry button

### 3. Home Page Integration

Updated `lib/presentation/screens/home/home_page.dart`:

- Added two provider cards below the main weather content
- **AccuWeather** card (orange, sunny icon)
- **OpenWeatherMap** card (blue, cloud icon)
- Each card navigates to its respective screen
- Clean, Material 3 styled cards

### 4. Configuration

API keys are managed through `ConfigReader`:

- `accuWeatherApiKey` - AccuWeather API key
- `openWeatherApiKey` - OpenWeatherMap API key

Both are loaded from `assets/config/keys.json`:

```json
{
  "accu_weather_api_key": "YOUR_ACCUWEATHER_KEY",
  "open_weather_api_key": "YOUR_OPENWEATHER_KEY"
}
```

## Key Features

✓ **Clean Architecture**: Separated models, services, viewmodels, and screens
✓ **Isolated Providers**: Each provider is completely independent
✓ **Error Handling**: Proper timeout and error handling in all services
✓ **State Management**: Uses existing Provider/ChangeNotifier pattern
✓ **Material 3 Design**: Consistent with Weatherly's existing theme
✓ **Pull-to-Refresh**: Both screens support refresh gesture
✓ **Parallel Fetching**: Current and forecast data fetched simultaneously
✓ **No Breaking Changes**: Existing Weatherly functionality remains intact

## Testing

To test the integration:

1. Ensure API keys are set in `assets/config/keys.json`
2. Run `flutter run`
3. From the Home screen, scroll down to see "Weather Providers"
4. Tap "AccuWeather" to view AccuWeather data
5. Tap "OpenWeather" to view OpenWeatherMap data
6. Both screens should load and display real-time data

## Branch

All changes applied to the current feature branch (dev).
No modifications to main/master branch.
