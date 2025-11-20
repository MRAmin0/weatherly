// **مهم:** برای اجرای این کد، لطفا پکیج زیر را به فایل pubspec.yaml اضافه کنید:
// dependencies:
//   ...
//   simple_animations: ^5.0.1
// و سپس دستور flutter pub get را در ترمینال اجرا کنید.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:simple_animations/simple_animations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weatherly',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey),
          labelStyle: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: _themeMode,
      home: WeatherScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _changeTheme,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const WeatherScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _location = 'Tehran';
  double? _temperature;
  String _weatherDescription = '';
  bool _isLoading = true;
  final TextEditingController _cityController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;
  List<dynamic> _forecast = [];

  @override
  void initState() {
    super.initState();
    _fetchWeatherAndForecast(cityName: _location);
    _cityController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _cityController.removeListener(_onSearchChanged);
    _cityController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchWeatherAndForecast(
      {String? cityName, double? lat, double? lon}) async {
    if (!mounted) return;
    if (!_isLoading) setState(() => _isLoading = true);

    const apiKey = 'YOUR_API_KEY_HERE'; // لطفا کلید API خود را اینجا قرار دهید
    String weatherUrl;
    String forecastUrl;

    if (lat != null && lon != null) {
      weatherUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      forecastUrl =
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    } else if (cityName != null) {
      weatherUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey&units=metric';
      forecastUrl =
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric';
    } else {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final weatherResponse = await http.get(Uri.parse(weatherUrl));
      final forecastResponse = await http.get(Uri.parse(forecastUrl));

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200 &&
          mounted) {
        final weatherData = json.decode(weatherResponse.body);
        final forecastData = json.decode(forecastResponse.body);

        final dailyForecast = (forecastData['list'] as List)
            .where((item) => item['dt_txt'].toString().contains('12:00:00'))
            .toList();

        setState(() {
          _location = weatherData['name'];
          _temperature = weatherData['main']['temp'];
          _weatherDescription = weatherData['weather'][0]['main'];
          _forecast = dailyForecast;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _weatherDescription = 'City not found!';
          _temperature = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weatherDescription = 'Failed to load data';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _cityController.text;
      // **تغییر اصلی:** فیلتر حروف انگلیسی حذف شد تا همه زبان‌ها پشتیبانی شوند
      if (query.length > 2) {
        _fetchCitySuggestions(query);
      } else {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _fetchCitySuggestions(String query) async {
    const apiKey = 'YOUR_API_KEY_HERE'; // لطفا کلید API خود را اینجا قرار دهید
    final url =
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body) as List;
        setState(() => _suggestions = data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      /* خطا را نادیده می‌گیریم */
    }
  }

  void _selectCity(Map<String, dynamic> cityData) {
    if (!mounted) return;
    final lat = cityData['lat'];
    final lon = cityData['lon'];
    final name = cityData['name'];

    setState(() {
      _location = name;
      _suggestions = [];
    });
    _cityController.clear();
    FocusScope.of(context).unfocus();

    _fetchWeatherAndForecast(lat: lat, lon: lon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSettingsDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weatherly'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_weatherDescription.isNotEmpty)
            WeatherBackground(weatherType: _weatherDescription),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchSection(),
                  const SizedBox(height: 40),
                  if (!_isLoading) ...[
                    _buildCurrentWeatherSection(),
                    const SizedBox(height: 40),
                    if (_forecast.isNotEmpty) _buildForecastSection(),
                  ]
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha((0.5 * 255).round()),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.titleLarge),
                const Divider(),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.phone_iphone),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {widget.currentThemeMode},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      widget.onThemeChanged(selection.first);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        GlassmorphicContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    style: const TextStyle(color: Colors.white),
                    // **تغییرات اصلی اینجا اعمال شده**
                    maxLength: 15, // محدودیت تعداد کاراکتر
                    // فیلتر حروف حذف شد تا همه زبان‌ها پشتیبانی شوند
                    // inputFormatters: [], 
                    decoration: const InputDecoration(
                      hintText: 'e.g., London',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      counterText: "", // شمارنده کاراکتر را مخفی می‌کند
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    if (_suggestions.isNotEmpty) {
                      _selectCity(_suggestions.first);
                    } else if (_cityController.text.isNotEmpty) {
                      _fetchWeatherAndForecast(cityName: _cityController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: GlassmorphicContainer(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    final name = suggestion['name'] ?? 'Unknown';
                    final country = suggestion['country'] ?? '';
                    final state = suggestion['state'] ?? '';
                    String subtitle = country;
                    if (state.isNotEmpty && state != name) {
                      subtitle = '$state, $country';
                    }
                    return ListTile(
                      title: Text(name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(subtitle,
                          style: const TextStyle(color: Colors.white70)),
                      onTap: () => _selectCity(suggestion),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentWeatherSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(_location,
            style: const TextStyle(
                fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text('${_temperature?.toStringAsFixed(1) ?? '--'}°C',
            style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w200,
                color: Colors.white)),
        const SizedBox(height: 20),
        Text(_weatherDescription,
            style: const TextStyle(fontSize: 26, color: Colors.white70)),
      ],
    );
  }

  Widget _buildForecastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("5-Day Forecast",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _forecast.length,
            itemBuilder: (context, index) {
              final day = _forecast[index];
              final date = DateTime.parse(day['dt_txt']);
              final dayOfWeek = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ][date.weekday - 1];
              final temp = day['main']['temp'].toStringAsFixed(0);
              String weather = day['weather'][0]['main'];
              IconData icon;
              switch (weather) {
                case 'Clear':
                  icon = Icons.wb_sunny;
                  break;
                case 'Clouds':
                  icon = Icons.cloud;
                  break;
                case 'Rain':
                  icon = Icons.umbrella;
                  break;
                case 'Snow':
                  icon = Icons.ac_unit;
                  break;
                default:
                  icon = Icons.cloud_queue;
              }
              return GlassmorphicContainer(
                child: SizedBox(
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(dayOfWeek,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Icon(icon, color: Colors.orangeAccent),
                      Text('$temp°C',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  const GlassmorphicContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class WeatherBackground extends StatelessWidget {
  final String weatherType;
  const WeatherBackground({super.key, required this.weatherType});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (weatherType) {
      case 'Rain':
      case 'Drizzle':
      case 'Thunderstorm':
        return const RainAnimation();
      case 'Snow':
        return const SnowAnimation();
      case 'Clear':
        return SunnyBackground(isDarkMode: isDarkMode);
      case 'Clouds':
        return CloudyBackground(isDarkMode: isDarkMode);
      default:
        return SunnyBackground(isDarkMode: isDarkMode);
    }
  }
}

class SunnyBackground extends StatelessWidget {
  final bool isDarkMode;
  const SunnyBackground({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF233053), const Color(0xFF000000)]
              : [const Color(0xFF4A90E2), const Color(0xFF81C7F5)],
        ),
      ),
    );
  }
}

class CloudyBackground extends StatelessWidget {
  final bool isDarkMode;
  const CloudyBackground({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF3C4E68), const Color(0xFF202A38)]
              : [const Color(0xFF7D97B3), const Color(0xFFB3C6D9)],
        ),
      ),
    );
  }
}

class RainAnimation extends StatelessWidget {
  const RainAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF283E51), Color(0xFF0A2342)],
        ),
      ),
      child: Stack(
        children: List.generate(100, (index) => const RainDrop()),
      ),
    );
  }
}

