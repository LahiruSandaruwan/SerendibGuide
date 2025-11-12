import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Cultural etiquette guide for Sri Lanka
class EtiquetteGuideScreen extends StatelessWidget {
  const EtiquetteGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultural Etiquette'),
        backgroundColor: AppConstants.sunsetOrange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: AppConstants.sunsetOrange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.diversity_3, size: 40, color: AppConstants.sunsetOrange),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Respect & Connect',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Understanding Sri Lankan customs',
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

          // Temple Etiquette
          _buildSection(
            title: 'Temple Etiquette',
            icon: Icons.temple_buddhist,
            color: AppConstants.premiumGold,
            rules: [
              _EtiquetteRule(
                icon: Icons.checkroom,
                title: 'Dress Modestly',
                description: 'Cover shoulders and knees. Remove hats and sunglasses.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.hiking_sharp,
                title: 'Remove Shoes',
                description: 'Take off shoes and socks before entering temple premises.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.photo_camera,
                title: 'Never Turn Your Back to Buddha',
                description: 'Always face Buddha statues. Don\'t pose with your back to them for photos.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.campaign,
                title: 'Keep Quiet',
                description: 'Speak softly. Temples are places of worship and meditation.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.block,
                title: 'No Selfie Poses',
                description: 'Don\'t pose with Buddha statues or point at religious icons.',
                doOrDont: false,
              ),
              _EtiquetteRule(
                icon: Icons.photo,
                title: 'Ask Before Photographing',
                description: 'Some areas prohibit photography. Always check first.',
                doOrDont: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Greetings & Social
          _buildSection(
            title: 'Greetings & Social Customs',
            icon: Icons.waving_hand,
            color: AppConstants.tropicalGreen,
            rules: [
              _EtiquetteRule(
                icon: Icons.back_hand,
                title: 'Use Your Right Hand',
                description: 'Give and receive items with your right hand. Left hand is considered unclean.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.emoji_people,
                title: 'Respectful Greeting',
                description: 'Say "Ayubowan" (Sinhala) or "Vanakkam" (Tamil) with palms together.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.person,
                title: 'Personal Space',
                description: 'Sri Lankans appreciate personal space. Avoid excessive physical contact.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.favorite,
                title: 'No Public Displays of Affection',
                description: 'Avoid kissing and excessive touching in public. It\'s culturally inappropriate.',
                doOrDont: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dining Etiquette
          _buildSection(
            title: 'Dining Etiquette',
            icon: Icons.restaurant,
            color: AppConstants.deepOceanBlue,
            rules: [
              _EtiquetteRule(
                icon: Icons.clean_hands,
                title: 'Wash Hands First',
                description: 'Always wash hands before eating, especially if eating with hands.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.back_hand,
                title: 'Use Right Hand',
                description: 'If eating with hands, use only your right hand.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.check_circle,
                title: 'Try Everything',
                description: 'It\'s polite to try a little bit of everything served.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.restaurant_menu,
                title: 'Finish Your Food',
                description: 'Leaving large amounts of food is wasteful and disrespectful.',
                doOrDont: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dress Code
          _buildSection(
            title: 'Dress Code',
            icon: Icons.checkroom,
            color: Colors.purple,
            rules: [
              _EtiquetteRule(
                icon: Icons.wb_sunny,
                title: 'Beach Wear at Beach Only',
                description: 'Swimwear is fine at beaches, but cover up when leaving.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.church,
                title: 'Conservative at Religious Sites',
                description: 'Long pants/skirts and covered shoulders at temples and religious sites.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.no_adult_content,
                title: 'Avoid Revealing Clothing',
                description: 'Sri Lankan culture is conservative. Dress modestly, especially outside tourist areas.',
                doOrDont: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Photography
          _buildSection(
            title: 'Photography',
            icon: Icons.camera_alt,
            color: AppConstants.sunsetOrange,
            rules: [
              _EtiquetteRule(
                icon: Icons.check,
                title: 'Ask Permission',
                description: 'Always ask before photographing people, especially monks and locals.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.block,
                title: 'No Buddha Tattoos',
                description: 'Don\'t display Buddha tattoos. It\'s considered highly disrespectful.',
                doOrDont: false,
              ),
              _EtiquetteRule(
                icon: Icons.military_tech,
                title: 'No Military/Police Photos',
                description: 'Never photograph military installations, checkpoints, or personnel.',
                doOrDont: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tipping
          _buildSection(
            title: 'Tipping',
            icon: Icons.attach_money,
            color: AppConstants.tropicalGreen,
            rules: [
              _EtiquetteRule(
                icon: Icons.restaurant,
                title: 'Restaurants: 10%',
                description: 'Tip 10% if service charge not included. Round up for small bills.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.local_taxi,
                title: 'Drivers: Round Up',
                description: 'Round up tuk-tuk fares or add 50-100 LKR for good service.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.hiking,
                title: 'Guides: 500-1000 LKR',
                description: 'Tip tour guides 500-1000 LKR per day depending on quality.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.hotel,
                title: 'Hotels: Optional',
                description: 'Tipping hotel staff is appreciated but not mandatory. 100-200 LKR is generous.',
                doOrDont: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // General Do's and Don'ts
          _buildSection(
            title: 'General Do\'s and Don\'ts',
            icon: Icons.rule,
            color: Colors.red,
            rules: [
              _EtiquetteRule(
                icon: Icons.check_circle,
                title: 'DO be patient',
                description: 'Things move at a slower pace. Embrace "island time".',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.check_circle,
                title: 'DO smile and be friendly',
                description: 'Sri Lankans are warm and hospitable. Return the kindness.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.check_circle,
                title: 'DO remove shoes indoors',
                description: 'Take off shoes when entering homes and some shops.',
                doOrDont: true,
              ),
              _EtiquetteRule(
                icon: Icons.cancel,
                title: 'DON\'T point your feet',
                description: 'Feet are considered unclean. Don\'t point feet at people or Buddha statues.',
                doOrDont: false,
              ),
              _EtiquetteRule(
                icon: Icons.cancel,
                title: 'DON\'T touch heads',
                description: 'The head is sacred. Don\'t touch anyone\'s head, especially children.',
                doOrDont: false,
              ),
              _EtiquetteRule(
                icon: Icons.cancel,
                title: 'DON\'T litter',
                description: 'Keep Sri Lanka beautiful. Always dispose of trash properly.',
                doOrDont: false,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bottom message
          Card(
            color: AppConstants.deepOceanBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  Text(
                    '🙏',
                    style: TextStyle(fontSize: 32),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When in doubt, observe and follow the locals!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sri Lankans are very forgiving of cultural mistakes. A smile and good intentions go a long way.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_EtiquetteRule> rules,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...rules.map((rule) => _buildRuleCard(rule)).toList(),
      ],
    );
  }

  Widget _buildRuleCard(_EtiquetteRule rule) {
    final color = rule.doOrDont ? AppConstants.tropicalGreen : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                rule.icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rule.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          rule.doOrDont ? 'DO' : 'DON\'T',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rule.description,
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
}

class _EtiquetteRule {
  final IconData icon;
  final String title;
  final String description;
  final bool doOrDont; // true = DO, false = DON'T

  const _EtiquetteRule({
    required this.icon,
    required this.title,
    required this.description,
    required this.doOrDont,
  });
}
