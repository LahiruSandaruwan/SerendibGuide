import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Smart packing list generator for Sri Lanka trips
class PackingListScreen extends StatefulWidget {
  const PackingListScreen({super.key});

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  String _season = 'dry'; // dry, wet
  int _duration = 7; // days
  final Set<String> _activities = {};
  final Map<String, bool> _checkedItems = {};

  List<PackingCategory> _getPackingList() {
    final List<PackingCategory> categories = [];

    // Essentials (always included)
    categories.add(PackingCategory(
      name: 'Travel Documents',
      icon: Icons.card_travel,
      color: Colors.red,
      items: [
        'Passport (valid 6+ months)',
        'Visa/ETA printout',
        'Travel insurance documents',
        'Flight tickets',
        'Hotel bookings',
        'Emergency contacts list',
        'Photocopies of documents',
        'Credit/debit cards',
        'Cash (LKR & USD)',
      ],
    ));

    // Clothing based on season
    final clothingItems = <String>[
      'Lightweight, breathable clothing',
      'Comfortable walking shoes',
      'Sandals/flip-flops',
      'Modest clothing for temples',
      'Light jacket or sweater',
      'Sleepwear',
      'Underwear and socks',
    ];

    if (_season == 'wet') {
      clothingItems.addAll([
        'Rain jacket or umbrella',
        'Waterproof bag',
        'Quick-dry clothes',
      ]);
    }

    if (_activities.contains('beach')) {
      clothingItems.addAll([
        'Swimwear',
        'Beach cover-up',
        'Sunhat',
      ]);
    }

    if (_activities.contains('hiking')) {
      clothingItems.addAll([
        'Hiking boots',
        'Long pants (leech protection)',
        'Moisture-wicking clothes',
      ]);
    }

    categories.add(PackingCategory(
      name: 'Clothing',
      icon: Icons.checkroom,
      color: Colors.blue,
      items: clothingItems,
    ));

    // Toiletries
    final toiletryDays = _duration > 14 ? 'Travel-size + refills' : 'Travel-size';
    categories.add(PackingCategory(
      name: 'Toiletries & Personal Care',
      icon: Icons.wash,
      color: Colors.purple,
      items: [
        'Toothbrush & toothpaste',
        'Shampoo & soap ($toiletryDays)',
        'Deodorant',
        'Sunscreen (SPF 50+)',
        'Insect repellent',
        'Personal medications',
        'First aid kit',
        'Hand sanitizer',
        'Wet wipes',
        'Feminine hygiene products',
        if (_duration > 7) 'Laundry detergent',
      ],
    ));

    // Electronics
    categories.add(PackingCategory(
      name: 'Electronics',
      icon: Icons.devices,
      color: Colors.green,
      items: [
        'Phone & charger',
        'Power bank',
        'Camera (optional)',
        'Universal adapter (UK plugs)',
        'Headphones',
        'E-reader/tablet (optional)',
        if (_activities.contains('adventure')) 'GoPro/action camera',
      ],
    ));

    // Health & Safety
    final healthItems = <String>[
      'Prescription medications',
      'Pain relievers',
      'Anti-diarrhea medicine',
      'Antihistamines',
      'Band-aids & antiseptic',
      'Oral rehydration salts',
      'Motion sickness pills',
      'Mosquito repellent',
    ];

    if (_activities.contains('hiking')) {
      healthItems.add('Blister treatment');
      healthItems.add('Salt (for leeches)');
    }

    categories.add(PackingCategory(
      name: 'Health & Safety',
      icon: Icons.health_and_safety,
      color: Colors.red[300]!,
      items: healthItems,
    ));

    // Activity-specific items
    if (_activities.isNotEmpty) {
      final activityItems = <String>[];

      if (_activities.contains('beach')) {
        activityItems.addAll([
          'Snorkel gear (optional)',
          'Waterproof phone case',
          'Beach towel',
        ]);
      }

      if (_activities.contains('hiking')) {
        activityItems.addAll([
          'Daypack/backpack',
          'Water bottle',
          'Trail snacks',
          'Headlamp/flashlight',
        ]);
      }

      if (_activities.contains('wildlife')) {
        activityItems.addAll([
          'Binoculars',
          'Zoom lens camera',
          'Field guide',
        ]);
      }

      if (activityItems.isNotEmpty) {
        categories.add(PackingCategory(
          name: 'Activity Gear',
          icon: Icons.hiking,
          color: Colors.orange,
          items: activityItems,
        ));
      }
    }

    // Optional but useful
    categories.add(PackingCategory(
      name: 'Optional But Useful',
      icon: Icons.more_horiz,
      color: Colors.grey,
      items: [
        'Reusable water bottle',
        'Snacks from home',
        'Ziplock bags',
        'Clothesline & clips',
        'Earplugs & eye mask',
        'Travel pillow',
        'Guidebook/phrasebook',
        'Pen & notepad',
        'Dry bag',
      ],
    ));

    return categories;
  }