class RainDrop extends StatefulWidget {
  const RainDrop({super.key});
  @override
  State<RainDrop> createState() => _RainDropState();
}

class _RainDropState extends State<RainDrop> {
  late double x, y, speed, length;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    x = Random().nextDouble();
    y = -Random().nextDouble();
    speed = Random().nextDouble() * 0.002 + 0.0015;
    length = Random().nextDouble() * 10 + 10;
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        y += speed;
        if (y > 1.2) _reset();
        return Positioned.fill(
          child: Align(
            alignment: Alignment(x * 2 - 1, y * 2 - 1),
            child: Container(
              width: 1.5,
              height: length,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SnowAnimation extends StatelessWidget {
  const SnowAnimation({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3a6ea5), Color(0xFF22333b)],
        ),
      ),
      child: Stack(
        children: List.generate(50, (index) => const SnowFlake()),
      ),
    );
  }
}

class SnowFlake extends StatefulWidget {
  const SnowFlake({super.key});
  @override
  State<SnowFlake> createState() => _SnowFlakeState();
}

class _SnowFlakeState extends State<SnowFlake> {
  late double x, y, speed, size, rotation;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    x = Random().nextDouble();
    y = -Random().nextDouble();
    speed = Random().nextDouble() * 0.001 + 0.0005;
    size = Random().nextDouble() * 6 + 4;
    rotation = Random().nextDouble() * 2 * pi;
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 20),
      builder: (context, value, child) {
        y += speed;
        x += sin(y * 10 + rotation) * 0.001;
        if (y > 1.2) _reset();
        return Positioned.fill(
          child: Align(
            alignment: Alignment(x * 2 - 1, y * 2 - 1),
            child: Icon(Icons.ac_unit, color: Colors.white, size: size),
          ),
        );
      },
    );
  }
}

