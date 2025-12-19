import 'package:flutter/material.dart';
import 'package:weatherly_app/viewmodels/weather_viewmodel.dart';
import 'package:weatherly_app/core/utils/city_utils.dart';

class PollutantBreakdown extends StatelessWidget {
  final WeatherViewModel viewModel;

  const PollutantBreakdown({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (viewModel.pm2_5 == null && viewModel.pm10 == null) {
      return const SizedBox.shrink();
    }

    final isPersian = viewModel.lang == 'fa';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            isPersian
                ? "جزئیات آلاینده‌ها (µg/m³)"
                : "Pollutant Details (µg/m³)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (viewModel.pm2_5 != null)
                _buildPollutantItem("PM2.5", viewModel.pm2_5!, isPersian),
              if (viewModel.pm10 != null)
                _buildPollutantItem("PM10", viewModel.pm10!, isPersian),
              if (viewModel.no2 != null)
                _buildPollutantItem("NO2", viewModel.no2!, isPersian),
              if (viewModel.o3 != null)
                _buildPollutantItem("O3", viewModel.o3!, isPersian),
              if (viewModel.so2 != null)
                _buildPollutantItem("SO2", viewModel.so2!, isPersian),
              if (viewModel.co != null)
                _buildPollutantItem("CO", viewModel.co!, isPersian),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollutantItem(String label, double value, bool isPersian) {
    final displayValue = isPersian
        ? toPersianDigits(value.toStringAsFixed(1))
        : value.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
