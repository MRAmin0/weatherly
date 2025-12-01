import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../viewmodels/openweathermap_viewmodel.dart';
import '../../models/openweathermap/owm_current.dart';
import '../../models/openweathermap/owm_forecast.dart';

class OpenWeatherMapScreen extends StatelessWidget {
  const OpenWeatherMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OpenWeatherMapViewModel()..fetchWeatherData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OpenWeatherMap (Real-time)'),
          centerTitle: true,
        ),
        body: Consumer<OpenWeatherMapViewModel>(
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
                    _buildCurrentWeather(context, viewModel.current!),
                    const SizedBox(height: 24),
                    if (viewModel.forecast.isNotEmpty) ...[
                      Text(
                        '5-Day / 3-Hour Forecast',
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

  Widget _buildCurrentWeather(BuildContext context, OwmCurrent data) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Weather description
            Text(
              data.description.toUpperCase(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              data.weatherMain,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

            // Feels like
            Text(
              'Feels like ${data.feelsLike.toStringAsFixed(1)}°C',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Details grid
            _buildDetailsGrid(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context, OwmCurrent data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                context,
                'Humidity',
                '${data.humidity}%',
                Icons.water_drop,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Wind',
                '${data.windSpeed.toStringAsFixed(1)} m/s',
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
                'Visibility',
                '${(data.visibility / 1000).toStringAsFixed(1)} km',
                Icons.visibility,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDetailItem(
                context,
                'Cloudiness',
                '${data.cloudiness}%',
                Icons.cloud,
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
                'Pressure',
                '${data.pressure.toStringAsFixed(0)} hPa',
                Icons.speed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container()),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastList(BuildContext context, List<OwmForecast> forecasts) {
    // Group forecasts by day
    final Map<String, List<OwmForecast>> groupedByDay = {};

    for (var forecast in forecasts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(forecast.dateTime);
      if (!groupedByDay.containsKey(dateKey)) {
        groupedByDay[dateKey] = [];
      }
      groupedByDay[dateKey]!.add(forecast);
    }

    return Column(
      children: groupedByDay.entries.map((entry) {
        return _buildDaySection(context, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    String dateKey,
    List<OwmForecast> forecasts,
  ) {
    final theme = Theme.of(context);
    final date = DateTime.parse(dateKey);
    final dateStr = DateFormat('EEEE, MMM d').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            dateStr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        ...forecasts.map((forecast) => _buildForecastCard(context, forecast)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildForecastCard(BuildContext context, OwmForecast forecast) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(forecast.dateTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Time
            SizedBox(
              width: 60,
              child: Text(
                timeStr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Weather icon/description
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(
                    _getWeatherIcon(forecast.weatherIcon),
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      forecast.weatherDescription,
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Temperature
            SizedBox(
              width: 70,
              child: Text(
                '${forecast.temperature.toStringAsFixed(1)}°C',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),

            const SizedBox(width: 8),

            // Additional info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast.humidity}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.air,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${forecast.windSpeed.toStringAsFixed(1)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny;
    if (iconCode.contains('02')) return Icons.wb_cloudy;
    if (iconCode.contains('03') || iconCode.contains('04')) return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10'))
      return Icons.water_drop;
    if (iconCode.contains('11')) return Icons.thunderstorm;
    if (iconCode.contains('13')) return Icons.ac_unit;
    if (iconCode.contains('50')) return Icons.foggy;
    return Icons.wb_sunny;
  }
}
