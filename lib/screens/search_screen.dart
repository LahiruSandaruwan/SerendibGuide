import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/attraction_card.dart';
import 'attraction_detail_screen.dart';

/// Search delegate for attractions
class AttractionSearchDelegate extends SearchDelegate<Attraction?> {
  final DatabaseService _databaseService = DatabaseService();

  @override
  String get searchFieldLabel => 'Search attractions...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildRecentSearches(context);
    }

    return _buildSearchResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < AppConstants.minSearchLength) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing32),
          child: Text(
            'Type at least ${AppConstants.minSearchLength} characters to search',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return _buildSearchResults(context);
  }

  Widget _buildRecentSearches(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getRecentSearches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Start typing to search attractions',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search by name, category, or tags',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final recentQuery = snapshot.data![index];
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(recentQuery),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _removeRecentSearch(recentQuery),
              ),
              onTap: () {
                query = recentQuery;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final appState = context.read<AppStateProvider>();

    return FutureBuilder<List<Attraction>>(
      future: _databaseService.searchAttractions(
        query,
        appState.languageCode,
        appState.isPremium,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppConstants.errorRed),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "$query"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or browse by category',
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Save successful search
        _saveRecentSearch(query);

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacing16),
              color: AppConstants.deepOceanBlue.withOpacity(0.1),
              child: Row(
                children: [
                  Text(
                    '${results.length} ${results.length == 1 ? 'result' : 'results'} found',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final attraction = results[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
                    child: AttractionCard(
                      attraction: attraction,
                      onTap: () {
                        close(context, attraction);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AttractionDetailScreen(attraction: attraction),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(AppConstants.keyRecentSearches) ?? [];

    // Remove if already exists
    recent.remove(query);

    // Add to beginning
    recent.insert(0, query);

    // Keep only last 10
    if (recent.length > AppConstants.maxRecentSearches) {
      recent.removeLast();
    }

    await prefs.setStringList(AppConstants.keyRecentSearches, recent);
  }

  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(AppConstants.keyRecentSearches) ?? [];
    recent.remove(query);
    await prefs.setStringList(AppConstants.keyRecentSearches, recent);
  }
}
