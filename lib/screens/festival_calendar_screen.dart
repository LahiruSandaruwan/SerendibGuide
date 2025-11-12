import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

/// Festival calendar for Sri Lankan holidays and celebrations
class FestivalCalendarScreen extends StatelessWidget {
  const FestivalCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Festival Calendar'),
        backgroundColor: AppConstants.premiumGold,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: AppConstants.premiumGold.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.celebration, size: 40, color: AppConstants.premiumGold),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Festivals & Holidays',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Experience Sri Lankan celebrations',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Poya Days Info
          _buildInfoCard(
            title: 'Poya Days (Full Moon Days)',
            icon: Icons.nightlight_round,
            color: AppConstants.deepOceanBlue,
            description: 'Buddhist public holidays observed on full moon days each month. Government offices, banks, and most businesses are closed. No alcohol sales allowed.',
          ),

          const SizedBox(height: 24),

          // Major Festivals
          _buildSectionHeader('Major Festivals'),

          _buildFestivalCard(
            name: 'Sinhala & Tamil New Year',
            date: 'April 13-14',
            color: AppConstants.sunsetOrange,
            description: 'The most important cultural celebration. Traditional games, oil lamp lighting, eating kiribath (milk rice), and exchanging gifts.',
            tips: [
              'Many businesses close for 2-3 days',
              'Hotels and attractions remain open',
              'Great time to experience traditional customs',
            ],
            icon: Icons.wb_sunny,
          ),

          _buildFestivalCard(
            name: 'Vesak (Buddha\'s Birthday)',
            date: 'May (Full Moon)',
            color: AppConstants.premiumGold,
            description: 'Celebrates Buddha\'s birth, enlightenment, and death. Beautiful lanterns, pandals (decorated stages), and free food stalls called dansalas.',
            tips: [
              'Cities beautifully illuminated',
              'Free food and drinks everywhere',
              'No alcohol sales for 3 days',
              'Visit Colombo or Kandy for best displays',
            ],
            icon: Icons.temple_buddhist,
          ),

          _buildFestivalCard(
            name: 'Esala Perahera (Kandy)',
            date: 'July/August (10 days)',
            color: AppConstants.tropicalGreen,
            description: 'Sri Lanka\'s grandest festival. Spectacular procession with decorated elephants, dancers, drummers, and fire performers carrying the sacred tooth relic.',
            tips: [
              'Book accommodation months in advance',
              'Procession starts at 8 PM',
              'Final night (Randoli) is most spectacular',
              'Arrive early for good viewing spots',
            ],
            icon: Icons.celebration,
          ),

          _buildFestivalCard(
            name: 'Deepavali (Festival of Lights)',
            date: 'October/November',
            color: Colors.orange,
            description: 'Tamil Hindu festival celebrating victory of light over darkness. Homes decorated with oil lamps, fireworks, and special sweets.',
            tips: [
              'Best experienced in Colombo or Jaffna',
              'Sweet shops offer special treats',
              'Temples beautifully decorated',
            ],
            icon: Icons.light_mode,
          ),

          _buildFestivalCard(
            name: 'Christmas',
            date: 'December 25',
            color: Colors.red,
            description: 'Celebrated by the Christian community with church services, carol singing, and family gatherings. Cities decorated with lights and Christmas trees.',
            tips: [
              'Many hotels offer special Christmas dinners',
              'Church services in English available',
              'Festive atmosphere in Colombo and Negombo',
            ],
            icon: Icons.card_giftcard,
          ),

          const SizedBox(height: 24),

          // Monthly Poya Days
          _buildSectionHeader('$currentYear Poya Days'),

          ..._buildPoyaDays(currentYear),

          const SizedBox(height: 24),

          // Other Important Dates
          _buildSectionHeader('Other Important Dates'),

          _buildDateCard(
            'Independence Day',
            'February 4',
            'National holiday celebrating independence from British rule in 1948.',
            Icons.flag,
            AppConstants.deepOceanBlue,
          ),

          _buildDateCard(
            'May Day',
            'May 1',
            'International Workers\' Day. Public holiday with processions and rallies.',
            Icons.groups,
            AppConstants.tropicalGreen,
          ),

          _buildDateCard(
            'Kataragama Festival',
            'July/August',
            'Hindu festival in southern Sri Lanka with fire-walking and body piercing rituals.',
            Icons.whatshot,
            Colors.deepOrange,
          ),

          _buildDateCard(
            'Duruthu Perahera',
            'January (Full Moon)',
            'First major perahera of the year at Kelaniya Temple, Colombo.',
            Icons.temple_buddhist,
            AppConstants.premiumGold,
          ),

          const SizedBox(height: 24),

          // Tips Card
          Card(
            color: AppConstants.sunsetOrange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: AppConstants.sunsetOrange),
                      SizedBox(width: 8),
                      Text(
                        'Festival Travel Tips',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Book accommodation well in advance for major festivals'),
                  _buildTip('Poya days: banks, government offices, and liquor stores closed'),
                  _buildTip('Dress modestly when attending religious festivals'),
                  _buildTip('Ask permission before photographing ceremonies'),
                  _buildTip('Public transport may be crowded during festivals'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.4,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFestivalCard({
    required String name,
    required String date,
    required Color color,
    required String description,
    required List<String> tips,
    required IconData icon,
  }) {
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, size: 16, color: color),
                      const SizedBox(width: 6),
                      const Text(
                        'Visitor Tips',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPoyaDays(int year) {
    // Approximate Poya days for reference
    final poyaDays = [
      {'month': 'January', 'name': 'Duruthu Poya', 'significance': 'Buddha\'s first visit to Sri Lanka'},
      {'month': 'February', 'name': 'Navam Poya', 'significance': 'Buddha announces his passing'},
      {'month': 'March', 'name': 'Medin Poya', 'significance': 'Buddha\'s first return home'},
      {'month': 'April', 'name': 'Bak Poya', 'significance': 'Buddha\'s second visit to Sri Lanka'},
      {'month': 'May', 'name': 'Vesak Poya', 'significance': 'Birth, enlightenment & death of Buddha'},
      {'month': 'June', 'name': 'Poson Poya', 'significance': 'Introduction of Buddhism to Sri Lanka'},
      {'month': 'July', 'name': 'Esala Poya', 'significance': 'Buddha\'s first sermon'},
      {'month': 'August', 'name': 'Nikini Poya', 'significance': 'First Buddhist Council'},
      {'month': 'September', 'name': 'Binara Poya', 'significance': 'Buddha visits heaven'},
      {'month': 'October', 'name': 'Vap Poya', 'significance': 'End of Buddha\'s retreat'},
      {'month': 'November', 'name': 'Il Poya', 'significance': 'Buddha ordains disciples'},
      {'month': 'December', 'name': 'Unduvap Poya', 'significance': 'Sanghamitta brings Bo sapling'},
    ];

    return poyaDays.map((poya) {
      return _buildDateCard(
        poya['name']!,
        '${poya['month']} (Full Moon)',
        poya['significance']!,
        Icons.nightlight_round,
        AppConstants.deepOceanBlue,
      );
    }).toList();
  }

  Widget _buildDateCard(
    String title,
    String date,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              date,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
