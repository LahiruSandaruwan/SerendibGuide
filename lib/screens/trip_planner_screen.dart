import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attraction.dart';
import '../models/trip.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import 'attraction_detail_screen.dart';

/// Trip Planner screen for creating and managing trips
class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final UserDataService _userDataService = UserDataService();
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final trips = await _userDataService.getTrips();
      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trips: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTripDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading trips...');
    }

    if (_trips.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.route,
        title: 'No trips yet',
        subtitle: 'Plan your first adventure in Sri Lanka!',
        actionLabel: 'Create Trip',
        onAction: () => _showCreateTripDialog(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return Dismissible(
            key: Key('trip_${trip.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: AppConstants.errorRed,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) => _confirmDelete(trip),
            onDismissed: (direction) => _deleteTrip(trip.id!),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppConstants.deepOceanBlue,
                  child: Text(
                    '${trip.attractionCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  trip.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Created ${Helpers.formatRelativeTime(trip.createdAt)}\n'
                  '${trip.attractionCount} ${trip.attractionCount == 1 ? 'attraction' : 'attractions'}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _openTripDetail(trip),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateTripDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Trip'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Trip Name',
              hintText: 'My Sri Lanka Adventure',
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a trip name')),
                  );
                  return;
                }

                // Check free user limit
                final appState = context.read<AppStateProvider>();
                if (!appState.isPremium && _trips.length >= AppConstants.freeTripsLimit) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Free users can create up to ${AppConstants.freeTripsLimit} trips. Upgrade to Premium for unlimited!'),
                      backgroundColor: AppConstants.errorRed,
                    ),
                  );
                  return;
                }

                try {
                  await _userDataService.createTrip(controller.text.trim(), []);
                  Navigator.pop(context);
                  _loadTrips();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trip created!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmDelete(Trip trip) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: Text('Are you sure you want to delete "${trip.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppConstants.errorRed),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _deleteTrip(int tripId) async {
    try {
      await _userDataService.deleteTrip(tripId);
      _loadTrips();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _openTripDetail(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailScreen(trip: trip),
      ),
    ).then((_) => _loadTrips());
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Trip Planner'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create custom itineraries for your Sri Lanka journey!'),
                SizedBox(height: 12),
                Text('• Tap + to create a new trip'),
                Text('• Tap a trip to view and edit'),
                Text('• Swipe left to delete a trip'),
                Text('• Add attractions from trip details'),
                SizedBox(height: 12),
                Text('Free users: 3 trips max\nPremium: Unlimited trips',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

/// Trip Detail Screen to view and edit trip
class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final UserDataService _userDataService = UserDataService();
  late Trip _trip;
  List<Attraction> _attractions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
    _loadAttractions();
  }

  Future<void> _loadAttractions() async {
    setState(() => _isLoading = true);
    try {
      if (_trip.attractionIds.isEmpty) {
        setState(() {
          _attractions = [];
          _isLoading = false;
        });
        return;
      }

      final attractions = await _databaseService.getAttractionsByIds(_trip.attractionIds);
      if (mounted) {
        setState(() {
          _attractions = attractions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_trip.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTripName(),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareTrip(),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _attractions.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.add_location_alt,
                  title: 'No attractions yet',
                  subtitle: 'Add attractions to your trip',
                  actionLabel: 'Browse Attractions',
                  onAction: () => Navigator.pop(context),
                )
              : Column(
                  children: [
                    // Trip Stats
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacing16),
                      color: AppConstants.deepOceanBlue.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(Icons.place, '${_attractions.length}', 'Places'),
                          _buildStat(Icons.straighten, _calculateTotalDistance(), 'Distance'),
                          _buildStat(Icons.schedule, _calculateTotalDuration(), 'Duration'),
                        ],
                      ),
                    ),

                    // Attractions List
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.all(AppConstants.spacing16),
                        itemCount: _attractions.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final attraction = _attractions[index];
                          return Card(
                            key: Key('attraction_${attraction.id}'),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: CategoryConfig.getCategoryColor(attraction.category),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(attraction.nameEn),
                              subtitle: Text('${attraction.category} • ${attraction.province}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.drag_handle, color: Colors.grey[400]),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: AppConstants.errorRed),
                                    onPressed: () => _removeAttraction(attraction.id!),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AttractionDetailScreen(attraction: attraction),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppConstants.deepOceanBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _calculateTotalDistance() {
    if (_attractions.length < 2) return 'N/A';

    double totalDistance = 0;
    for (int i = 0; i < _attractions.length - 1; i++) {
      totalDistance += _attractions[i].distanceFrom(
        _attractions[i + 1].latitude,
        _attractions[i + 1].longitude,
      );
    }

    return Helpers.formatDistance(totalDistance);
  }

  String _calculateTotalDuration() {
    if (_attractions.isEmpty) return 'N/A';

    final durations = _attractions
        .where((a) => a.duration != null)
        .map((a) => a.duration!)
        .toList();

    if (durations.isEmpty) return 'N/A';

    return Helpers.calculateTripDuration(durations);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final attraction = _attractions.removeAt(oldIndex);
      _attractions.insert(newIndex, attraction);

      // Update trip with new order
      _trip = _trip.copyWith(
        attractionIds: _attractions.map((a) => a.id!).toList(),
      );
    });

    // Save to database
    _userDataService.updateTrip(
      _trip.id!,
      _trip.name,
      _trip.attractionIds,
    );
  }

  Future<void> _removeAttraction(int attractionId) async {
    try {
      final newIds = _trip.attractionIds.where((id) => id != attractionId).toList();
      await _userDataService.updateTrip(_trip.id!, _trip.name, newIds);

      setState(() {
        _trip = _trip.copyWith(attractionIds: newIds);
      });

      _loadAttractions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from trip')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _editTripName() {
    final controller = TextEditingController(text: _trip.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Trip Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Trip Name',
              border: OutlineInputBorder(),
            ),
            maxLength: 50,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                try {
                  await _userDataService.updateTrip(
                    _trip.id!,
                    controller.text.trim(),
                    _trip.attractionIds,
                  );

                  setState(() {
                    _trip = _trip.copyWith(name: controller.text.trim());
                  });

                  Navigator.pop(context);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trip name updated')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _shareTrip() {
    final attractionNames = _attractions.map((a) => a.nameEn).toList();
    final shareText = Helpers.getTripShareText(_trip.name, attractionNames);

    // TODO: Implement Share.share(shareText)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share trip: $shareText')),
    );
  }
}
