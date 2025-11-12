import 'package:flutter/material.dart';
import '../models/attraction.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'dart:math';

/// Route optimizer for multi-attraction visits
class RouteOptimizerScreen extends StatefulWidget {
  const RouteOptimizerScreen({super.key});

  @override
  State<RouteOptimizerScreen> createState() => _RouteOptimizerScreenState();
}

class _RouteOptimizerScreenState extends State<RouteOptimizerScreen> {
  final DatabaseService _databaseService = DatabaseService();

  List<Attraction> _allAttractions = [];
  List<Attraction> _selectedAttractions = [];
  List<Attraction> _optimizedRoute = [];
  bool _isLoading = true;
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _loadAttractions();
  }

  Future<void> _loadAttractions() async {
    setState(() => _isLoading = true);
    try {
      final attractions = await _databaseService.getAttractions();
      setState(() {
        _allAttractions = attractions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading attractions: $e');
      setState(() => _isLoading = false);
    }
  }

  void _optimizeRoute() {
    if (_selectedAttractions.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 attractions to optimize')),
      );
      return;
    }

    setState(() => _isOptimizing = true);

    // Simple nearest-neighbor optimization
    final optimized = _nearestNeighborRoute(_selectedAttractions);

    setState(() {
      _optimizedRoute = optimized;
      _isOptimizing = false;
    });
  }

  List<Attraction> _nearestNeighborRoute(List<Attraction> attractions) {
    if (attractions.isEmpty) return [];

    final List<Attraction> route = [];
    final List<Attraction> remaining = List.from(attractions);

    // Start with first attraction
    route.add(remaining.removeAt(0));

    // Build route by always picking nearest unvisited attraction
    while (remaining.isNotEmpty) {
      final current = route.last;
      Attraction? nearest;
      double minDistance = double.infinity;

      for (var attraction in remaining) {
        final distance = _calculateDistance(current, attraction);
        if (distance < minDistance) {
          minDistance = distance;
          nearest = attraction;
        }
      }

      if (nearest != null) {
        route.add(nearest);
        remaining.remove(nearest);
      }
    }

    return route;
  }

  double _calculateDistance(Attraction a, Attraction b) {
    // Simple Euclidean distance using lat/lng
    // For more accuracy, could use Haversine formula
    final lat1 = a.latitude;
    final lon1 = a.longitude;
    final lat2 = b.latitude;
    final lon2 = b.longitude;

    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) {
      return 1000.0; // Large distance for unknown locations
    }

    final dx = lat2 - lat1;
    final dy = lon2 - lon1;
    return sqrt(dx * dx + dy * dy);
  }

  double _calculateTotalDistance(List<Attraction> route) {
    if (route.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      total += _calculateDistance(route[i], route[i + 1]);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Optimizer'),
        backgroundColor: AppConstants.tropicalGreen,
        actions: [
          if (_selectedAttractions.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedAttractions.clear();
                  _optimizedRoute.clear();
                });
              },
              icon: const Icon(Icons.clear_all, color: Colors.white),
              label: const Text('Clear', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header
                Container(
                  color: AppConstants.tropicalGreen.withOpacity(0.1),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.route, color: AppConstants.tropicalGreen, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Optimize Your Route',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Select attractions and we\'ll find the best route',
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_selectedAttractions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          '${_selectedAttractions.length} attractions selected',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.tropicalGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Attraction selection or optimized route
                Expanded(
                  child: _optimizedRoute.isEmpty
                      ? _buildAttractionSelection()
                      : _buildOptimizedRoute(),
                ),

                // Optimize button
                if (_selectedAttractions.isNotEmpty && _optimizedRoute.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isOptimizing ? null : _optimizeRoute,
                        icon: _isOptimizing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_fix_high),
                        label: Text(_isOptimizing ? 'Optimizing...' : 'Optimize Route'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.tropicalGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildAttractionSelection() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allAttractions.length,
      itemBuilder: (context, index) {
        final attraction = _allAttractions[index];
        final isSelected = _selectedAttractions.contains(attraction);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? AppConstants.tropicalGreen.withOpacity(0.1) : null,
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedAttractions.add(attraction);
                } else {
                  _selectedAttractions.remove(attraction);
                }
              });
            },
            title: Text(
              attraction.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              '${attraction.province ?? "Unknown"} • ${attraction.category}',
              style: const TextStyle(fontSize: 12),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.tropicalGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: AppConstants.tropicalGreen),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptimizedRoute() {
    final totalDistance = _calculateTotalDistance(_optimizedRoute);
    final estimatedTime = (totalDistance * 30).round(); // Rough estimate: 30 min per unit distance

    return Column(
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          color: AppConstants.tropicalGreen.withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(Icons.route, 'Optimized', '${_optimizedRoute.length} stops'),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              _buildStat(Icons.access_time, 'Estimated', '~${estimatedTime}min travel'),
            ],
          ),
        ),

        // Route
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _optimizedRoute.length,
            itemBuilder: (context, index) {
              final attraction = _optimizedRoute[index];
              final isLast = index == _optimizedRoute.length - 1;

              return Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppConstants.tropicalGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        attraction.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${attraction.province ?? "Unknown"} • ${attraction.category}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: 2,
                            height: 30,
                            color: AppConstants.tropicalGreen.withOpacity(0.3),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _optimizedRoute.clear());
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Selection'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Save to trip planner
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route saved!')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.tropicalGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.tropicalGreen),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