  @override
  Widget build(BuildContext context) {
    final packingList = _getPackingList();
    final totalItems = packingList.fold(0, (sum, cat) => sum + cat.items.length);
    final checkedCount = _checkedItems.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packing List Generator'),
        backgroundColor: AppConstants.tropicalGreen,
        actions: [
          if (checkedCount > 0)
            TextButton(
              onPressed: () {
                setState(() => _checkedItems.clear());
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Configuration panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.tropicalGreen.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trip Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Season
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Dry Season (Dec-Mar)'),
                        value: 'dry',
                        groupValue: _season,
                        onChanged: (value) {
                          setState(() => _season = value!);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Wet Season (Apr-Nov)'),
                        value: 'wet',
                        groupValue: _season,
                        onChanged: (value) {
                          setState(() => _season = value!);
                        },
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),

                // Duration
                Row(
                  children: [
                    const Text('Trip Duration:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _duration,
                      items: [3, 5, 7, 10, 14, 21, 30].map((days) {
                        return DropdownMenuItem(
                          value: days,
                          child: Text('$days days'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _duration = value!);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Activities
                const Text('Activities:', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildActivityChip('Beach', 'beach', Icons.beach_access),
                    _buildActivityChip('Hiking', 'hiking', Icons.hiking),
                    _buildActivityChip('Wildlife', 'wildlife', Icons.pets),
                    _buildActivityChip('Adventure', 'adventure', Icons.kayaking),
                  ],
                ),
              ],
            ),
          ),

          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Packing Progress: $checkedCount / $totalItems',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: totalItems > 0 ? checkedCount / totalItems : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppConstants.tropicalGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${(totalItems > 0 ? (checkedCount / totalItems * 100) : 0).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.tropicalGreen,
                  ),
                ),
              ],
            ),
          ),

          // Packing list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: packingList.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(packingList[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String label, String value, IconData icon) {
    final isSelected = _activities.contains(value);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _activities.add(value);
          } else {
            _activities.remove(value);
          }
        });
      },
      selectedColor: AppConstants.tropicalGreen.withOpacity(0.3),
      checkmarkColor: AppConstants.tropicalGreen,
    );
  }

  Widget _buildCategoryCard(PackingCategory category) {
    final categoryChecked =
        category.items.every((item) => _checkedItems[item] == true);
    final categoryProgress = category.items
            .where((item) => _checkedItems[item] == true)
            .length /
        category.items.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: category.color),
            ),
            title: Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: LinearProgressIndicator(
              value: categoryProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(category.color),
            ),
            trailing: Checkbox(
              value: categoryChecked,
              onChanged: (value) {
                setState(() {
                  for (var item in category.items) {
                    _checkedItems[item] = value ?? false;
                  }
                });
              },
            ),
          ),
          ...category.items.map((item) {
            final isChecked = _checkedItems[item] ?? false;
            return CheckboxListTile(
              dense: true,
              title: Text(
                item,
                style: TextStyle(
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: isChecked ? Colors.grey : Colors.black,
                ),
              ),
              value: isChecked,
              onChanged: (value) {
                setState(() {
                  _checkedItems[item] = value ?? false;
                });
              },
              activeColor: category.color,
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class PackingCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> items;

  PackingCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.items,
  });
}
