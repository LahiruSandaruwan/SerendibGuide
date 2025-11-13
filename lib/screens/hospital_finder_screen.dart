import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/hospital.dart';
import '../utils/constants.dart';

/// Screen for finding hospitals and medical facilities
class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen> {
  String? _filterCity;
  HospitalType? _filterType;
  bool _filter24Hour = false;
  String _searchQuery = '';

  List<Hospital> _getFilteredHospitals() {
    var hospitals = HospitalsData.getAllHospitals();

    // Filter by city
    if (_filterCity != null) {
      hospitals = hospitals.where((h) => h.city == _filterCity).toList();
    }

    // Filter by type
    if (_filterType != null) {
      hospitals = hospitals.where((h) => h.type == _filterType).toList();
    }

    // Filter by 24-hour
    if (_filter24Hour) {
      hospitals = hospitals.where((h) => h.has24HourEmergency).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      hospitals = hospitals.where((h) {
        return h.name.toLowerCase().contains(query) ||
            h.address.toLowerCase().contains(query) ||
            h.city.toLowerCase().contains(query);
      }).toList();
    }

    return hospitals;
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot make phone calls')),
        );
      }
    }
  }

  void _copyNumber(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $number')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHospitals = _getFilteredHospitals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital Finder'),
        backgroundColor: AppConstants.deepOceanBlue,
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search hospitals...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),

                // Filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // City filter
                    DropdownButton<String?>(
                      value: _filterCity,
                      hint: const Text('All Cities'),
                      underline: Container(),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Cities'),
                        ),
                        ...HospitalsData.getAllCities().map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _filterCity = value);
                      },
                    ),

                    const SizedBox(width: 8),

                    // Type filter
                    DropdownButton<HospitalType?>(
                      value: _filterType,
                      hint: const Text('All Types'),
                      underline: Container(),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...HospitalType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => _filterType = value);
                      },
                    ),

                    const SizedBox(width: 8),

                    // 24-hour filter
                    FilterChip(
                      label: const Text('24/7 Only'),
                      selected: _filter24Hour,
                      onSelected: (selected) {
                        setState(() => _filter24Hour = selected);
                      },
                      selectedColor: AppConstants.tropicalGreen.withOpacity(0.2),
                      checkmarkColor: AppConstants.tropicalGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Text(
              '${filteredHospitals.length} ${filteredHospitals.length == 1 ? 'facility' : 'facilities'} found',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Hospitals list
          Expanded(
            child: filteredHospitals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHospitals.length,
                    itemBuilder: (context, index) {
                      return _buildHospitalCard(filteredHospitals[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_hospital, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hospitals found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hospital.type.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.deepOceanBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hospital.type.displayName,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppConstants.deepOceanBlue,
                              ),
                            ),
                          ),
                          if (hospital.has24HourEmergency) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '24/7',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${hospital.address}, ${hospital.city}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Services
            if (hospital.services.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hospital.services.take(3).map((service) {
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
                      service,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.tropicalGreen,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (hospital.services.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+${hospital.services.length - 3} more services',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 12),
            ],

            // Phone numbers
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hospital.phone,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (hospital.emergencyPhone != null &&
                          hospital.emergencyPhone != hospital.phone) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Emergency: ${hospital.emergencyPhone}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Call button
                ElevatedButton.icon(
                  onPressed: () => _makeCall(
                    hospital.emergencyPhone ?? hospital.phone,
                  ),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                // Copy button
                IconButton(
                  onPressed: () => _copyNumber(hospital.phone),
                  icon: const Icon(Icons.copy, size: 18),
                  color: AppConstants.deepOceanBlue,
                  tooltip: 'Copy number',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
