// lib/widgets/charts/temperature_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weatherly_app/models/hourly_forecast.dart';
import 'package:intl/intl.dart';
import 'package:weatherly_app/utils/city_utils.dart';

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
      padding: const EdgeInsets.only(top: 20, right: 20),
      height: 200,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: spots.length.toDouble() - 1,
          minY: minY - 2,
          maxY: maxY + 2,
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          // ✅ Add betweenBarsData at LineChartData level
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
              // ✅ Updated: Use getTooltipColor instead of tooltipBgColor
              getTooltipColor: (touchedSpot) => Colors.black.withValues(alpha: 0.8),
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.all(10),
              tooltipMargin: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final time = formatTime(
                    hourlyData[touchedSpot.spotIndex].time,
                    isPersian,
                  );
                  final temp = touchedSpot.y.toStringAsFixed(0);
                  final unit = useCelsius ? '°C' : '°F';
                  return LineTooltipItem(
                    '$time\n$temp$unit',
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
              dotData: const FlDotData(show: false),
              // ✅ Updated: Use gradient instead of single color for line
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
              // ✅ Updated: Use showingIndicators for spot line
              showingIndicators: [],
            ),
          ],
        ),
      ),
    );
  }
}

String formatTime(DateTime time, bool isPersian) {
  final formatter = DateFormat('HH:mm');
  String result = formatter.format(time);
  if (isPersian) {
    return toPersianDigits(result);
  }
  return result;
}