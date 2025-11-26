import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ⭐️ =================================================================
// ⭐️ ویجت‌های آیتم (Item Widgets)
// ⭐️ =================================================================

class ForecastItem extends StatelessWidget {
  final String dayFa;
  final String tempText;
  final String icon;

  const ForecastItem({
    super.key,
    required this.dayFa,
    required this.tempText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
            dayFa,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          // نمایش آیکون بدون فیلتر رنگ
          SvgPicture.asset(
            icon,
            width: 32, // کمی بزرگتر برای وضوح بیشتر
            height: 32,
            // colorFilter حذف شد
          ),
          Text(
            tempText,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class HourlyItem extends StatelessWidget {
  final String hourText;
  final String tempText;
  final String icon;

  const HourlyItem({
    super.key,
    required this.hourText,
    required this.tempText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70, // عرض کمی کمتر شد تا جمع‌وجورتر باشد
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(15), // بوردر محو
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hourText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withAlpha(180),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          // نمایش آیکون بدون فیلتر رنگ
          SvgPicture.asset(
            icon,
            width: 32,
            height: 32,
            // colorFilter حذف شد
          ),
          Text(
            tempText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
