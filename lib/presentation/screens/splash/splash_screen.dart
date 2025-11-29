import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/screens/weather_screen.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _fadeController.forward();

    Future.delayed(const Duration(milliseconds: 1700), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const WeatherScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();

    final weatherType = vm.currentWeather?.weatherType ?? WeatherType.clear;

    final gradientColors = _getDynamicGradient(weatherType);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🔹 Dynamic Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Fullscreen Glass Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(color: Colors.white.withValues(alpha: 0.06)),
            ),
          ),

          // 🔹 Logo + App Name
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glass Circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    "Weatherly",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.32),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Forecast • Air Quality • Live Weather",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌈 Dynamic Gradient Based on Weather
  List<Color> _getDynamicGradient(WeatherType type) {
    switch (type) {
      case WeatherType.clear:
        return [const Color(0xFF6EC6FF), const Color(0xFF003C8F)];
      case WeatherType.clouds:
        return [const Color(0xFF90A4AE), const Color(0xFF455A64)];
      case WeatherType.rain:
        return [const Color(0xFF5C6BC0), const Color(0xFF263238)];
      case WeatherType.thunderstorm:
        return [const Color(0xFF9575CD), const Color(0xFF1A1A1A)];
      case WeatherType.snow:
        return [const Color(0xFFE1F5FE), const Color(0xFF607D8B)];
      default:
        return [const Color(0xFF6EC6FF), const Color(0xFF003C8F)];
    }
  }
}
