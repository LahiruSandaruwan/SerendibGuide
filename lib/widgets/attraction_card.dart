import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../utils/constants.dart';

/// Card widget displaying attraction in list/grid views
class AttractionCard extends StatelessWidget {
  final Attraction attraction;
  final VoidCallback? onTap;
  final bool showFavoriteButton;

  const AttractionCard({
    super.key,
    required this.attraction,
    this.onTap,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final isFavorite = appState.isFavorite(attraction.id ?? 0);
    final locale = appState.languageCode;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Attraction Image
                SizedBox(
                  height: AppConstants.attractionCardImageHeight,
                  width: double.infinity,
                  child: Image.asset(
                    attraction.getImagePath(0),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),

                // Premium Badge
                if (attraction.isPremium && !appState.isPremium)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.premiumGold,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.star, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Favorite Button
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey[700],
                        ),
                        onPressed: () async {
                          try {
                            await appState.toggleFavorite(attraction.id ?? 0);

                            if (!context.mounted) return;

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
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: AppConstants.errorRed,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    attraction.getName(locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: AppConstants.fontMedium,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacing8),

                  // Category and Province
                  Row(
                    children: [
                      Icon(
                        CategoryConfig.getCategoryIcon(attraction.category),
                        size: 16,
                        color: CategoryConfig.getCategoryColor(attraction.category),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          attraction.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: CategoryConfig.getCategoryColor(attraction.category),
                                fontWeight: AppConstants.fontMedium,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          attraction.fullLocation,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Entry Fee
                  if (attraction.entryFee != null) ...[
                    const SizedBox(height: AppConstants.spacing8),
                    Row(
                      children: [
                        Icon(
                          attraction.isFree ? Icons.check_circle : Icons.attach_money,
                          size: 16,
                          color: attraction.isFree
                            ? AppConstants.successGreen
                            : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attraction.entryFee!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: attraction.isFree
                                    ? AppConstants.successGreen
                                    : Colors.grey[600],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
