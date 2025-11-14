import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/world_time.dart';
import '../services/world_time_service.dart';
import '../utils/constants.dart';

/// Screen for world time and timezone conversion
class WorldTimeScreen extends StatefulWidget {
  const WorldTimeScreen({super.key});

  @override
  State<WorldTimeScreen> createState() => _WorldTimeScreenState();
}

class _WorldTimeScreenState extends State<WorldTimeScreen> {
  final WorldTimeService _service = WorldTimeService();

  WorldTime? _sriLankaTime;
  WorldTime? _userTime;
  TimeComparison? _comparison;
  Map<String, WorldTime> _popularTimes = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWorldTimes();
  }

  Future<void> _loadWorldTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sriLankaTime = await _service.getSriLankaTime();
      final userTime = await _service.getUserTime();
      final comparison = await _service.compareWithSriLanka();

      // Load popular timezones
      final popularTimezones = [
        'Asia/Colombo',
        'Europe/London',
        'America/New_York',
        'Asia/Tokyo',
        'Australia/Sydney',
      ];
      final popularTimes =
          await _service.getMultipleTimezones(popularTimezones);

      if (mounted) {
        setState(() {
          _sriLankaTime = sriLankaTime;
          _userTime = userTime;
          _comparison = comparison;
          _popularTimes = popularTimes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load time information';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Time'),
        backgroundColor: AppConstants.deepOceanBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWorldTimes,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading world times...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load time information'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadWorldTimes,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadWorldTimes,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sri Lanka Time (main)
          if (_sriLankaTime != null) _buildSriLankaTimeCard(_sriLankaTime!),

          const SizedBox(height: 16),

          // Time Comparison
          if (_comparison != null) _buildComparisonCard(_comparison!),

          const SizedBox(height: 24),

          // Popular Times
          const Text(
            'World Clocks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ..._popularTimes.entries.map((entry) {
            return _buildTimeZoneCard(
              _getLocationName(entry.key),
              entry.value,
            );
          }),

          const SizedBox(height: 16),

          // Info card
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSriLankaTimeCard(WorldTime time) {
    return Card(
      elevation: 4,
      color: AppConstants.tropicalGreen.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🇱🇰',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Sri Lanka',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.tropicalGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              time.formattedTime,
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppConstants.deepOceanBlue,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(time.datetime),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.tropicalGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                time.utcOffsetFormatted,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(TimeComparison comparison) {
    if (_userTime == null) return const SizedBox();

    final isInSriLanka = comparison.timeDifferenceMinutes == 0;

    return Card(
      color: isInSriLanka
          ? AppConstants.successGreen.withOpacity(0.1)
          : AppConstants.sunsetOrange.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isInSriLanka ? Icons.check_circle : Icons.public,
                  color: isInSriLanka
                      ? AppConstants.successGreen
                      : AppConstants.sunsetOrange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Time',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userTime!.timeWithTimezone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepOceanBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comparison.comparisonText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
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

  Widget _buildTimeZoneCard(String location, WorldTime time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppConstants.deepOceanBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              _getLocationEmoji(location),
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          location,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          time.utcOffsetFormatted,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Text(
          time.formattedTime,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.deepOceanBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Travel Tip',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sri Lanka does not observe Daylight Saving Time. The timezone (UTC+5:30) remains constant throughout the year.',
            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }

  String _getLocationName(String timezone) {
    switch (timezone) {
      case 'Asia/Colombo':
        return 'Sri Lanka';
      case 'Europe/London':
        return 'London, UK';
      case 'America/New_York':
        return 'New York, USA';
      case 'Asia/Tokyo':
        return 'Tokyo, Japan';
      case 'Australia/Sydney':
        return 'Sydney, Australia';
      default:
        return timezone.split('/').last.replaceAll('_', ' ');
    }
  }

  String _getLocationEmoji(String location) {
    if (location.contains('Sri Lanka')) return '🇱🇰';
    if (location.contains('London')) return '🇬🇧';
    if (location.contains('New York')) return '🇺🇸';
    if (location.contains('Tokyo')) return '🇯🇵';
    if (location.contains('Sydney')) return '🇦🇺';
    return '🌍';
  }
}
