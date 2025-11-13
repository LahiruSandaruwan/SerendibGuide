import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/embassy.dart';
import '../utils/constants.dart';

/// Comprehensive safety and travel guide
class SafetyTravelGuideScreen extends StatelessWidget {
  const SafetyTravelGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety & Travel Guide'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            context,
            icon: Icons.local_hospital,
            title: 'Embassy Directory',
            subtitle: 'Contact your embassy in Sri Lanka',
            color: AppConstants.deepOceanBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _EmbassyDirectoryScreen(),
                ),
              );
            },
          ),

          _buildSectionCard(
            context,
            icon: Icons.shield,
            title: 'Safety Tips',
            subtitle: 'Important safety information',
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _SafetyTipsScreen(),
                ),
              );
            },
          ),

          _buildSectionCard(
            context,
            icon: Icons.badge,
            title: 'Lost Document Helper',
            subtitle: 'What to do if you lose passport/cards',
            color: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _LostDocumentScreen(),
                ),
              );
            },
          ),

          _buildSectionCard(
            context,
            icon: Icons.sim_card,
            title: 'SIM Card & WiFi Guide',
            subtitle: 'Get connected in Sri Lanka',
            color: AppConstants.tropicalGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _SIMCardGuideScreen(),
                ),
              );
            },
          ),

          _buildSectionCard(
            context,
            icon: Icons.flight,
            title: 'Visa Information',
            subtitle: 'Entry requirements and visa guide',
            color: AppConstants.sunsetOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _VisaInfoScreen(),
                ),
              );
            },
          ),

          _buildSectionCard(
            context,
            icon: Icons.directions_bus,
            title: 'Transportation Guide',
            subtitle: 'Trains, buses, taxis & tuk-tuks',
            color: AppConstants.deepOceanBlue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _TransportationGuideScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// Embassy Directory Screen
class _EmbassyDirectoryScreen extends StatefulWidget {
  const _EmbassyDirectoryScreen();

  @override
  State<_EmbassyDirectoryScreen> createState() =>
      _EmbassyDirectoryScreenState();
}

class _EmbassyDirectoryScreenState extends State<_EmbassyDirectoryScreen> {
  String _searchQuery = '';

  List<Embassy> _getFilteredEmbassies() {
    var embassies = EmbassiesData.getAllEmbassies();
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      embassies = embassies.where((e) {
        return e.country.toLowerCase().contains(query) ||
            e.address.toLowerCase().contains(query);
      }).toList();
    }
    return embassies;
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final embassies = _getFilteredEmbassies();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Embassy Directory'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search embassies...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: embassies.length,
              itemBuilder: (context, index) {
                final embassy = embassies[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Text(
                      _getCountryFlag(embassy.country),
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(embassy.country),
                    subtitle: Text(embassy.name),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.location_on, embassy.address),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.phone, embassy.phone,
                                onTap: () => _makeCall(embassy.phone)),
                            if (embassy.emergencyPhone != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                  Icons.emergency, embassy.emergencyPhone!,
                                  onTap: () =>
                                      _makeCall(embassy.emergencyPhone!),
                                  color: Colors.red),
                            ],
                            if (embassy.email != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.email, embassy.email!,
                                  onTap: () => _copyText(embassy.email!)),
                            ],
                            if (embassy.website != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.language, embassy.website!,
                                  onTap: () => _copyText(embassy.website!)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {VoidCallback? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: color ?? Colors.grey[800]),
            ),
          ),
          if (onTap != null)
            Icon(Icons.touch_app, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  String _getCountryFlag(String country) {
    final flags = {
      'United States': '🇺🇸',
      'United Kingdom': '🇬🇧',
      'Australia': '🇦🇺',
      'Canada': '🇨🇦',
      'India': '🇮🇳',
      'China': '🇨🇳',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Japan': '🇯🇵',
      'Russia': '🇷🇺',
      'Netherlands': '🇳🇱',
      'Italy': '🇮🇹',
      'South Korea': '🇰🇷',
      'Pakistan': '🇵🇰',
      'Bangladesh': '🇧🇩',
      'Thailand': '🇹🇭',
      'Malaysia': '🇲🇾',
      'Singapore': '🇸🇬',
      'Maldives': '🇲🇻',
      'Norway': '🇳🇴',
    };
    return flags[country] ?? '🏛️';
  }
}

