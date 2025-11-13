import 'package:flutter/material.dart';
import '../utils/constants.dart';

// SIM Card Guide Screen
class SIMCardGuideScreen extends StatelessWidget {
  const SIMCardGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIM Card & WiFi Guide'),
        backgroundColor: AppConstants.tropicalGreen,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProviderCard(
            'Dialog',
            'Most popular network with best coverage',
            [
              'Tourist SIM: LKR 1,300 (9GB data + calls)',
              'Data packages: From LKR 50 for 1GB',
              'Available at: Airport, Dialog shops',
              'Coverage: Excellent nationwide',
            ],
            Colors.red,
          ),
          _buildProviderCard(
            'Mobitel',
            'Good coverage, competitive prices',
            [
              'Tourist SIM: LKR 1,000 (5GB data + calls)',
              'Data packages: From LKR 49 for 1GB',
              'Available at: Airport, Mobitel shops',
              'Coverage: Very good in cities',
            ],
            Colors.orange,
          ),
          _buildProviderCard(
            'Airtel',
            'Budget-friendly option',
            [
              'Tourist SIM: LKR 850 (4GB data + calls)',
              'Data packages: From LKR 40 for 1GB',
              'Available at: Airport, Airtel shops',
              'Coverage: Good in major areas',
            ],
            Colors.red[300]!,
          ),
          _buildProviderCard(
            'Hutch',
            'Competitive data plans',
            [
              'Tourist SIM: LKR 900 (5GB data + calls)',
              'Data packages: From LKR 45 for 1GB',
              'Available at: Airport, Hutch shops',
              'Coverage: Good in main cities',
            ],
            Colors.purple,
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Bring your passport for SIM registration\n'
                    '• Airport counters open 24/7\n'
                    '• SIM cards activated immediately\n'
                    '• Top-up available at shops, kiosks, online\n'
                    '• Free WiFi at most hotels and cafes\n'
                    '• Check roaming charges with home carrier',
                    style: TextStyle(fontSize: 14, height: 1.8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📍 Where to Buy',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLocationItem(
                      'Bandaranaike Airport', 'Arrivals hall, open 24/7'),
                  _buildLocationItem('Colombo Fort', 'Multiple provider shops'),
                  _buildLocationItem('Kandy City', 'Main Street shops'),
                  _buildLocationItem('Galle Fort', 'Tourist area shops'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
      String name, String description, List<String> details, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sim_card, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(detail, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(String place, String details) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 16, color: AppConstants.sunsetOrange),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(place,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(details,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Visa Information Screen
class VisaInfoScreen extends StatelessWidget {
  const VisaInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visa Information'),
        backgroundColor: AppConstants.sunsetOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Electronic Travel Authorization (ETA)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Most visitors can apply online for an ETA before traveling to Sri Lanka.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildVisaTypeCard(
            'Tourist ETA',
            'For tourism and leisure',
            [
              'Duration: 30 days (extendable to 6 months)',
              'Fee: USD 50 (online application)',
              'Processing: Instant to 24 hours',
              'Multiple entry: Not permitted',
              'Apply: www.eta.gov.lk',
            ],
            Icons.beach_access,
            Colors.blue,
          ),
          _buildVisaTypeCard(
            'Business ETA',
            'For business purposes',
            [
              'Duration: 30 days',
              'Fee: USD 100',
              'Processing: 24-48 hours',
              'Requirements: Business invitation letter',
              'Apply: www.eta.gov.lk',
            ],
            Icons.business,
            Colors.orange,
          ),
          _buildVisaTypeCard(
            'Transit Visa',
            'For airport transit',
            [
              'Duration: 48 hours',
              'Fee: USD 25',
              'Requirements: Onward ticket',
              'Not required for some nationalities',
              'Apply: At airport or online',
            ],
            Icons.flight_takeoff,
            Colors.purple,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🆓 Visa-Free Countries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Maldives, Seychelles, Singapore (30 days free)',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 Required Documents',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirement('Valid passport (6 months validity)'),
                  _buildRequirement('Return/onward ticket'),
                  _buildRequirement('Sufficient funds proof'),
                  _buildRequirement('Hotel booking confirmation'),
                  _buildRequirement('Travel insurance (recommended)'),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Important Notes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Apply for ETA at least 48 hours before travel\n'
                    '• Print ETA approval and carry with passport\n'
                    '• Visa extension available at Department of Immigration\n'
                    '• Overstay penalties apply (fines + deportation)\n'
                    '• Check latest requirements before travel',
                    style: TextStyle(fontSize: 14, height: 1.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaTypeCard(String title, String subtitle, List<String> details,
      IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(detail, style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: AppConstants.tropicalGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

// Transportation Guide Screen
class TransportationGuideScreen extends StatelessWidget {
  const TransportationGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transportation Guide'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTransportCard(
            '🚂 Trains',
            'Scenic & affordable',
            [
              'Colombo to Kandy: 2.5-3 hours, LKR 180-1,000',
              'Colombo to Ella: 7-9 hours, LKR 300-1,500',
              'Book online: www.railway.gov.lk',
              '1st class reservations recommended',
              'Scenic routes: Kandy-Ella, Colombo-Galle',
            ],
            Colors.blue,
          ),
          _buildTransportCard(
            '🚌 Buses',
            'Extensive network',
            [
              'Government (CTB): Cheap, slower',
              'Private: More comfortable, AC available',
              'Intercity Express: Fastest option',
              'Fares: LKR 50-500 depending on distance',
              'Buy tickets at bus stands or on board',
            ],
            Colors.orange,
          ),
          _buildTransportCard(
            '🛺 Tuk-Tuks',
            'Convenient local transport',
            [
              'Negotiate fare before starting',
              'Short trips: LKR 100-300',
              'Longer trips: LKR 50-80 per km',
              'Use PickMe or Uber apps for fixed rates',
              'Carry small notes for payment',
            ],
            Colors.green,
          ),
          _buildTransportCard(
            '🚕 Taxis & Ride Apps',
            'Comfortable & metered',
            [
              'Uber available in major cities',
              'PickMe: Local ride-hailing app',
              'Airport taxis: LKR 3,000-4,000 to Colombo',
              'Metered taxis available',
              'Day hire: LKR 6,000-10,000',
            ],
            Colors.purple,
          ),
          _buildTransportCard(
            '🚗 Car Rental',
            'Self-drive or with driver',
            [
              'International license required',
              'Drive on left side',
              'With driver recommended',
              'Cost: USD 40-80 per day',
              'Fuel: LKR 350-400 per liter',
            ],
            Colors.red,
          ),
          _buildTransportCard(
            '✈️ Domestic Flights',
            'Quick inter-city travel',
            [
              'Cinnamon Air: Seaplane services',
              'FitsAir: Domestic flights',
              'Colombo to Jaffna: ~1 hour',
              'Colombo to Trincomalee: ~45 min',
              'Book in advance for best prices',
            ],
            Colors.cyan,
          ),
          Card(
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Pro Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Book train tickets early for popular routes\n'
                    '• Use Google Maps for bus routes\n'
                    '• Keep change ready for buses\n'
                    '• Download PickMe and Uber apps\n'
                    '• Traffic heavy in Colombo 7-10am, 4-7pm\n'
                    '• Hire drivers for multi-day trips',
                    style: TextStyle(fontSize: 14, height: 1.8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(String title, String subtitle,
      List<String> details, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(detail,
                            style: const TextStyle(fontSize: 13, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
