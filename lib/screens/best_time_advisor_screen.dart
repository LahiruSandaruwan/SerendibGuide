import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Best time to visit advisor with weather, crowds, and cost analysis
class BestTimeAdvisorScreen extends StatelessWidget {
  const BestTimeAdvisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Best Time to Visit'),
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
                  Icon(Icons.calendar_month, size: 40, color: AppConstants.sunsetOrange),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'When to Visit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Weather, crowds, and costs by month',
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

          // Quick summary
          _buildSeasonSummary(),

          const SizedBox(height: 24),

          const Text(
            'Month-by-Month Guide',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Month cards
          ..._months.asMap().entries.map((entry) {
            final index = entry.key;
            final month = entry.value;
            return _buildMonthCard(month, index + 1);
          }).toList(),

          const SizedBox(height: 16),

          // General tips
          Card(
            color: AppConstants.deepOceanBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tips_and_updates, color: AppConstants.deepOceanBlue),
                      SizedBox(width: 8),
                      Text(
                        'Travel Tips',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Book 2-3 months in advance for peak season (Dec-Mar)'),
                  _buildTip('Shoulder seasons (Apr-May, Sep-Nov) offer best value'),
                  _buildTip('Hill country is cooler year-round'),
                  _buildTip('Both coasts have good weather at different times'),
                  _buildTip('Cultural festivals can affect availability and prices'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonSummary() {
    return Column(
      children: [
        _buildSeasonCard(
          '🌟 Peak Season (Dec - Mar)',
          'Best weather, warm and dry across most of the island',
          'High',
          'High',
          AppConstants.premiumGold,
          'Ideal for beaches, wildlife, and cultural sites. Book early!',
        ),
        const SizedBox(height: 8),
        _buildSeasonCard(
          '🌤️ Shoulder Season (Apr-May, Sep-Nov)',
          'Good weather with occasional showers, fewer tourists',
          'Medium',
          'Medium',
          AppConstants.tropicalGreen,
          'Best value! Great weather with better prices and fewer crowds.',
        ),
        const SizedBox(height: 8),
        _buildSeasonCard(
          '🌧️ Monsoon Season (Jun-Aug)',
          'Wet season, especially on west and south coasts',
          'Low',
          'Low',
          AppConstants.deepOceanBlue,
          'Cheapest rates. East coast (Trinco, Arugam Bay) still good!',
        ),
      ],
    );
  }

  Widget _buildSeasonCard(
    String title,
    String description,
    String crowds,
    String cost,
    Color color,
    String tip,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric('Crowds', crowds, _getCrowdColor(crowds)),
                const SizedBox(width: 16),
                _buildMetric('Cost', cost, _getCostColor(cost)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tip,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCard(MonthData month, int monthNumber) {
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
                    color: month.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    month.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        month.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        month.subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetric('Weather', month.weather, _getWeatherColor(month.weather))),
                Expanded(child: _buildMetric('Crowds', month.crowds, _getCrowdColor(month.crowds))),
                Expanded(child: _buildMetric('Cost', month.cost, _getCostColor(month.cost))),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              month.description,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            if (month.highlights.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: month.highlights.map((highlight) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: month.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      highlight,
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Color _getWeatherColor(String weather) {
    switch (weather) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Fair':
        return Colors.orange;
      case 'Rainy':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getCrowdColor(String crowds) {
    switch (crowds) {
      case 'Very High':
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getCostColor(String cost) {
    switch (cost) {
      case 'Very High':
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
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

  static final List<MonthData> _months = [
    const MonthData(
      name: 'January',
      subtitle: 'Peak Season',
      emoji: '☀️',
      weather: 'Excellent',
      crowds: 'Very High',
      cost: 'Very High',
      description: 'Perfect weather across the island. Warm, dry, and sunny. Ideal for beaches, wildlife, and cultural sites.',
      highlights: ['Beach weather', 'Wildlife safaris', 'Duruthu Perahera'],
      color: AppConstants.premiumGold,
    ),
    const MonthData(
      name: 'February',
      subtitle: 'Peak Season',
      emoji: '🌤️',
      weather: 'Excellent',
      crowds: 'Very High',
      cost: 'Very High',
      description: 'Continuation of peak season. Dry and sunny weather continues. Best time for whale watching in Mirissa.',
      highlights: ['Whale watching', 'Beach perfect', 'Independence Day (Feb 4)'],
      color: AppConstants.premiumGold,
    ),
    const MonthData(
      name: 'March',
      subtitle: 'Peak Season',
      emoji: '☀️',
      weather: 'Good',
      crowds: 'High',
      cost: 'High',
      description: 'Still great weather but getting warmer. Occasional showers start appearing. Last month of peak season.',
      highlights: ['Still dry', 'Hot temperatures', 'Good wildlife viewing'],
      color: AppConstants.tropicalGreen,
    ),
    const MonthData(
      name: 'April',
      subtitle: 'Shoulder Season',
      emoji: '🌦️',
      weather: 'Fair',
      crowds: 'Medium',
      cost: 'Medium',
      description: 'Inter-monsoon period with scattered showers. New Year celebrations mid-month. Can be very hot and humid.',
      highlights: ['Sinhala/Tamil New Year', 'Fewer tourists', 'Lower prices'],
      color: AppConstants.sunsetOrange,
    ),
    const MonthData(
      name: 'May',
      subtitle: 'Shoulder Season',
      emoji: '🌧️',
      weather: 'Fair',
      crowds: 'Low',
      cost: 'Low',
      description: 'Start of southwest monsoon. Rain increases, especially in west and south. Vesak festival with beautiful lanterns.',
      highlights: ['Vesak festival', 'Low crowds', 'Cheaper rates'],
      color: AppConstants.deepOceanBlue,
    ),
    const MonthData(
      name: 'June',
      subtitle: 'Monsoon Season',
      emoji: '🌧️',
      weather: 'Rainy',
      crowds: 'Low',
      cost: 'Low',
      description: 'Monsoon in full swing on west/south coasts. East coast (Trinco, Arugam Bay) has great weather! Poson Poya festival.',
      highlights: ['East coast perfect', 'Poson Poya', 'Best deals'],
      color: AppConstants.deepOceanBlue,
    ),
    const MonthData(
      name: 'July',
      subtitle: 'Monsoon Season',
      emoji: '🎉',
      weather: 'Rainy',
      crowds: 'Medium',
      cost: 'Medium',
      description: 'Continues wet on west coast. Kandy Esala Perahera festival - one of Asia\'s greatest shows! East coast still good.',
      highlights: ['Esala Perahera', 'East coast dry', 'Cultural festivals'],
      color: AppConstants.premiumGold,
    ),
    const MonthData(
      name: 'August',
      subtitle: 'Monsoon Season',
      emoji: '🌧️',
      weather: 'Rainy',
      crowds: 'Low',
      cost: 'Low',
      description: 'Monsoon continues but starting to ease. Great time for east coast. Hill country pleasant and green.',
      highlights: ['East coast', 'Hill country', 'Green landscapes'],
      color: AppConstants.tropicalGreen,
    ),
    const MonthData(
      name: 'September',
      subtitle: 'Shoulder Season',
      emoji: '🌦️',
      weather: 'Fair',
      crowds: 'Low',
      cost: 'Low',
      description: 'Inter-monsoon period. Weather improving in south and west. Good value month with fewer crowds.',
      highlights: ['Improving weather', 'Great value', 'Low crowds'],
      color: AppConstants.sunsetOrange,
    ),
    const MonthData(
      name: 'October',
      subtitle: 'Shoulder Season',
      emoji: '🌦️',
      weather: 'Fair',
      crowds: 'Medium',
      cost: 'Medium',
      description: 'Transitional month with mixed weather. Can have short intense showers. Deepavali celebrations. Good deals still available.',
      highlights: ['Deepavali', 'Mixed weather', 'Moderate prices'],
      color: AppConstants.sunsetOrange,
    ),
    const MonthData(
      name: 'November',
      subtitle: 'Shoulder Season',
      emoji: '🌤️',
      weather: 'Good',
      crowds: 'Medium',
      cost: 'Medium',
      description: 'Weather improving significantly. Northeast monsoon begins but mainly affects north/east. Great value before peak season.',
      highlights: ['Weather improving', 'Good value', 'Fewer tourists'],
      color: AppConstants.tropicalGreen,
    ),
    const MonthData(
      name: 'December',
      subtitle: 'Peak Season Starting',
      emoji: '☀️',
      weather: 'Excellent',
      crowds: 'High',
      cost: 'High',
      description: 'Peak season begins! Dry weather returns. Christmas and New Year bring high tourist numbers. Book well in advance.',
      highlights: ['Perfect weather', 'Christmas/New Year', 'Book early'],
      color: AppConstants.premiumGold,
    ),
  ];
}

class MonthData {
  final String name;
  final String subtitle;
  final String emoji;
  final String weather;
  final String crowds;
  final String cost;
  final String description;
  final List<String> highlights;
  final Color color;

  const MonthData({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.weather,
    required this.crowds,
    required this.cost,
    required this.description,
    required this.highlights,
    required this.color,
  });
}
