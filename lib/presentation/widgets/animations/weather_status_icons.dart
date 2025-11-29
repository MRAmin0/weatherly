import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/data/models/weather_type.dart';
import 'package:weatherly_app/presentation/widgets/animations/weather_animator.dart';

/// 1. آیکون هوشمند توربین بادی (با سرعت متغیر و چرخش دقیق)
class WindTurbineIcon extends StatelessWidget {
  final double windSpeed;

  const WindTurbineIcon({super.key, required this.windSpeed});

  @override
  Widget build(BuildContext context) {
    // محاسبه سرعت چرخش
    final Duration? windDuration = windSpeed > 0.5
        ? Duration(milliseconds: (6000 / windSpeed).clamp(200, 5000).toInt())
        : null;

    // ویجت پایه (ثابت)
    final baseWidget = SvgPicture.string(
      _turbineBaseSvg,
      width: 32,
      height: 32,
      colorFilter: const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
    );

    // ویجت پره (چرخان)
    // نکته: چون SVG اصلاح شده و مرکز پره دقیقاً وسط کادر است،
    // دیگر نیازی به Transform.translate نداریم.
    final bladesWidget = SvgPicture.string(
      _turbineBladesSvg,
      width: 32,
      height: 32,
      colorFilter: const ColorFilter.mode(Colors.blueAccent, BlendMode.srcIn),
    );

    // ترکیب لایه‌ها
    return Stack(
      alignment: Alignment.center, // تراز کردن دقیق مرکز به مرکز
      children: [
        // لایه ۱: پایه
        baseWidget,

        // لایه ۲: پره‌ها
        if (windDuration != null)
          WeatherAnimator(
            weatherType: WeatherType.clear, // تریگر چرخش
            customDuration: windDuration,
            child: bladesWidget,
          )
        else
          bladesWidget, // اگر باد نیست، ثابت نشان بده
      ],
    );
  }
}

/// 2. آیکون رطوبت
class HumidityIcon extends StatelessWidget {
  const HumidityIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const WeatherAnimator(
      weatherType: WeatherType.clear,
      onPulse: true,
      child: Icon(
        Icons.water_drop_outlined,
        color: Colors.lightBlueAccent,
        size: 28,
      ),
    );
  }
}

/// 3. آیکون کیفیت هوا
class AirQualityIcon extends StatelessWidget {
  final Color color;

  const AirQualityIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.air, color: color, size: 28);
  }
}

// ==========================================================
// کدهای SVG اصلاح شده (مرکزیت دقیق)
// ==========================================================

// پایه: نوک پایه دقیقاً در مختصات y=12 (مرکز عمودی) تمام می‌شود
const String _turbineBaseSvg = '''
<svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <g fill="#1565C0">
        <path d="M4 5h6a0.5 0.5 0 0 1 0 1H4a0.5 0.5 0 0 1 0-1z"/>
        <path d="M5 7h4a0.5 0.5 0 0 1 0 1H5a0.5 0.5 0 0 1 0-1z"/>
        <path d="M4 9h5a0.5 0.5 0 0 1 0 1H4a0.5 0.5 0 0 1 0-1z"/>
        
        <path d="M2 20 C 5 20, 6 18.5, 9 18.5 C 12 18.5, 13 20, 16 20 C 19 20, 20 18.5, 22 18.5 V 22 H 2 V 20 Z"/>
        
        <path d="M11 20 L 13 20 L 12.5 12 L 11.5 12 Z"/>
    </g>
</svg>
''';

// پره‌ها: مرکز دایره دقیقاً در (12,12) است
const String _turbineBladesSvg = '''
<svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <g fill="#1565C0">
        <g transform="translate(12, 12)">
            <circle cx="0" cy="0" r="1.5" fill="#1565C0"/>
            <circle cx="0" cy="0" r="0.5" fill="white"/>
            
            <path d="M0 0 C 1 -1 2 -5 4 -7 C 5 -5 2 1 0 0" />
            <path d="M0 0 C 1 -1 2 -5 4 -7 C 5 -5 2 1 0 0" transform="rotate(120)"/>
            <path d="M0 0 C 1 -1 2 -5 4 -7 C 5 -5 2 1 0 0" transform="rotate(240)"/>
        </g>
    </g>
</svg>
''';
