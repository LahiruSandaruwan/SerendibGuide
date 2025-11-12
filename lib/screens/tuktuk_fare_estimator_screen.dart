import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

/// Tuk-tuk (three-wheeler) fare estimator for Sri Lanka
class TukTukFareEstimatorScreen extends StatefulWidget {
  const TukTukFareEstimatorScreen({super.key});

  @override
  State<TukTukFareEstimatorScreen> createState() => _TukTukFareEstimatorScreenState();
}

class _TukTukFareEstimatorScreenState extends State<TukTukFareEstimatorScreen> {
  final TextEditingController _distanceController = TextEditingController(text: '5');
  final TextEditingController _waitingController = TextEditingController(text: '0');

  bool _isMetered = true;
  bool _isNightTime = false;
  String _cityType = 'Colombo';

  // Base rates (LKR)
  final double _meteredBaseRate = 50.0;
  final double _meteredPerKm = 60.0;
  final double _nonMeteredPerKm = 80.0;
  final double _waitingChargePerMinute = 5.0;
  final double _nightSurchargePercent = 20.0;

  // City multipliers
  final Map<String, double> _cityMultipliers = {
    'Colombo': 1.0,
    'Kandy': 0.9,
    'Galle': 0.85,
    'Other Cities': 0.8,
    'Rural Areas': 0.7,
  };

  // Sample common routes
  final List<Map<String, dynamic>> _commonRoutes = [
    {'from': 'Bandaranaike Airport', 'to': 'Colombo Fort', 'km': 35, 'price': 2500},
    {'from': 'Colombo Fort', 'to': 'Mount Lavinia', 'km': 12, 'price': 800},
    {'from': 'Kandy City', 'to': 'Temple of Tooth', 'km': 2, 'price': 200},
    {'from': 'Galle Fort', 'to': 'Unawatuna Beach', 'km': 6, 'price': 500},
    {'from': 'Negombo Beach', 'to': 'Negombo Town', 'km': 3, 'price': 250},
  ];

  @override
  void dispose() {
    _distanceController.dispose();
    _waitingController.dispose();
    super.dispose();
  }

  Map<String, double> _calculateFare() {
    final double distance = double.tryParse(_distanceController.text) ?? 0;
    final double waitingMinutes = double.tryParse(_waitingController.text) ?? 0;
    final double cityMultiplier = _cityMultipliers[_cityType] ?? 1.0;

    double baseFare = 0;
    double distanceFare = 0;
    double waitingCharge = 0;
    double subtotal = 0;
    double nightSurcharge = 0;
    double total = 0;

    if (_isMetered) {
      // Metered fare
      baseFare = _meteredBaseRate;
      distanceFare = distance * _meteredPerKm * cityMultiplier;
    } else {
      // Non-metered (negotiated) fare
      baseFare = 0;
      distanceFare = distance * _nonMeteredPerKm * cityMultiplier;
    }

    waitingCharge = waitingMinutes * _waitingChargePerMinute;
    subtotal = baseFare + distanceFare + waitingCharge;

    if (_isNightTime) {
      nightSurcharge = subtotal * (_nightSurchargePercent / 100);
    }

    total = subtotal + nightSurcharge;

    // Round to nearest 10 rupees
    total = (total / 10).round() * 10.0;

    return {
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'waitingCharge': waitingCharge,
      'subtotal': subtotal,
      'nightSurcharge': nightSurcharge,
      'total': total,
      'fairMin': total * 0.9,
      'fairMax': total * 1.2,
    };
  }

  @override
  Widget build(BuildContext context) {
    final fare = _calculateFare();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuk-Tuk Fare Estimator'),
        backgroundColor: AppConstants.sunsetOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card with icon
            Card(
              color: AppConstants.sunsetOrange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Row(
                  children: [
                    const Icon(Icons.electric_rickshaw, size: 50, color: AppConstants.sunsetOrange),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Fair Fare Calculator',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Know the fair price before you ride',
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

            // Distance input
            const Text(
              'Trip Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.straighten),
                helperText: 'Approximate distance of your trip',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Waiting time
            TextField(
              controller: _waitingController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Waiting Time (minutes)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                helperText: 'If driver waits for you during trip',
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Meter type
            const Text(
              'Ride Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: const Text('Metered Tuk-Tuk'),
                    subtitle: const Text('Has a meter, most accurate pricing'),
                    value: true,
                    groupValue: _isMetered,
                    onChanged: (value) {
                      setState(() => _isMetered = value!);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<bool>(
                    title: const Text('Non-Metered (Negotiated)'),
                    subtitle: const Text('Price agreed before ride'),
                    value: false,
                    groupValue: _isMetered,
                    onChanged: (value) {
                      setState(() => _isMetered = value!);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // City selection
            DropdownButtonFormField<String>(
              value: _cityType,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: _cityMultipliers.keys.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _cityType = value!);
              },
            ),

            const SizedBox(height: 16),

            // Night time toggle
            SwitchListTile(
              title: const Text('Night Time (10 PM - 6 AM)'),
              subtitle: Text('+$_nightSurchargePercent% surcharge'),
              value: _isNightTime,
              onChanged: (value) {
                setState(() => _isNightTime = value);
              },
              secondary: const Icon(Icons.nightlight_round),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Fare breakdown
            const Text(
              'Estimated Fare',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_isMetered)
              _buildFareItem('Base Fare', fare['baseFare']!, Icons.flag),
            _buildFareItem('Distance Charge', fare['distanceFare']!, Icons.route),
            if (fare['waitingCharge']! > 0)
              _buildFareItem('Waiting Charge', fare['waitingCharge']!, Icons.timer),
            if (fare['nightSurcharge']! > 0)
              _buildFareItem('Night Surcharge', fare['nightSurcharge']!, Icons.nights_stay),

            const SizedBox(height: 16),
            const Divider(thickness: 2),
            const SizedBox(height: 16),

            // Fair price range
            Card(
              color: AppConstants.sunsetOrange,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  children: [
                    const Text(
                      'FAIR PRICE RANGE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'LKR ${fare['fairMin']!.round()} - ${fare['fairMax']!.round()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Expected price for this trip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Negotiation tips
            Card(
              color: AppConstants.tropicalGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tips_and_updates, color: AppConstants.tropicalGreen),
                        SizedBox(width: 8),
                        Text(
                          'Negotiation Tips',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Always prefer metered tuk-tuks for fair pricing'),
                    _buildTip('Agree on price BEFORE getting in if no meter'),
                    _buildTip('Have small bills ready - drivers may not have change'),
                    _buildTip('Use this app to show the fair price range'),
                    _buildTip('In tourist areas, initial quotes may be 2-3x fair price'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Common routes reference
            const Text(
              'Common Routes Reference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ..._commonRoutes.map((route) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppConstants.deepOceanBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${route['km']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.deepOceanBlue,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    '${route['from']} → ${route['to']}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${route['km']} km',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Text(
                    '~LKR ${route['price']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppConstants.sunsetOrange,
                    ),
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Important info
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
                        'Prices are estimates based on typical rates. Actual fares may vary based on traffic, route, and driver. Always confirm price before starting journey.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Safety tips
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.security, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Safety Tips',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTip('Share your ride details with someone you trust'),
                    _buildTip('Sit in the back for better safety and comfort'),
                    _buildTip('Use licensed tuk-tuks with visible registration'),
                    _buildTip('Trust your instincts - decline if something feels wrong'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFareItem(String label, double amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.sunsetOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            'LKR ${amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
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
}
