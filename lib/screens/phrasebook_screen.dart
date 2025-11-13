import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/translation.dart';
import '../services/translation_service.dart';
import '../utils/constants.dart';

/// Phrasebook screen with common travel phrases and live translator
class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> {
  final TranslationService _service = TranslationService();
  final TextEditingController _textController = TextEditingController();

  String _fromLang = 'en';
  String _toLang = 'si';
  Translation? _translation;
  bool _isTranslating = false;
  String? _error;

  int _selectedTab = 0; // 0 = Phrases, 1 = Translator

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isTranslating = true;
      _error = null;
    });

    try {
      final translation = await _service.translate(
        text: text,
        from: _fromLang,
        to: _toLang,
      );

      if (mounted) {
        setState(() {
          _translation = translation;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Translation failed. Please try again.';
          _isTranslating = false;
        });
      }
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = _fromLang;
      _fromLang = _toLang;
      _toLang = temp;

      // Swap text if there's a translation
      if (_translation != null) {
        _textController.text = _translation!.translatedText;
        _translation = null;
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrasebook & Translator'),
        backgroundColor: AppConstants.sunsetOrange,
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'Common Phrases'),
            Tab(text: 'Translator'),
          ],
        ),
      ),
      body: _selectedTab == 0 ? _buildPhrasebookTab() : _buildTranslatorTab(),
    );
  }

  Widget _buildPhrasebookTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: TravelPhrases.categories.length,
      itemBuilder: (context, index) {
        final category = TravelPhrases.categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(String category) {
    final phrases = TravelPhrases.getPhrasesForCategory(category);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Text(
          _getCategoryIcon(category),
          style: const TextStyle(fontSize: 28),
        ),
        children: phrases.entries.map((entry) {
          return _buildPhraseRow(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Greetings':
        return '👋';
      case 'Directions':
        return '🗺️';
      case 'Numbers':
        return '🔢';
      case 'Food & Dining':
        return '🍽️';
      case 'Emergency':
        return '🚨';
      case 'Shopping':
        return '🛒';
      case 'Transport':
        return '🚌';
      default:
        return '📖';
    }
  }

  Widget _buildPhraseRow(String english, String sinhala) {
    return InkWell(
      onTap: () => _copyToClipboard(sinhala),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                english,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sinhala,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.deepOceanBlue,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () => _copyToClipboard(sinhala),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info card
          Card(
            color: AppConstants.deepOceanBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppConstants.deepOceanBlue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Powered by LibreTranslate - Free & Open Source',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Language selectors
          Row(
            children: [
              Expanded(
                child: _buildLanguageSelector(
                  label: 'From',
                  value: _fromLang,
                  onChanged: (value) => setState(() => _fromLang = value!),
                ),
              ),
              IconButton(
                onPressed: _swapLanguages,
                icon: const Icon(Icons.swap_horiz),
                iconSize: 32,
              ),
              Expanded(
                child: _buildLanguageSelector(
                  label: 'To',
                  value: _toLang,
                  onChanged: (value) => setState(() => _toLang = value!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Input text
          TextField(
            controller: _textController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Enter text to translate',
              hintText: 'Type your text here...',
              border: const OutlineInputBorder(),
              suffixIcon: _textController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _textController.clear();
                          _translation = null;
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),

          // Translate button
          ElevatedButton.icon(
            onPressed: _isTranslating || _textController.text.isEmpty
                ? null
                : _translate,
            icon: _isTranslating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.translate),
            label: Text(_isTranslating ? 'Translating...' : 'Translate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.sunsetOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppConstants.errorRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppConstants.errorRed),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Translation result
          if (_translation != null) ...[
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppConstants.successGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Translation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(_translation!.translatedText),
                          tooltip: 'Copy',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _translation!.translatedText,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppConstants.deepOceanBlue,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLanguageSelector({
    required String label,
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: SupportedLanguages.languages.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Row(
                  children: [
                    Text(SupportedLanguages.getFlag(entry.key)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
