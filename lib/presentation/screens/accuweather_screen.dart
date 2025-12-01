import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/accuweather_viewmodel.dart';
import '../../models/accuweather/accuweather_current.dart';
import '../../models/accuweather/accuweather_forecast.dart';

class AccuWeatherScreen extends StatelessWidget {
  const AccuWeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccuWeatherViewModel()..fetchWeatherData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AccuWeather (Real-time)'),
          centerTitle: true,
        ),
        body: Consumer<AccuWeatherViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: viewModel.refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.current == null) {
              return const Center(child: Text('No data available'));
            }

            return RefreshIndicator(
              onRefresh: viewModel.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentConditions(context, viewModel.current!),
                    const SizedBox(height: 24),
                    if (viewModel.forecast.isNotEmpty) ...[
                      Text(
                        '5-Day Forecast',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildForecastList(context, viewModel.forecast),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentConditions(
    BuildContext context,
    AccuCurrentConditions data,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Main weather
            Text(
              data.weatherText,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.temperature.toStringAsFixed(1)}',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 72,
                  ),
                ),
                Text('°C', style: theme.textTheme.headlineMedium),
              ],
            ),

            // RealFeel
            Text(
              'RealFeel® ${data.realFeel.toStringAsFixed(1)}°C',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Details grid
            _buildDetailsGrid(context, data),

            // 24h summary
            if (data.tempMin24h != null && data.tempMax24h != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _build24hSummary(context, data),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, AccuCurrentConditions data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Humidity',
                '${data.relativeHumidity}%',
                Icons.water_drop,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Wind',
                '${data.windSpeed.toStringAsFixed(1)} km/h',
                Icons.air,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'UV Index',
                '${data.uvIndex} (${data.uvIndexText})',
                Icons.wb_sunny,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Visibility',
                '${data.visibility.toStringAsFixed(1)} km',
                Icons.visibility,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Cloud Cover',
                '${data.cloudCover}%',
                Icons.cloud,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Pressure',
                '${data.pressure.toStringAsFixed(0)} mb',
                Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Dew Point',
                '${data.dewPoint.toStringAsFixed(1)}°C',
                Icons.thermostat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Wind Dir',
                data.windDirection,
                Icons.navigation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build24hSummary(BuildContext context, AccuCurrentConditions data) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '24-Hour Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              context,
              'Min',
              '${data.tempMin24h!.toStringAsFixed(1)}°C',
              Icons.arrow_downward,
            ),
            _buildSummaryItem(
              context,
              'Max',
              '${data.tempMax24h!.toStringAsFixed(1)}°C',
              Icons.arrow_upward,
            ),
            if (data.rainLastHour != null)
              _buildSummaryItem(
                context,
                'Rain',
                '${data.rainLastHour!.toStringAsFixed(1)} mm',
                Icons.water,
              ),
          ],
        ),
        if (data.pressureTendency.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Pressure: ${data.pressureTendency}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastList(
    BuildContext context,
    List<AccuDailyForecast> forecasts,
  ) {
    return Column(
      children: forecasts
          .map((forecast) => _buildForecastCard(context, forecast))
          .toList(),
    );
  }

  Widget _buildForecastCard(BuildContext context, AccuDailyForecast forecast) {
    final theme = Theme.of(context);
    final date = DateTime.tryParse(forecast.date);
    final dateStr = date != null
        ? DateFormat('EEE, MMM d').format(date)
        : forecast.date;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    forecast.phrase,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        size: 16,
                        color: Colors.red[300],
                      ),
                      Text(
                        '${forecast.maxTemp.toStringAsFixed(0)}°',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 16,
                        color: Colors.blue[300],
                      ),
                      Text(
                        '${forecast.minTemp.toStringAsFixed(0)}°',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (forecast.precipitationProbability > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${forecast.precipitationProbability}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
