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

    return Container(
      padding: const EdgeInsets.only(top: 16),
      height: 280,
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ), // Avoid clipping at edges
          child: SizedBox(
            width:
                spots.length *
                72.0, // Increased width per point for better spacing
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
                      reservedSize: 85,
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

                        final rawTemp = item.temperature;
                        final temp = useCelsius
                            ? rawTemp
                            : (rawTemp * 9 / 5) + 32;
                        final unit = useCelsius ? '°' : '°';
                        final tempText = "${temp.toStringAsFixed(0)}$unit";
                        final tempLabel = isPersian
                            ? toPersianDigits(tempText)
                            : tempText;

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                timeLabel,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SvgPicture.asset(iconPath, width: 22, height: 22),
                              const SizedBox(height: 6),
                              Text(
                                tempLabel,
                                style: const TextStyle(
                                  color: Colors.white,
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
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        Colors.white.withValues(alpha: 0.2),
                    tooltipRoundedRadius: 15,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final item = hourlyData[touchedSpot.spotIndex];
                        final time = formatLocalHour(item.time, 0);
                        final timeStr = isPersian
                            ? toPersianDigits(time)
                            : time;

                        final tempValue = touchedSpot.y.toStringAsFixed(0);
                        final tempStr = isPersian
                            ? toPersianDigits(tempValue)
                            : tempValue;
                        final unit = useCelsius ? '°C' : '°F';

                        return LineTooltipItem(
                          '$timeStr\n$tempStr$unit',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
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
                    curveSmoothness: 0.35,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3.5,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: Colors.blueAccent.withValues(alpha: 0.8),
                        );
                      },
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: 0.7),
                      ],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
