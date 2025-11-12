import 'package:flutter/material.dart';
import '../models/photo_spot.dart';
import '../utils/constants.dart';

/// Photo spots guide for photographers
class PhotoSpotsScreen extends StatefulWidget {
  const PhotoSpotsScreen({super.key});

  @override
  State<PhotoSpotsScreen> createState() => _PhotoSpotsScreenState();
}

class _PhotoSpotsScreenState extends State<PhotoSpotsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  PhotoDifficulty? _filterDifficulty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PhotoSpot> _getFilteredSpots() {
    var spots = PhotoSpotsData.getAllPhotoSpots();

    // Apply difficulty filter
    if (_filterDifficulty != null) {
      spots = spots.where((spot) => spot.difficulty == _filterDifficulty).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      spots = spots.where((spot) {
        final query = _searchQuery.toLowerCase();
        return spot.attractionName.toLowerCase().contains(query) ||
            spot.spotName.toLowerCase().contains(query) ||
            spot.description.toLowerCase().contains(query);
      }).toList();
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpots = _getFilteredSpots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Spots'),
        backgroundColor: AppConstants.sunsetOrange,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search bar
              Container(
                color: AppConstants.sunsetOrange,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search photo spots...',
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

              // Difficulty filter
              Container(
                color: AppConstants.sunsetOrange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _filterDifficulty == null,
                        onSelected: (selected) {
                          setState(() => _filterDifficulty = null);
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white.withOpacity(0.4),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      ...PhotoDifficulty.values.map((difficulty) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(PhotoSpotsData.difficultyNames[difficulty]!),
                            selected: _filterDifficulty == difficulty,
                            onSelected: (selected) {
                              setState(() {
                                _filterDifficulty = selected ? difficulty : null;
                              });
                            },
                            backgroundColor: Colors.white.withOpacity(0.2),
                            selectedColor: Colors.white.withOpacity(0.4),
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredSpots.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No photo spots found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                Card(
                  color: AppConstants.sunsetOrange.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt, size: 40, color: AppConstants.sunsetOrange),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Photography Guide',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${filteredSpots.length} photo spots for stunning shots',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Photo spots
                ...filteredSpots.map((spot) => _buildPhotoSpotCard(spot)).toList(),
              ],
            ),
    );
  }

  Widget _buildPhotoSpotCard(PhotoSpot spot) {
    final difficultyColor = _getDifficultyColor(spot.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppConstants.sunsetOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: AppConstants.sunsetOrange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.attractionName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        spot.spotName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    PhotoSpotsData.difficultyNames[spot.difficulty]!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: difficultyColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              spot.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 16),

            // Best time
            _buildInfoRow(
              Icons.wb_sunny,
              'Best Time',
              spot.bestTimeOfDay,
              AppConstants.sunsetOrange,
            ),

            const SizedBox(height: 8),

            // Equipment
            _buildInfoRow(
              Icons.camera,
              'Equipment',
              spot.equipment,
              AppConstants.deepOceanBlue,
            ),

            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.tropicalGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppConstants.tropicalGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tips_and_updates, size: 16, color: AppConstants.tropicalGreen),
                      SizedBox(width: 6),
                      Text(
                        'Photography Tips',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...spot.tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(fontSize: 12, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(PhotoDifficulty difficulty) {
    switch (difficulty) {
      case PhotoDifficulty.easy:
        return Colors.green;
      case PhotoDifficulty.moderate:
        return Colors.orange;
      case PhotoDifficulty.challenging:
        return Colors.red;
    }
  }
}
