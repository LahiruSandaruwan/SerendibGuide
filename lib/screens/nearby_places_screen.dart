import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/place.dart';
import '../services/nearby_places_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Screen for displaying nearby hotels, restaurants, and other places
class NearbyPlacesScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? locationName;

  const NearbyPlacesScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.locationName,
  });

  @override
  State<NearbyPlacesScreen> createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  final NearbyPlacesService _service = NearbyPlacesService();
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  bool _isLoading = true;
  String? _error;
  Set<PlaceType> _selectedTypes = {
    PlaceType.restaurant,
    PlaceType.cafe,
    PlaceType.hotel,
  };
  int _radiusKm = 5;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final places = await _service.getNearbyPlaces(
        latitude: widget.latitude,
        longitude: widget.longitude,
        radiusMeters: _radiusKm * 1000,
        types: _selectedTypes.toList(),
      );

      if (mounted) {
        setState(() {
          _places = places;
          _filteredPlaces = places;
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

  void _filterPlaces() {
    setState(() {
      if (_selectedTypes.isEmpty) {
        _filteredPlaces = _places;
      } else {
        _filteredPlaces = _places
            .where((place) => _selectedTypes.contains(place.type))
            .toList();
      }
    });
  }

  Future<void> _openDirections(Place place) async {
    final url = Helpers.getDirectionsUrl(place.latitude, place.longitude);
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

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make call')),
      );
    }
  }

  Future<void> _openWebsite(String website) async {
    String url = website;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nearby Places'),
            if (widget.locationName != null)
              Text(
                'Near ${widget.locationName}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        backgroundColor: AppConstants.sunsetOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _filteredPlaces.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        _buildSummaryCard(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredPlaces.length,
                            itemBuilder: (context, index) {
                              return _buildPlaceCard(_filteredPlaces[index]);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildSummaryCard() {
    final restaurantCount =
        _filteredPlaces.where((p) => p.type == PlaceType.restaurant).length;
    final cafeCount =
        _filteredPlaces.where((p) => p.type == PlaceType.cafe).length;
    final hotelCount =
        _filteredPlaces.where((p) => p.type == PlaceType.hotel).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.deepOceanBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.deepOceanBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('🍽️', restaurantCount, 'Restaurants'),
              _buildStatItem('☕', cafeCount, 'Cafes'),
              _buildStatItem('🏨', hotelCount, 'Hotels'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Within ${_radiusKm}km radius',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Data from OpenStreetMap',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, int count, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConstants.deepOceanBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(Place place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPlaceDetails(place),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    place.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              place.displayDistance,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (place.stars != null) ...[
                              const SizedBox(width: 12),
                              Text(
                                place.starRating,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(place.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getTypeColor(place.type).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      place.type.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(place.type),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              if (place.cuisine != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      place.cuisine!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],

              if (place.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.place, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.address!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (place.openingHours != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.openingHours!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDirections(place),
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Directions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.deepOceanBlue,
                      ),
                    ),
                  ),
                  if (place.phone != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callPhone(place.phone!),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.tropicalGreen,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(PlaceType type) {
    switch (type) {
      case PlaceType.restaurant:
        return AppConstants.sunsetOrange;
      case PlaceType.cafe:
        return AppConstants.ancientBrown;
      case PlaceType.hotel:
        return AppConstants.deepOceanBlue;
      case PlaceType.bar:
        return AppConstants.spiceYellow;
      case PlaceType.other:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No places found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search radius',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
              label: const Text('Change Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.sunsetOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading places',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unknown error occurred',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPlaces,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.sunsetOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Places'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Place Types',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    title: const Text('🍽️ Restaurants'),
                    value: _selectedTypes.contains(PlaceType.restaurant),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedTypes.add(PlaceType.restaurant);
                        } else {
                          _selectedTypes.remove(PlaceType.restaurant);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('☕ Cafes'),
                    value: _selectedTypes.contains(PlaceType.cafe),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedTypes.add(PlaceType.cafe);
                        } else {
                          _selectedTypes.remove(PlaceType.cafe);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('🏨 Hotels'),
                    value: _selectedTypes.contains(PlaceType.hotel),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedTypes.add(PlaceType.hotel);
                        } else {
                          _selectedTypes.remove(PlaceType.hotel);
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('🍺 Bars & Pubs'),
                    value: _selectedTypes.contains(PlaceType.bar),
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          _selectedTypes.add(PlaceType.bar);
                        } else {
                          _selectedTypes.remove(PlaceType.bar);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Search Radius',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _radiusKm.toDouble(),
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: '${_radiusKm}km',
                    onChanged: (value) {
                      setDialogState(() {
                        _radiusKm = value.round();
                      });
                    },
                  ),
                  Center(
                    child: Text(
                      '${_radiusKm}km radius',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _loadPlaces();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.sunsetOrange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPlaceDetails(Place place) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(place.icon, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        place.displayDistance,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (place.address != null)
              _buildDetailRow(Icons.place, 'Address', place.address!),
            if (place.phone != null)
              _buildDetailRow(Icons.phone, 'Phone', place.phone!),
            if (place.website != null)
              _buildDetailRow(Icons.web, 'Website', place.website!),
            if (place.cuisine != null)
              _buildDetailRow(Icons.restaurant, 'Cuisine', place.cuisine!),
            if (place.openingHours != null)
              _buildDetailRow(Icons.access_time, 'Hours', place.openingHours!),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openDirections(place);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.deepOceanBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (place.phone != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _callPhone(place.phone!);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.tropicalGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (place.website != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _openWebsite(place.website!);
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Visit Website'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
