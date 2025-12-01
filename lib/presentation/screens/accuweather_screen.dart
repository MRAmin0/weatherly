import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/accuweather_viewmodel.dart';
import '../../models/accuweather_current.dart';

class AccuWeatherScreen extends StatelessWidget {
  const AccuWeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccuWeatherViewModel()..fetchCurrentConditions(),
      child: Scaffold(
        appBar: AppBar(title: const Text('AccuWeather Real-time')),
        body: Consumer<AccuWeatherViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${viewModel.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: viewModel.fetchCurrentConditions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.data == null) {
              return const Center(child: Text('No data available'));
            }

            final data = viewModel.data!;
            return RefreshIndicator(
              onRefresh: viewModel.fetchCurrentConditions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, data),
                    const SizedBox(height: 24),
                    _buildDetailGrid(context, data),
                    const SizedBox(height: 24),
                    _buildSummaryCard(context, data),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AccuCurrentConditions data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              data.weatherText,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.temperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'RealFeel® ${data.realFeel.toStringAsFixed(1)}°C',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailGrid(BuildContext context, AccuCurrentConditions data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildInfoTile(
          context,
          'Humidity',
          '${data.relativeHumidity}%',
          Icons.water_drop,
        ),
        _buildInfoTile(
          context,
          'Wind',
          '${data.windSpeed} km/h ${data.windDirection}',
          Icons.air,
        ),
        _buildInfoTile(
          context,
          'UV Index',
          '${data.uvIndex} (${data.uvIndexText})',
          Icons.wb_sunny,
        ),
        _buildInfoTile(
          context,
          'Visibility',
          '${data.visibility} km',
          Icons.visibility,
        ),
        _buildInfoTile(
          context,
          'Cloud Cover',
          '${data.cloudCover}%',
          Icons.cloud,
        ),
        _buildInfoTile(context, 'Pressure', '${data.pressure} mb', Icons.speed),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AccuCurrentConditions data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('24h Summary', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            if (data.tempMin24h != null && data.tempMax24h != null)
              _buildSummaryRow(
                'Temperature Range',
                '${data.tempMin24h}°C - ${data.tempMax24h}°C',
              ),
            if (data.rainLastHour != null)
              _buildSummaryRow('Rain (Last Hour)', '${data.rainLastHour} mm'),
            _buildSummaryRow('Pressure Tendency', data.pressureTendency),
            _buildSummaryRow('Dew Point', '${data.dewPoint}°C'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
