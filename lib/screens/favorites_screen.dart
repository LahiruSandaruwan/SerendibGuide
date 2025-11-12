import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/attraction_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import 'attraction_detail_screen.dart';

/// Favorites screen showing saved attractions
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Attraction> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = context.read<AppStateProvider>();
      final favoriteIds = appState.favoriteIds.toList();

      if (favoriteIds.isEmpty) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        return;
      }

      final attractions = await _databaseService.getAttractionsByIds(favoriteIds);

      if (mounted) {
        setState(() {
          _favorites = attractions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Favorites'),
            Consumer<AppStateProvider>(
              builder: (context, appState, _) {
                return Text(
                  '${appState.favoriteIds.length} saved',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          if (_favorites.isNotEmpty)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, size: 20),
                      SizedBox(width: 8),
                      Text('Remove All'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearConfirmation();
                }
              },
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading favorites...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _loadFavorites,
      );
    }

    if (_favorites.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        subtitle: 'Tap ❤️ on attractions to save them here',
        actionLabel: 'Browse Attractions',
        onAction: () {
          Navigator.pop(context);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppConstants.spacing12,
          mainAxisSpacing: AppConstants.spacing12,
        ),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final attraction = _favorites[index];
          return AttractionCard(
            attraction: attraction,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                    AttractionDetailScreen(attraction: attraction),
                ),
              );
              // Reload favorites in case they changed
              _loadFavorites();
            },
          );
        },
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove All Favorites'),
          content: const Text(
            'Are you sure you want to remove all favorites? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final appState = context.read<AppStateProvider>();
                await appState.clearFavorites();
                _loadFavorites();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All favorites removed')),
                );
              },
              child: const Text(
                'Remove All',
                style: TextStyle(color: AppConstants.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }
}
