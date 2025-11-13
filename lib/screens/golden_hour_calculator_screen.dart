import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

/// Golden hour calculator for photography enthusiasts
class GoldenHourCalculatorScreen extends StatefulWidget {
  const GoldenHourCalculatorScreen({super.key});

  @override
  State<GoldenHourCalculatorScreen> createState() => _GoldenHourCalculatorScreenState();
}

class _GoldenHourCalculatorScreenState extends State<GoldenHourCalculatorScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedLocation = 'Colombo';

  // Key Sri Lankan locations with coordinates
  final Map<String, Map<String, double>> _locations = {
    'Colombo': {'lat': 6.9271, 'lng': 79.8612},
    'Kandy': {'lat': 7.2906, 'lng': 80.6337},
    'Galle': {'lat': 6.0535, 'lng': 80.2210},
    'Sigiriya': {'lat': 7.9569, 'lng': 80.7597},
    'Ella': {'lat': 6.8667, 'lng': 81.0467},
    'Nuwara Eliya': {'lat': 6.9497, 'lng': 80.7891},
    'Mirissa': {'lat': 5.9450, 'lng': 80.4687},
    'Yala': {'lat': 6.3715, 'lng': 81.5198},
    'Trincomalee': {'lat': 8.5874, 'lng': 81.2152},
    'Jaffna': {'lat': 9.6615, 'lng': 80.0255},
    'Anuradhapura': {'lat': 8.3114, 'lng': 80.4037},
    'Polonnaruwa': {'lat': 7.9403, 'lng': 81.0188},
  };

  @override
  Widget build(BuildContext context) {
    final coordinates = _locations[_selectedLocation]!;
    final sunTimes = _calculateSunTimes(
      coordinates['lat']!,
      coordinates['lng']!,
      _selectedDate,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Hour Calculator'),
        backgroundColor: AppConstants.sunsetOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: AppConstants.sunsetOrange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, size: 50, color: AppConstants.sunsetOrange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Perfect Light Finder',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Best photography times for stunning shots',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Location selection
            const Text(
              'Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _locations.keys.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLocation = value!);
              },
            ),

            const SizedBox(height: 16),

            // Date selection
            const Text(
              'Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 7)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current time indicator
            _buildTimeIndicator(sunTimes),

            const SizedBox(height: 24),

            // Golden hours
            const Text(
              'Golden Hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Warm, soft light perfect for portraits and landscapes',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            _buildTimeCard(
              'Morning Golden Hour',
              Icons.wb_twilight,
              Colors.orange.shade300,
              sunTimes['sunrise']!,
              sunTimes['morningGoldenEnd']!,
              'Best for: East-facing monuments, landscapes, portraits',
            ),

            const SizedBox(height: 12),

            _buildTimeCard(
              'Evening Golden Hour',
              Icons.wb_twilight,
              Colors.deepOrange.shade400,
              sunTimes['eveningGoldenStart']!,
              sunTimes['sunset']!,
              'Best for: West-facing views, sunsets, silhouettes',
            ),

            const SizedBox(height: 24),

            // Blue hours
            const Text(
              'Blue Hours',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cool, even light ideal for cityscapes and architecture',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            _buildTimeCard(
              'Morning Blue Hour',
              Icons.nightlight,
              Colors.blue.shade300,
              sunTimes['morningBlueStart']!,
              sunTimes['sunrise']!,
              'Best for: Cityscapes, architecture, long exposures',
            ),

            const SizedBox(height: 12),

            _buildTimeCard(
              'Evening Blue Hour',
              Icons.nights_stay,
              Colors.indigo.shade400,
              sunTimes['sunset']!,
              sunTimes['eveningBlueEnd']!,
              'Best for: City lights, twilight scenes, reflections',
            ),

            const SizedBox(height: 24),

            // Sun position
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sun Times',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildSunTimeRow('Sunrise', sunTimes['sunrise']!, Icons.wb_sunny, Colors.orange),
                    const SizedBox(height: 8),
                    _buildSunTimeRow('Solar Noon', sunTimes['solarNoon']!, Icons.wb_sunny_outlined, Colors.amber),
                    const SizedBox(height: 8),
                    _buildSunTimeRow('Sunset', sunTimes['sunset']!, Icons.nights_stay, Colors.deepOrange),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timelapse, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Daylight: ${_formatDuration(sunTimes['dayLength']!)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photography tips
            Card(
              color: AppConstants.tropicalGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.camera_alt, color: AppConstants.tropicalGreen),
                        SizedBox(width: 8),
                        Text(
                          'Photography Tips',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Arrive 30 minutes early to scout and set up'),
                    _buildTip('Golden hour lasts about 1 hour - work quickly'),
                    _buildTip('Avoid harsh midday sun (11 AM - 2 PM)'),
                    _buildTip('Use manual mode for consistent exposure'),
                    _buildTip('Bring a tripod for blue hour long exposures'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location-specific tips
            _buildLocationTips(_selectedLocation),

            const SizedBox(height: 16),

            // Info disclaimer
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Times are calculated using astronomical formulas and may vary by a few minutes. Weather conditions greatly affect light quality.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeIndicator(Map<String, dynamic> sunTimes) {
    final now = DateTime.now();
    final sunrise = sunTimes['sunrise']!;
    final sunset = sunTimes['sunset']!;

    String status;
    Color color;
    IconData icon;

    if (now.isBefore(sunTimes['morningBlueStart']!)) {
      status = 'Night Time';
      color = Colors.indigo;
      icon = Icons.nightlight;
    } else if (now.isBefore(sunrise)) {
      status = 'Morning Blue Hour';
      color = Colors.blue;
      icon = Icons.wb_twilight;
    } else if (now.isBefore(sunTimes['morningGoldenEnd']!)) {
      status = 'Morning Golden Hour';
      color = Colors.orange;
      icon = Icons.wb_sunny;
    } else if (now.isBefore(sunTimes['eveningGoldenStart']!)) {
      status = 'Daytime';
      color = Colors.yellow.shade700;
      icon = Icons.wb_sunny_outlined;
    } else if (now.isBefore(sunset)) {
      status = 'Evening Golden Hour';
      color = Colors.deepOrange;
      icon = Icons.wb_twilight;
    } else if (now.isBefore(sunTimes['eveningBlueEnd']!)) {
      status = 'Evening Blue Hour';
      color = Colors.indigo;
      icon = Icons.nights_stay;
    } else {
      status = 'Night Time';
      color = Colors.indigo.shade900;
      icon = Icons.nightlight;
    }

    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Light Condition',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
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

  Widget _buildTimeCard(
    String title,
    IconData icon,
    Color color,
    DateTime start,
    DateTime end,
    String description,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(start),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'End',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('h:mm a').format(end),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                description,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunTimeRow(String label, DateTime time, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label),
        ),
        Text(
          DateFormat('h:mm a').format(time),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTips(String location) {
    final Map<String, List<String>> locationTips = {
      'Sigiriya': [
        'Climb early for sunrise - gates open at 7 AM',
        'Evening light makes the rock glow golden',
        'Bring water - it\'s a strenuous climb',
      ],
      'Ella': [
        'Nine Arch Bridge best at morning golden hour',
        'Little Adam\'s Peak perfect for sunrise',
        'Ella Rock offers 360° views',
      ],
      'Galle': [
        'Fort walls stunning during evening golden hour',
        'Sunset from lighthouse is iconic',
        'Blue hour great for colonial architecture',
      ],
      'Kandy': [
        'Temple of Tooth beautiful in morning light',
        'Kandy Lake reflections best at blue hour',
        'Evening prayers create atmospheric photos',
      ],
    };

    if (!locationTips.containsKey(location)) {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppConstants.deepOceanBlue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppConstants.deepOceanBlue),
                const SizedBox(width: 8),
                Text(
                  '$location Photo Tips',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...locationTips[location]!.map((tip) => _buildTip(tip)).toList(),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  /// Calculate sun times using simplified astronomical formulas
  /// Based on NOAA solar calculations
  Map<String, dynamic> _calculateSunTimes(double latitude, double longitude, DateTime date) {
    // Julian day calculation
    final julianDay = _toJulianDay(date);
    final julianCentury = (julianDay - 2451545.0) / 36525.0;

    // Sun's geometric mean longitude (degrees)
    final geomMeanLongSun = (280.46646 + julianCentury * (36000.76983 + julianCentury * 0.0003032)) % 360;

    // Sun's geometric mean anomaly (degrees)
    final geomMeanAnomSun = 357.52911 + julianCentury * (35999.05029 - 0.0001537 * julianCentury);

    // Equation of center
    final sinM = sin(_degreesToRadians(geomMeanAnomSun));
    final sunEqOfCenter = sinM * (1.914602 - julianCentury * (0.004817 + 0.000014 * julianCentury));

    // Sun's true longitude
    final sunTrueLong = geomMeanLongSun + sunEqOfCenter;

    // Equation of time (minutes)
    final obliqCorr = 23.0 + (26.0 + ((21.448 - julianCentury * (46.815 + julianCentury * (0.00059 - julianCentury * 0.001813)))) / 60.0) / 60.0;
    final y = tan(_degreesToRadians(obliqCorr / 2)) * tan(_degreesToRadians(obliqCorr / 2));
    final eqOfTime = 4 * _radiansToDegrees(
      y * sin(2 * _degreesToRadians(geomMeanLongSun)) -
      2 * 0.016708634 * sin(_degreesToRadians(geomMeanAnomSun)) +
      4 * 0.016708634 * y * sin(_degreesToRadians(geomMeanAnomSun)) * cos(2 * _degreesToRadians(geomMeanLongSun)) -
      0.5 * y * y * sin(4 * _degreesToRadians(geomMeanLongSun)) -
      1.25 * 0.016708634 * 0.016708634 * sin(2 * _degreesToRadians(geomMeanAnomSun))
    );

    // Solar noon (minutes from midnight)
    final solarNoonMinutes = (720 - 4 * longitude - eqOfTime);

    // Hour angle for sunrise/sunset (90.833° accounts for atmospheric refraction)
    final hourAngle = _radiansToDegrees(acos(
      cos(_degreesToRadians(90.833)) / (cos(_degreesToRadians(latitude)) * cos(_degreesToRadians(23.44))) -
      tan(_degreesToRadians(latitude)) * tan(_degreesToRadians(23.44))
    ));

    final sunriseMinutes = solarNoonMinutes - hourAngle * 4;
    final sunsetMinutes = solarNoonMinutes + hourAngle * 4;

    // Create DateTime objects
    final sunrise = _minutesToDateTime(date, sunriseMinutes);
    final sunset = _minutesToDateTime(date, sunsetMinutes);
    final solarNoon = _minutesToDateTime(date, solarNoonMinutes);

    // Golden hours (1 hour after sunrise, 1 hour before sunset)
    final morningGoldenEnd = sunrise.add(const Duration(hours: 1));
    final eveningGoldenStart = sunset.subtract(const Duration(hours: 1));

    // Blue hours (40 minutes before sunrise, 40 minutes after sunset)
    final morningBlueStart = sunrise.subtract(const Duration(minutes: 40));
    final eveningBlueEnd = sunset.add(const Duration(minutes: 40));

    return {
      'sunrise': sunrise,
      'sunset': sunset,
      'solarNoon': solarNoon,
      'morningGoldenEnd': morningGoldenEnd,
      'eveningGoldenStart': eveningGoldenStart,
      'morningBlueStart': morningBlueStart,
      'eveningBlueEnd': eveningBlueEnd,
      'dayLength': sunset.difference(sunrise),
    };
  }

  double _toJulianDay(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;

    return date.day + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045.5;
  }

  DateTime _minutesToDateTime(DateTime date, double minutes) {
    final hours = minutes ~/ 60;
    final mins = (minutes % 60).round();
    return DateTime(date.year, date.month, date.day, hours, mins);
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180.0;
  double _radiansToDegrees(double radians) => radians * 180.0 / pi;
}
