import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/phrase.dart';
import '../utils/constants.dart';

/// Sinhala/Tamil phrasebook for tourists
class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Language _selectedLanguage = Language.sinhala;

  final List<PhraseCategory> _categories = [
    PhraseCategory.greetings,
    PhraseCategory.basics,
    PhraseCategory.directions,
    PhraseCategory.food,
    PhraseCategory.shopping,
    PhraseCategory.emergency,
    PhraseCategory.temple,
    PhraseCategory.numbers,
    PhraseCategory.time,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Phrase> _getFilteredPhrases(PhraseCategory category) {
    var phrases = PhrasebookData.getPhrasesByCategory(category);

    if (_searchQuery.isEmpty) return phrases;

    return phrases.where((phrase) {
      final query = _searchQuery.toLowerCase();
      return phrase.english.toLowerCase().contains(query) ||
          phrase.sinhalaRomanized.toLowerCase().contains(query) ||
          phrase.tamilRomanized.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrasebook'),
        backgroundColor: AppConstants.deepOceanBlue,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Language selector
              Container(
                color: AppConstants.deepOceanBlue,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Language:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<Language>(
                        segments: const [
                          ButtonSegment(
                            value: Language.sinhala,
                            label: Text('Sinhala', style: TextStyle(fontSize: 12)),
                          ),
                          ButtonSegment(
                            value: Language.tamil,
                            label: Text('Tamil', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                        selected: {_selectedLanguage},
                        onSelectionChanged: (Set<Language> selection) {
                          setState(() {
                            _selectedLanguage = selection.first;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return Colors.white.withOpacity(0.2);
                          }),
                          foregroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.selected)) {
                              return AppConstants.deepOceanBlue;
                            }
                            return Colors.white;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Container(
                color: AppConstants.deepOceanBlue,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search phrases...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: _categories.map((category) {
                  return Tab(text: PhrasebookData.categoryNames[category]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          final phrases = _getFilteredPhrases(category);

          if (phrases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No phrases found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: phrases.length,
            itemBuilder: (context, index) {
              return _buildPhraseCard(phrases[index]);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhraseCard(Phrase phrase) {
    final nativeText = _selectedLanguage == Language.sinhala
        ? phrase.sinhala
        : phrase.tamil;
    final romanizedText = _selectedLanguage == Language.sinhala
        ? phrase.sinhalaRomanized
        : phrase.tamilRomanized;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Copy to clipboard
          Clipboard.setData(ClipboardData(text: romanizedText));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Copied "$romanizedText" to clipboard'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // English
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.deepOceanBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.deepOceanBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phrase.english,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: romanizedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Native script
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.tropicalGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedLanguage == Language.sinhala ? 'SI' : 'TA',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.tropicalGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nativeText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Romanized
              Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Text(
                  romanizedText,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              // Cultural note
              if (phrase.culturalNote != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.sunsetOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppConstants.sunsetOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AppConstants.sunsetOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phrase.culturalNote!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum Language {
  sinhala,
  tamil,
}
