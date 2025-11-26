import 'package:flutter/material.dart';
import 'package:weatherly_app/models/weather_type.dart';

class WeatherAnimator extends StatefulWidget {
  final WeatherType weatherType;
  final Widget child;
  final bool isSmallIcon;

  const WeatherAnimator({
    super.key,
    required this.weatherType,
    required this.child,
    this.isSmallIcon = false,
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
    if (oldWidget.weatherType != widget.weatherType) {
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

  // زمان‌ها را کاهش دادم تا انیمیشن سریع‌تر و زنده‌تر باشد
  Duration _getDuration() {
    switch (widget.weatherType) {
      case WeatherType.clear:
        return const Duration(seconds: 5); // قبلا ۱۰ بود (چرخش سریع‌تر خورشید)
      case WeatherType.clouds:
        return const Duration(milliseconds: 2000); // قبلا ۴ ثانیه بود
      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        return const Duration(milliseconds: 800); // بارش سریع‌تر باران
      case WeatherType.snow:
        return const Duration(milliseconds: 1500); // بارش نرم برف
      case WeatherType.windy:
        return const Duration(milliseconds: 300); // لرزش سریع باد
      default:
        return const Duration(seconds: 1);
    }
  }

  void _startAnimation() {
    if (widget.weatherType == WeatherType.clear) {
      _controller.repeat();
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // استفاده از RepaintBoundary برای افزایش پرفورمنس
    // این کار باعث می‌شود انیمیشن روی بقیه صفحه تاثیر نگذارد و روان‌تر اجرا شود
    return RepaintBoundary(child: _buildAnimation());
  }

  Widget _buildAnimation() {
    switch (widget.weatherType) {
      case WeatherType.clear:
        return RotationTransition(turns: _controller, child: widget.child);

      case WeatherType.clouds:
      case WeatherType.fog:
      case WeatherType.mist:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.08, 0), // دامنه حرکت را کمی بیشتر کردم
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

      case WeatherType.windy:
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.05, 0),
                end: const Offset(0.05, 0),
              ).animate(
                // از منحنی Elastic برای حس بهتر باد استفاده کردم
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeInOutBack,
                ),
              ),
          child: widget.child,
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
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.05).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: widget.child,
        );
    }
  }
}
