import 'package:flutter/material.dart';
import '../models/air_quality.dart';
import '../models/moon_phase.dart';
import '../services/air_quality_service.dart';
import '../services/moon_phase_service.dart';
import '../utils/constants.dart';

/// Widget displaying environmental information (Air Quality & Moon Phase)
class EnvironmentalInfoWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const EnvironmentalInfoWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<EnvironmentalInfoWidget> createState() => _EnvironmentalInfoWidgetState();
}

class _EnvironmentalInfoWidgetState extends State<EnvironmentalInfoWidget> {
  final AirQualityService _airQualityService = AirQualityService();
  final MoonPhaseService _moonPhaseService = MoonPhaseService();

  AirQuality? _airQuality;
  MoonPhase? _moonPhase;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadEnvironmentalData();
  }

  Future<void> _loadEnvironmentalData() async {
    setState(() => _isLoading = true);

    try {
      final airQuality = await _airQualityService.getAirQuality(
        latitude: widget.latitude,
        longitude: widget.longitude,
        locationName: widget.locationName,
      );

      final moonPhase = await _moonPhaseService.getCurrentMoonPhase();

      if (mounted) {
        setState(() {
          _airQuality = airQuality;
          _moonPhase = moonPhase;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_airQuality == null && _moonPhase == null) {
      return const SizedBox.shrink();
    }

    return _buildEnvironmentalCard();
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
              'Loading environmental info...',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.tropicalGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppConstants.tropicalGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Environmental Info',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Air quality & moon phase',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Summary (always visible)
          if (!_isExpanded && _airQuality != null && _moonPhase != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat(
                    _airQuality!.emoji,
                    'Air: ${_airQuality!.category}',
                    _airQuality!.color,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey[300]),
                  _buildQuickStat(
                    _moonPhase!.emoji,
                    _moonPhase!.phaseName,
                    AppConstants.deepOceanBlue,
                  ),
                ],
              ),
            ),

          // Detailed content (expanded)
          if (_isExpanded) ...[
            const Divider(),

            // Air Quality Section
            if (_airQuality != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _airQuality!.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Air Quality',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _airQuality!.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'AQI ${_airQuality!.aqiDisplay}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _airQuality!.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _airQuality!.category,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _airQuality!.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                        color: _airQuality!.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _airQuality!.healthAdvice,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Moon Phase Section
            if (_moonPhase != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _moonPhase!.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Moon Phase',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _moonPhase!.phaseName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppConstants.deepOceanBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_moonPhase!.illuminationPercentage} illuminated',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Photography Tips
                    if (_moonPhase!.photographyTips.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.sunsetOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: AppConstants.sunsetOrange,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Photography Tips',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.sunsetOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...(_moonPhase!.photographyTips.take(2).map((tip) =>
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[700])),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Beach Activities
                    if (_moonPhase!.beachActivities.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.deepOceanBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.beach_access,
                                  size: 16,
                                  color: AppConstants.deepOceanBlue,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Beach & Tides',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.deepOceanBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...(_moonPhase!.beachActivities.take(2).map((tip) =>
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('• ',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[700])),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStat(String emoji, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
