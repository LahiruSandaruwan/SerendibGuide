import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import '../models/sun_times.dart';
import '../services/weather_service.dart';
import '../services/sun_times_service.dart';
import '../utils/constants.dart';

/// Weather widget showing current conditions and forecast
class WeatherWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const WeatherWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  final SunTimesService _sunTimesService = SunTimesService();
  WeatherForecast? _forecast;
  SunTimes? _sunTimes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final forecast = await _weatherService.getWeatherForecast(
        latitude: widget.latitude,
        longitude: widget.longitude,
        locationName: widget.locationName,
      );

      final sunTimes = await _sunTimesService.getTodaySunTimes(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      if (mounted) {
        setState(() {
          _forecast = forecast;
          _sunTimes = sunTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load weather data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null || _forecast == null) {
      return _buildErrorState();
    }

    return _buildWeatherCard();
  }

  Widget _buildLoadingState() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Loading weather...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey[400]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _error ?? 'Weather unavailable',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    final current = _forecast!.current;
    final today = _forecast!.today;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  current.icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        current.temperatureDisplay,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.sunsetOrange,
                        ),
                      ),
                      Text(
                        'Feels like ${today.temperatureRangeDisplay}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (current.humidity > 0) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${current.humidity}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    Row(
                      children: [
                        Icon(
                          Icons.air,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${current.windSpeed.round()} km/h',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Recommendation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: current.isGoodWeather
                    ? AppConstants.successGreen.withOpacity(0.1)
                    : AppConstants.warningAmber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: current.isGoodWeather
                      ? AppConstants.successGreen.withOpacity(0.3)
                      : AppConstants.warningAmber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    current.isGoodWeather ? Icons.check_circle : Icons.info,
                    color: current.isGoodWeather
                        ? AppConstants.successGreen
                        : AppConstants.warningAmber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      current.recommendation,
                      style: TextStyle(
                        fontSize: 13,
                        color: current.isGoodWeather
                            ? AppConstants.successGreen
                            : AppConstants.warningAmber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sun times
            if (_sunTimes != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSunTimeItem(
                    '🌅',
                    'Sunrise',
                    _sunTimes!.formatTime(_sunTimes!.sunrise),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  _buildSunTimeItem(
                    '🌇',
                    'Sunset',
                    _sunTimes!.formatTime(_sunTimes!.sunset),
                  ),
                ],
              ),

              // Photography tip
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.deepOceanBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: AppConstants.deepOceanBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _sunTimes!.photographyRecommendation,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppConstants.deepOceanBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 7-day forecast preview
            if (_forecast!.daily.length > 1) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '7-Day Forecast',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _forecast!.daily.length,
                  itemBuilder: (context, index) {
                    return _buildForecastDay(_forecast!.daily[index], index);
                  },
                ),
              ),
            ],

            // Data source
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Data from Open-Meteo',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunTimeItem(String icon, String label, String time) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastDay(Weather weather, int index) {
    final dayName = index == 0
        ? 'Today'
        : index == 1
            ? 'Tomorrow'
            : DateFormat('EEE').format(weather.timestamp);

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weather.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            '${weather.temperatureMax.round()}°',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${weather.temperatureMin.round()}°',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