// Safety Tips Screen
class _SafetyTipsScreen extends StatelessWidget {
  const _SafetyTipsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Tips'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            '🚨 Emergency Numbers',
            [
              'Police: 119',
              'Ambulance: 1990',
              'Fire: 110',
              'Tourist Police: 011-2421111',
              'Tourism Helpline: 1912',
            ],
            Colors.red,
          ),
          _buildTipCard(
            '💰 Money & Valuables',
            [
              'Use hotel safes for passports and valuables',
              'Carry photocopies of important documents',
              'Be cautious of pickpockets in crowded areas',
              'Use ATMs in banks or secure locations',
              'Don\'t flash expensive jewelry or cameras',
            ],
            Colors.orange,
          ),
          _buildTipCard(
            '🚗 Transportation',
            [
              'Use registered taxis or ride-sharing apps',
              'Negotiate tuk-tuk fares before starting',
              'Wear helmets when on motorbikes',
              'Avoid traveling alone late at night',
              'Check train/bus schedules in advance',
            ],
            Colors.blue,
          ),
          _buildTipCard(
            '🏖️ Beach & Water Safety',
            [
              'Swim only in designated safe areas',
              'Be aware of strong currents',
              'Apply high SPF sunscreen regularly',
              'Stay hydrated in hot weather',
              'Watch for warning flags on beaches',
            ],
            Colors.cyan,
          ),
          _buildTipCard(
            '🦎 Wildlife & Nature',
            [
              'Keep safe distance from elephants',
              'Don\'t feed wild animals',
              'Wear appropriate footwear for hiking',
              'Stay on marked trails',
              'Check for leeches in rainy season',
            ],
            Colors.green,
          ),
          _buildTipCard(
            '🏛️ Temple Etiquette',
            [
              'Dress modestly (cover shoulders & knees)',
              'Remove shoes before entering',
              'Don\'t pose for photos with Buddha statues',
              'Ask permission before photographing monks',
              'Don\'t turn your back to Buddha images',
            ],
            Colors.purple,
          ),
          _buildTipCard(
            '🍽️ Food & Water',
            [
              'Drink only bottled or boiled water',
              'Eat at clean, busy restaurants',
              'Wash hands before eating',
              'Be cautious with street food initially',
              'Peel fruits yourself when possible',
            ],
            Colors.teal,
          ),
          _buildTipCard(
            '📱 Communication',
            [
              'Buy a local SIM card for reliable contact',
              'Share your itinerary with family/friends',
              'Keep embassy contact numbers saved',
              'Learn basic Sinhala/Tamil phrases',
              'Have offline maps downloaded',
            ],
            AppConstants.deepOceanBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, List<String> tips, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            const SizedBox(height: 12),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
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

// Lost Document Helper Screen
class _LostDocumentScreen extends StatelessWidget {
  const _LostDocumentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Document Helper'),
        backgroundColor: Colors.red,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDocumentCard(
            '🛂 Lost Passport',
            [
              '1. File a police report immediately at nearest station',
              '2. Contact your embassy/consulate with:',
              '   • Police report copy',
              '   • Passport photos (2)',
              '   • Copy of lost passport (if available)',
              '   • Proof of citizenship',
              '3. Apply for emergency travel document',
              '4. Notify your accommodation',
              '5. Check if travel insurance covers replacement',
            ],
            Colors.red,
          ),
          _buildDocumentCard(
            '💳 Lost Credit/Debit Cards',
            [
              '1. Call your bank immediately to block cards',
              '2. Report to police if theft suspected',
              '3. Request emergency replacement card',
              '4. Use card-free payment apps if available',
              '5. Notify credit bureaus if identity theft risk',
              '6. Keep emergency cash separate',
            ],
            Colors.orange,
          ),
          _buildDocumentCard(
            '📱 Lost Phone',
            [
              '1. Use Find My Device (Android) or Find My iPhone',
              '2. Call your number from another phone',
              '3. Report to police if stolen',
              '4. Contact your mobile carrier to block SIM',
              '5. Change passwords for important accounts',
              '6. File insurance claim if covered',
            ],
            Colors.blue,
          ),
          _buildDocumentCard(
            '💼 Lost Wallet/Purse',
            [
              '1. Cancel all credit/debit cards immediately',
              '2. File police report',
              '3. Contact your embassy if passport inside',
              '4. Replace driver\'s license/ID cards',
              '5. Monitor bank accounts for fraud',
              '6. Update any membership cards',
            ],
            Colors.purple,
          ),
          _buildDocumentCard(
            '🎫 Lost Travel Tickets',
            [
              '1. Contact the airline/bus/train company',
              '2. Provide booking reference number',
              '3. Request ticket reissue (may incur fee)',
              '4. Check email for digital copies',
              '5. Visit ticket office with ID proof',
            ],
            Colors.green,
          ),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Prevention Tips',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Keep photocopies of all documents separately\n'
                    '• Email yourself scans of important documents\n'
                    '• Use hotel safes for valuables\n'
                    '• Keep emergency cash hidden separately\n'
                    '• Note down important phone numbers offline',
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String title, List<String> steps, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            const SizedBox(height: 12),
            ...steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    step,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// Continued in next message due to length...
