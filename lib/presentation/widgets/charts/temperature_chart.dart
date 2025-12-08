// lib/widgets/charts/temperature_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weatherly_app/data/models/hourly_forecast.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';
import 'package:weatherly_app/core/utils/weather_formatters.dart';

class TemperatureChart extends StatelessWidget {
  final List<HourlyForecastEntry> hourlyData;
  final bool useCelsius;
  final bool isPersian;

  const TemperatureChart({
    super.key,
    required this.hourlyData,
    required this.useCelsius,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<FlSpot> spots = hourlyData.asMap().entries.map((entry) {
      final x = entry.key.toDouble();
      final temp = entry.value.temperature;
      final y = useCelsius ? temp : (temp * 9 / 5) + 32;
      return FlSpot(x, y);
    }).toList();

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      height: 300,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: minY - 2,
          maxY: maxY + 2,
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 90,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= hourlyData.length) {
                    return const SizedBox.shrink();
                  }

                  final item = hourlyData[index];
                  final timeStr = formatLocalHour(item.time, 0);
                  final timeLabel = isPersian
                      ? toPersianDigits(timeStr)
                      : timeStr;
                  final iconPath = weatherIconAsset(
                    weatherTypeToApiName(item.weatherType),
                  );

                  // Temperature with unit
                  final rawTemp = item.temperature;
                  final temp = useCelsius ? rawTemp : (rawTemp * 9 / 5) + 32;
                  final unit = useCelsius ? '°C' : '°F';
                  final tempText = "${temp.toStringAsFixed(0)}$unit";
                  final tempLabel = isPersian
                      ? toPersianDigits(tempText)
                      : tempText;

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SvgPicture.asset(iconPath, width: 28, height: 28),
                        const SizedBox(height: 2),
                        Text(
                          tempLabel,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 0,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.5),
                  primaryColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) =>
                  Colors.black.withValues(alpha: 0.8),
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.all(10),
              tooltipMargin: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final item = hourlyData[touchedSpot.spotIndex];
                  final time = formatLocalHour(item.time, 0);
                  final timeStr = isPersian ? toPersianDigits(time) : time;

                  final temp = touchedSpot.y.toStringAsFixed(0);
                  final tempStr = isPersian ? toPersianDigits(temp) : temp;
                  final unit = useCelsius ? '°C' : '°F';

                  return LineTooltipItem(
                    '$timeStr\n$tempStr$unit',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: primaryColor,
                  );
                },
              ),
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
