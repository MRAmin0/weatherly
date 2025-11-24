import 'package:flutter/material.dart';
import 'package:weatherly_app/models/weather_type.dart';

/// A modular widget that animates its child based on the [WeatherType].
/// This keeps animation logic separate from the main UI code.
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

  Duration _getDuration() {
    switch (widget.weatherType) {
      case WeatherType.clear:
        return const Duration(seconds: 10); // Slow rotation for sun
      case WeatherType.clouds:
        return const Duration(seconds: 4); // Floating clouds
      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        return const Duration(milliseconds: 1500); // Rain drops
      case WeatherType.snow:
        return const Duration(seconds: 3); // Gentle sway
      case WeatherType.windy:
        return const Duration(milliseconds: 500); // Fast shake
      default:
        return const Duration(seconds: 2);
    }
  }

  void _startAnimation() {
    if (widget.weatherType == WeatherType.clear) {
      _controller.repeat(); // Rotate forever
    } else {
      _controller.repeat(reverse: true); // Pulse/Float back and forth
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.weatherType) {
      case WeatherType.clear:
        // Rotate Animation (Sun)
        return RotationTransition(turns: _controller, child: widget.child);

      case WeatherType.clouds:
      case WeatherType.fog:
      case WeatherType.mist:
        // Floating Animation (Horizontal)
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.05, 0),
                end: const Offset(0.05, 0),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
          child: widget.child,
        );

      case WeatherType.rain:
      case WeatherType.drizzle:
      case WeatherType.thunderstorm:
        // Bobbing/Drop Animation (Vertical)
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: const Offset(0, 0.05),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: widget.child,
          ),
        );

      case WeatherType.windy:
        // Shaking Animation
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(-0.03, 0),
                end: const Offset(0.03, 0),
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
              ),
          child: widget.child,
        );

      case WeatherType.snow:
        // Gentle Sway + Fade
        return FadeTransition(
          opacity: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
            ),
            child: widget.child,
          ),
        );

      default:
        // Default Pulse
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.05).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: widget.child,
        );
    }
  }
}
