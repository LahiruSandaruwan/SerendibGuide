import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/daily_fact.dart';
import '../utils/constants.dart';

/// Screen displaying daily Sri Lanka facts and travel quotes
class DailyFactsScreen extends StatefulWidget {
  const DailyFactsScreen({super.key});

  @override
  State<DailyFactsScreen> createState() => _DailyFactsScreenState();
}

class _DailyFactsScreenState extends State<DailyFactsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  final List<String> _categories = SriLankaFactsLibrary.getCategories();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Did You Know?'),
        backgroundColor: AppConstants.sunsetOrange,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Facts'),
            Tab(text: 'Quotes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildAllFactsTab(),
          _buildQuotesTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    final fact = SriLankaFactsLibrary.getFactOfTheDay();
    final quote = SriLankaFactsLibrary.getQuoteOfTheDay();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Fact of the Day
        Card(
          elevation: 4,
          color: AppConstants.tropicalGreen.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      fact.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Fact of the Day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.tropicalGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fact.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.tropicalGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fact.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fact.content,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(
                          '${fact.title}\n\n${fact.content}'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.tropicalGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Quote of the Day
        Card(
          elevation: 4,
          color: AppConstants.sunsetOrange.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      quote['emoji']!,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Quote of the Day',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.sunsetOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"${quote['quote']!}"',
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${quote['author']!}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.sunsetOrange,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(
                          '"${quote['quote']!}" — ${quote['author']!}'),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.sunsetOrange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'New fact and quote every day! Check back tomorrow for more.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllFactsTab() {
    return Column(
      children: [
        // Category filter
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', _selectedCategory == null),
                      ..._categories.map((cat) =>
                          _buildCategoryChip(cat, _selectedCategory == cat)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Facts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _getFilteredFacts().length,
            itemBuilder: (context, index) {
              final fact = _getFilteredFacts()[index];
              return _buildFactCard(fact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuotesTab() {
    final quotes = SriLankaFactsLibrary.quotes;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return _buildQuoteCard(quote);
      },
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected && label != 'All' ? label : null;
          });
        },
        selectedColor: AppConstants.tropicalGreen.withOpacity(0.3),
        checkmarkColor: AppConstants.tropicalGreen,
      ),
    );
  }

  List<DailyFact> _getFilteredFacts() {
    if (_selectedCategory == null) {
      return SriLankaFactsLibrary.facts
          .map((f) => DailyFact(
                title: f['title']!,
                content: f['content']!,
                emoji: f['emoji']!,
                category: f['category']!,
                date: DateTime.now(),
              ))
          .toList();
    } else {
      return SriLankaFactsLibrary.getFactsByCategory(_selectedCategory!);
    }
  }

  Widget _buildFactCard(DailyFact fact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  fact.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fact.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.deepOceanBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                fact.category,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.deepOceanBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              fact.content,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, String> quote) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote['emoji']!,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '"${quote['quote']!}"',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${quote['author']!}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.deepOceanBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
