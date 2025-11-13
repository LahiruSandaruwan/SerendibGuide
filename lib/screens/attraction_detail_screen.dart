import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/image_gallery_widget.dart';
import '../widgets/attraction_card.dart';
import '../widgets/loading_widget.dart';
import 'nearby_places_screen.dart';

/// Attraction detail screen with full information
class AttractionDetailScreen extends StatefulWidget {
  final Attraction attraction;

  const AttractionDetailScreen({
    super.key,
    required this.attraction,
  });

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Attraction> _nearbyAttractions = [];
  bool _isLoadingNearby = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyAttractions();
  }

  Future<void> _loadNearbyAttractions() async {
    try {
      final nearby = await _databaseService.getNearbyAttractions(
        widget.attraction.id!,
        AppConstants.nearbyRadiusKm,
      );

      if (mounted) {
        setState(() {
          _nearbyAttractions = nearby;
          _isLoadingNearby = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingNearby = false;
        });
      }
    }
  }

  Future<void> _openDirections() async {
    final url = Helpers.getDirectionsUrl(
      widget.attraction.latitude,
      widget.attraction.longitude,
    );

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps')),
      );
    }
  }

  void _shareAttraction() {
    final shareText = Helpers.getAttractionShareText(
      widget.attraction.nameEn,
      widget.attraction.latitude,
      widget.attraction.longitude,
    );
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final locale = appState.languageCode;
    final isFavorite = appState.isFavorite(widget.attraction.id ?? 0);
    final isPremiumLocked = widget.attraction.isPremium && !appState.isPremium;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.attraction.getName(locale),
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: ImageGalleryWidget(
                images: widget.attraction.imagePaths,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () async {
                  try {
                    await appState.toggleFavorite(widget.attraction.id ?? 0);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppConstants.errorRed,
                      ),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareAttraction,
              ),
            ],
          ),

          // Content
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Province
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: CategoryConfig.getCategoryIcon(
                            widget.attraction.category,
                          ),
                          label: widget.attraction.category,
                          color: CategoryConfig.getCategoryColor(
                            widget.attraction.category,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.location_on,
                          label: widget.attraction.province,
                          color: Colors.grey[700]!,
                        ),
                        if (widget.attraction.difficulty != null) ...[
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            icon: DifficultyConfig.getDifficultyIcon(
                              widget.attraction.difficulty!,
                            ),
                            label: widget.attraction.difficulty!,
                            color: DifficultyConfig.getDifficultyColor(
                              widget.attraction.difficulty!,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacing24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _shareAttraction,
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openDirections,
                            icon: const Icon(Icons.directions),
                            label: const Text('Directions'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.deepOceanBlue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Nearby Places Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NearbyPlacesScreen(
                                latitude: widget.attraction.latitude,
                                longitude: widget.attraction.longitude,
                                locationName: widget.attraction.getName(locale),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Find Nearby Hotels & Restaurants'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.sunsetOrange,
                          side: BorderSide(color: AppConstants.sunsetOrange),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacing24),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacing16),

                    // Overview Section
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: AppConstants.fontBold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    // Premium Lock Overlay
                    if (isPremiumLocked) ...[
                      _buildPremiumLockedDescription(),
                    ] else ...[
                      Text(
                        widget.attraction.getDescription(locale),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacing24),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacing16),

                    // Details Section
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: AppConstants.fontBold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    if (widget.attraction.entryFee != null)
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Entry Fee',
                        value: widget.attraction.entryFee!,
                      ),

                    if (widget.attraction.openingHours != null)
                      _buildDetailRow(
                        icon: Icons.schedule,
                        label: 'Opening Hours',
                        value: widget.attraction.openingHours!,
                      ),

                    if (widget.attraction.bestTime != null)
                      _buildDetailRow(
                        icon: Icons.wb_sunny,
                        label: 'Best Time to Visit',
                        value: widget.attraction.bestTime!,
                      ),

                    if (widget.attraction.duration != null)
                      _buildDetailRow(
                        icon: Icons.access_time,
                        label: 'Duration Needed',
                        value: widget.attraction.duration!,
                      ),

                    const SizedBox(height: AppConstants.spacing24),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacing16),

                    // What to Bring
                    Text(
                      'What to Bring',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: AppConstants.fontBold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    ...Helpers.getWhatToBring(widget.attraction.category).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 20,
                              color: AppConstants.successGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tags
                    if (widget.attraction.tags.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacing24),
                      const Divider(),
                      const SizedBox(height: AppConstants.spacing16),
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: AppConstants.fontBold,
                            ),
                      ),
                      const SizedBox(height: AppConstants.spacing12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.attraction.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Colors.grey[200],
                          );
                        }).toList(),
                      ),
                    ],

                    // Nearby Attractions
                    const SizedBox(height: AppConstants.spacing24),
                    const Divider(),
                    const SizedBox(height: AppConstants.spacing16),

                    Text(
                      'Nearby Attractions',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: AppConstants.fontBold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacing12),

                    if (_isLoadingNearby)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacing24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_nearbyAttractions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        child: Text(
                          'No nearby attractions found',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _nearbyAttractions.length,
                          itemBuilder: (context, index) {
                            final nearby = _nearbyAttractions[index];
                            return SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: AttractionCard(
                                  attraction: nearby,
                                  showFavoriteButton: false,
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                          AttractionDetailScreen(attraction: nearby),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: AppConstants.spacing24),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: AppConstants.fontMedium,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppConstants.deepOceanBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: AppConstants.fontMedium,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLockedDescription() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
        border: Border.all(color: AppConstants.premiumGold, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 48,
            color: AppConstants.premiumGold,
          ),
          const SizedBox(height: 16),
          Text(
            'Premium Content',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: AppConstants.fontBold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upgrade to Premium to unlock the full description and all premium attractions!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to premium screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium upgrade coming soon!')),
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Upgrade Now - \$14.99'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.premiumGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacing24,
                vertical: AppConstants.spacing12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
