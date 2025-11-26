// lib/widgets/animations/weather_animator.dart
import 'package:flutter/material.dart';
import 'package:weatherly_app/models/weather_type.dart';

class WeatherAnimator extends StatefulWidget {
  final WeatherType weatherType;
  final Widget child;
  final bool isSmallIcon;
  final Duration? customDuration; // برای تنظیم سرعت باد
  final bool onPulse; // برای حالت پالس ساده (رطوبت)

  const WeatherAnimator({
    super.key,
    required this.weatherType,
    required this.child,
    this.isSmallIcon = false,
    this.customDuration,
    this.onPulse = false,
  });

  @override
  State<WeatherAnimator> createState() => _WeatherAnimatorState();
}

class _WeatherAnimatorState extends State<WeatherAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _getDuration());
    _startAnimation();
  }

  @override
  void didUpdateWidget(WeatherAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // اگر نوع آب‌وهوا یا سرعت (Duration) تغییر کرد، انیمیشن آپدیت بشه
    if (oldWidget.weatherType != widget.weatherType ||
        oldWidget.customDuration != widget.customDuration ||
        oldWidget.onPulse != widget.onPulse) {
      _controller.duration = _getDuration();
      _controller.reset();
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration _getDuration() {
    // 1. اگر سرعت کاستوم داده بودیم (برای باد)، همون رو استفاده کن
    if (widget.customDuration != null) {
      return widget.customDuration!;
    }

    // 2. اگر حالت پالس بود (برای رطوبت)
    if (widget.onPulse) {
      return const Duration(seconds: 2);
    }

    // 3. حالت‌های پیش‌فرض
    switch (widget.weatherType) {
      case WeatherType.clear:
        return const Duration(seconds: 5);
      case WeatherType.clouds:
        return const Duration(milliseconds: 2000);
      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        return const Duration(milliseconds: 800);
      case WeatherType.snow:
        return const Duration(milliseconds: 1500);
      case WeatherType.windy:
        return const Duration(milliseconds: 300);
      default:
        return const Duration(seconds: 1);
    }
  }

  void _startAnimation() {
    if (widget.weatherType == WeatherType.clear && !widget.onPulse) {
      _controller.repeat();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: _buildAnimation());
  }

  Widget _buildAnimation() {
    // 1. اگر حالت پالس خواسته شده (برای رطوبت)
    if (widget.onPulse) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.05).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: widget.child,
      );
    }

    // 2. بقیه انیمیشن‌ها
    switch (widget.weatherType) {
      case WeatherType.clear: // برای باد هم از چرخش استفاده می‌کنیم
        return RotationTransition(turns: _controller, child: widget.child);

      case WeatherType.clouds:
      case WeatherType.fog:
      case WeatherType.mist:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.08, 0),
                end: const Offset(0.08, 0),
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOutSine,
                ),
              ),
          child: widget.child,
        );

      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: const Offset(0, 0.1),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.linear),
            ),
            child: widget.child,
          ),
        );

      case WeatherType.snow:
        return FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: const Offset(0, 0.05),
            ).animate(_controller),
            child: widget.child,
          ),
        );

      default:
        // Default Pulse
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.05).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: widget.child,
        );
    }
  }
}
