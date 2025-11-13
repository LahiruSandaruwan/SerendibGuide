import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/wikipedia_info.dart';
import '../services/wikipedia_service.dart';
import '../utils/constants.dart';

/// Widget displaying Wikipedia information about an attraction
class WikipediaWidget extends StatefulWidget {
  final String searchTerm;
  final String? fallbackSearchTerm;

  const WikipediaWidget({
    super.key,
    required this.searchTerm,
    this.fallbackSearchTerm,
  });

  @override
  State<WikipediaWidget> createState() => _WikipediaWidgetState();
}

class _WikipediaWidgetState extends State<WikipediaWidget> {
  final WikipediaService _service = WikipediaService();
  WikipediaInfo? _info;
  bool _isLoading = true;
  bool _isExpanded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWikipediaInfo();
  }

  Future<void> _loadWikipediaInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Try main search term first
      WikipediaInfo? info = await _service.getArticleSummaryWithFallback(widget.searchTerm);

      // If not found and fallback provided, try fallback
      if (info == null && widget.fallbackSearchTerm != null) {
        info = await _service.getArticleSummaryWithFallback(widget.fallbackSearchTerm!);
      }

      if (mounted) {
        setState(() {
          _info = info;
          _isLoading = false;
          _error = info == null ? 'No Wikipedia article found' : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not load Wikipedia info';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openWikipediaArticle() async {
    if (_info == null) return;

    final uri = Uri.parse(_info!.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Wikipedia')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null || _info == null) {
      return const SizedBox.shrink(); // Hide if no Wikipedia info available
    }

    return _buildWikipediaCard();
  }

  Widget _buildLoadingState() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(
              'Loading Wikipedia info...',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWikipediaCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Wikipedia logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'From Wikipedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified,
                              size: 14,
                              color: AppConstants.deepOceanBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _info!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_info!.description != null &&
                            _info!.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            _info!.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),

          // Thumbnail (if available and expanded)
          if (_isExpanded && _info!.hasThumbnail) ...[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: Image.network(
                _info!.thumbnail!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Content (expanded)
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_info!.hasThumbnail) const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    _info!.extract,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Read more button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openWikipediaArticle,
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Read full article on Wikipedia'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.deepOceanBlue,
                        side: BorderSide(color: AppConstants.deepOceanBlue),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // License info
                  Center(
                    child: Text(
                      'Content from Wikipedia - CC BY-SA 3.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
