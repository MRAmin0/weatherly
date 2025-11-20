import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ⭐️ =================================================================
// ⭐️ ویجت‌های آیتم (Item Widgets)
// ⭐️ =================================================================

class ForecastItem extends StatelessWidget {
  final String dayFa;
  final String tempText;
  final String icon;

  const ForecastItem({super.key, 
    // super.key, // 👈 هشدار حذف شد
    required this.dayFa,
    required this.tempText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(dayFa, style: Theme.of(context).textTheme.titleSmall),
          SvgPicture.asset(
            icon,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
          Text(tempText, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class HourlyItem extends StatelessWidget {
  final String hourText;
  final String tempText;
  final String icon;

  const HourlyItem({super.key, 
    // super.key, // 👈 هشدار حذف شد
    required this.hourText,
    required this.tempText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            hourText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha(179),
            ), // (Opacity 0.7)
          ),
          SvgPicture.asset(
            icon,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),
          ),
          Text(tempText, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
