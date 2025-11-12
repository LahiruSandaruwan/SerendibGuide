import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'attraction_detail_screen.dart';

/// Map screen showing all attractions with offline support
class MapScreen extends StatefulWidget {
  final Attraction? initialAttraction;

  const MapScreen({
    super.key,
    this.initialAttraction,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final MapController _mapController = MapController();

  List<Attraction> _attractions = [];
  bool _isLoading = true;
  String? _selectedCategory;

  // Sri Lanka center coordinates
  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const double _defaultZoom = 8.0;

  @override
  void initState() {
    super.initState();
    _loadAttractions();
  }

  Future<void> _loadAttractions() async {
    setState(() => _isLoading = true);

    try {
      final appState = context.read<AppStateProvider>();
      final attractions = await _databaseService.getAttractions(
        appState.languageCode,
        appState.isPremium,
      );

      setState(() {
        _attractions = attractions;
        _isLoading = false;
      });

      // If initial attraction provided, zoom to it
      if (widget.initialAttraction != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(
            LatLng(
              widget.initialAttraction!.latitude,
              widget.initialAttraction!.longitude,
            ),
            13.0,
          );
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attractions: $e')),
        );
      }
    }
  }

  List<Attraction> get _filteredAttractions {
    if (_selectedCategory == null) return _attractions;
    return _attractions.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        actions: [
          // Reset view
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(_sriLankaCenter, _defaultZoom);
            },
            tooltip: 'Reset view',
          ),
          // Filter
          PopupMenuButton<String>(
            icon: Icon(
              _selectedCategory != null ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter by category',
            onSelected: (category) {
              setState(() {
                _selectedCategory = category == 'all' ? null : category;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Categories'),
              ),
              const PopupMenuDivider(),
              ...AppConstants.categories.map((category) => PopupMenuItem(
                value: category,
                child: Text(category),
              )),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.initialAttraction != null
                        ? LatLng(
                            widget.initialAttraction!.latitude,
                            widget.initialAttraction!.longitude,
                          )
                        : _sriLankaCenter,
                    initialZoom: widget.initialAttraction != null ? 13.0 : _defaultZoom,
                    minZoom: 7.0,
                    maxZoom: 18.0,
                    // Restrict to Sri Lanka bounds
                    maxBounds: LatLngBounds(
                      const LatLng(5.9, 79.4), // Southwest
                      const LatLng(9.9, 82.0), // Northeast
                    ),
                  ),
                  children: [
                    // Tile layer - offline tiles from MBTiles or online fallback
                    TileLayer(
                      urlTemplate: appState.useOfflineMaps
                          ? 'assets/tiles/{z}/{x}/{y}.png' // Offline tiles
                          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Online fallback
                      userAgentPackageName: 'com.serendibguide.app',
                      maxZoom: 18,
                      tileProvider: appState.useOfflineMaps
                          ? AssetTileProvider() // Custom tile provider for assets
                          : NetworkTileProvider(),
                      errorTileCallback: (tile, error, stackTrace) {
                        // Fallback to online if offline tiles missing
                        if (appState.useOfflineMaps) {
                          debugPrint('Offline tile not found, using online fallback');
                        }
                      },
                    ),

                    // Markers layer
                    MarkerLayer(
                      markers: _filteredAttractions.map((attraction) {
                        final isSelected = widget.initialAttraction?.id == attraction.id;

                        return Marker(
                          point: LatLng(attraction.latitude, attraction.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _showAttractionBottomSheet(attraction),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: isSelected ? 50 : 40,
                                  color: isSelected
                                      ? AppConstants.errorRed
                                      : _getCategoryColor(attraction.category),
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                if (attraction.isPremium)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.star,
                                      size: 16,
                                      color: AppConstants.premiumGold,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // Category filter chip (if active)
                if (_selectedCategory != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.filter_alt,
                              size: 20,
                              color: _getCategoryColor(_selectedCategory!),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing: $_selectedCategory',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() => _selectedCategory = null);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Attractions count badge
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Card(
                    color: AppConstants.deepOceanBlue,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        '${_filteredAttractions.length} attractions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAttractionBottomSheet(Attraction attraction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppConstants.spacing16),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              if (attraction.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                  child: Image.asset(
                    attraction.imageUrls.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      attraction.getName(context.read<AppStateProvider>().languageCode),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (attraction.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.premiumGold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                ],
              ),

              const SizedBox(height: 8),

              // Category and province
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: _getCategoryColor(attraction.category),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attraction.category,
                    style: TextStyle(
                      color: _getCategoryColor(attraction.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    attraction.province,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                attraction.getDescription(context.read<AppStateProvider>().languageCode),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // View Details button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttractionDetailScreen(
                          attraction: attraction,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.deepOceanBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ancient Sites':
        return AppConstants.ancientBrown;
      case 'Beaches':
        return AppConstants.deepOceanBlue;
      case 'Nature & Wildlife':
        return AppConstants.tropicalGreen;
      case 'Hill Country':
        return AppConstants.mountainGreen;
      case 'Cities':
        return AppConstants.errorRed;
      case 'Religious Sites':
        return AppConstants.sunsetOrange;
      case 'Food Experiences':
        return AppConstants.spiceYellow;
      case 'Culture & Museums':
        return const Color(0xFF8B4513);
      case 'Scenic Experiences':
        return AppConstants.skyBlue;
      default:
        return Colors.grey;
    }
  }
}

/// Custom tile provider for loading tiles from assets
class AssetTileProvider extends TileProvider {
  AssetTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final path = 'assets/tiles/${coordinates.z}/${coordinates.x}/${coordinates.y}.png';
    return AssetImage(path);
  }
}
