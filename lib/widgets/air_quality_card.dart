import 'package:flutter/material.dart';
import 'package:weatherly_app/l10n/app_localizations.dart';
import 'package:weatherly_app/utils/weather_formatters.dart';

class AirQualityCard extends StatefulWidget {
  final int aqi;

  const AirQualityCard({super.key, required this.aqi});

  @override
  State<AirQualityCard> createState() => _AirQualityCardState();
}

class _AirQualityCardState extends State<AirQualityCard> {
  bool _showAqiGuide = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = labelForAqi(widget.aqi, l10n);
    final severityColor = statusColorForAqi(widget.aqi);
    final progress = (widget.aqi / 500.0).clamp(0.0, 1.0);
    final aqiString = l10n.localeName == 'fa'
        ? toPersianDigits('AQI ${widget.aqi}')
        : 'AQI ${widget.aqi}';

    final scheme = Theme.of(context).colorScheme;
    final accentColor = scheme.primary;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showAqiGuide = !_showAqiGuide),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.air_rounded, color: accentColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.airQualityIndex,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            status,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: severityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withAlpha(230),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        aqiString,
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontSize: 20, // کمی سایز رو منطقی‌تر کردم
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _showAqiGuide
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
                // اعداد 0 تا 500 رو اینجا حذف کردم چون توی کارت پاپ‌آپ شلوغ میشه
                // اگر دوست داشتی برشون گردون
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: _showAqiGuide
              ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: _buildAqiGuideTable(context, l10n),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildAqiGuideTable(BuildContext context, AppLocalizations l10n) {
    final aqiRanges = [
      {
        'label': l10n.aqiStatusVeryGood,
        'range': '0 - 25',
        'color': const Color(0xFF00E400),
        'recommendation': l10n.aqiRecommendationNormal,
      },
      {
        'label': l10n.aqiStatusGood,
        'range': '26 - 37',
        'color': const Color(0xFF7CB342),
        'recommendation': l10n.aqiRecommendationCaution,
      },
      {
        'label': l10n.aqiStatusModerate,
        'range': '38 - 50',
        'color': const Color(0xFFFFC107),
        'recommendation': l10n.aqiRecommendationAvoid,
      },
      {
        'label': l10n.aqiStatusPoor,
        'range': '51 - 90',
        'color': const Color(0xFFFF7E00),
        'recommendation': l10n.aqiRecommendationMask,
      },
      {
        'label': l10n.aqiStatusVeryPoor,
        'range': '90+',
        'color': const Color(0xFFFF0000),
        'recommendation': l10n.aqiRecommendationNoActivity,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.airQualityGuide,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...aqiRanges.map((item) {
            final color = item['color'] as Color;
            final label = item['label'] as String;
            final range = l10n.localeName == 'fa'
                ? toPersianDigits(item['range'] as String)
                : item['range'] as String;
            final recommendation = item['recommendation'] as String;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(102), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Icon(
                      _getAqiEmoji(color),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                range,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recommendation,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getAqiEmoji(Color color) {
    if (color == const Color(0xFF00E400) || color == const Color(0xFF7CB342)) {
      return Icons.sentiment_very_satisfied;
    } else if (color == const Color(0xFFFFC107)) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }
}