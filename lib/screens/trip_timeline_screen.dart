import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';

/// Visual timeline of the user's journey through Sri Lanka
class TripTimelineScreen extends StatefulWidget {
  const TripTimelineScreen({super.key});

  @override
  State<TripTimelineScreen> createState() => _TripTimelineScreenState();
}

class _TripTimelineScreenState extends State<TripTimelineScreen> {
  final UserDataService _userDataService = UserDataService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  Map<String, int> _attractionVisits = {};
  DateTime? _firstVisit;
  DateTime? _lastVisit;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    try {
      final entriesData = await _userDataService.getJournalEntries();
      final entries = entriesData.map((data) => JournalEntry.fromMap(data)).toList();

      // Sort by visit date
      entries.sort((a, b) => a.visitDate.compareTo(b.visitDate));

      // Calculate statistics
      final Map<String, int> visits = {};
      for (var entry in entries) {
        visits[entry.attractionName] = (visits[entry.attractionName] ?? 0) + 1;
      }

      setState(() {
        _entries = entries;
        _attractionVisits = visits;
        if (entries.isNotEmpty) {
          _firstVisit = entries.first.visitDate;
          _lastVisit = entries.last.visitDate;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading timeline: $e')),
        );
      }
    }
  }

  int _getTripDuration() {
    if (_firstVisit == null || _lastVisit == null) return 0;
    return _lastVisit!.difference(_firstVisit!).inDays + 1;
  }

  double _getAverageRating() {
    if (_entries.isEmpty) return 0.0;
    final total = _entries.fold(0, (sum, entry) => sum + entry.rating);
    return total / _entries.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journey'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildStatsHeader(),
                      _buildTimeline(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Your journey awaits!',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding journal entries to see your trip timeline',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.deepOceanBlue,
            AppConstants.deepOceanBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.flight_takeoff,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'Sri Lanka Adventure',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (_firstVisit != null && _lastVisit != null) ...[
            Text(
              '${dateFormat.format(_firstVisit!)} - ${dateFormat.format(_lastVisit!)}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                Icons.calendar_today,
                '${_getTripDuration()}',
                'Days',
              ),
              _buildStatItem(
                Icons.place,
                '${_attractionVisits.length}',
                'Places',
              ),
              _buildStatItem(
                Icons.book,
                '${_entries.length}',
                'Entries',
              ),
              _buildStatItem(
                Icons.star,
                _getAverageRating().toStringAsFixed(1),
                'Avg Rating',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isFirst = index == 0;
        final isLast = index == _entries.length - 1;

        return _buildTimelineItem(entry, isFirst, isLast);
      },
    );
  }

  Widget _buildTimelineItem(JournalEntry entry, bool isFirst, bool isLast) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppConstants.deepOceanBlue.withOpacity(0.3),
                    ),
                  ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getRatingColor(entry.rating),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getRatingColor(entry.rating).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${entry.rating}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppConstants.deepOceanBlue.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content card
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.deepOceanBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dateFormat.format(entry.visitDate),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.deepOceanBlue,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Star rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < entry.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 14,
                              color: AppConstants.sunsetOrange,
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Attraction name
                    Row(
                      children: [
                        const Icon(
                          Icons.place,
                          size: 18,
                          color: AppConstants.sunsetOrange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.attractionName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.deepOceanBlue,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Content preview
                    Text(
                      entry.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey[700],
                      ),
                    ),

                    // Tags
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: entry.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.tropicalGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppConstants.tropicalGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppConstants.tropicalGreen,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Special markers
                    if (isFirst || isLast) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isFirst
                              ? Colors.green.withOpacity(0.1)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isFirst
                                ? Colors.green.withOpacity(0.3)
                                : Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isFirst ? Icons.flight_takeoff : Icons.flight_land,
                              size: 14,
                              color: isFirst ? Colors.green : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isFirst ? 'Journey Start' : 'Most Recent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isFirst ? Colors.green : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) {
      return Colors.green;
    } else if (rating >= 3) {
      return AppConstants.sunsetOrange;
    } else if (rating >= 2) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
