import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

/// Info screen with 5 tabs: Trains, Buses, Emergency, Tips, Culture
class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _routesData;
  Map<String, dynamic>? _travelInfoData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final routesJson = await rootBundle.loadString('assets/data/routes.json');
      final travelInfoJson = await rootBundle.loadString('assets/data/travel_info.json');

      setState(() {
        _routesData = jsonDecode(routesJson);
        _travelInfoData = jsonDecode(travelInfoJson);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Information'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.train), text: 'Trains'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Buses'),
            Tab(icon: Icon(Icons.emergency), text: 'Emergency'),
            Tab(icon: Icon(Icons.tips_and_updates), text: 'Tips'),
            Tab(icon: Icon(Icons.temple_hindu), text: 'Culture'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTrainsTab(),
                _buildBusesTab(),
                _buildEmergencyTab(),
                _buildTipsTab(),
                _buildCultureTab(),
              ],
            ),
    );
  }

  Widget _buildTrainsTab() {
    final routes = _routesData?['train_routes'] as List? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
          child: ExpansionTile(
            leading: const Icon(Icons.train, color: AppConstants.deepOceanBlue),
            title: Text(
              route['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${route['from']} → ${route['to']}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.straighten, 'Distance', '${route['distance_km']} km'),
                    _buildInfoRow(Icons.schedule, 'Duration', route['duration']),
                    _buildInfoRow(Icons.repeat, 'Frequency', route['frequency']),
                    const SizedBox(height: 12),
                    const Text('Prices:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((route['prices'] as Map).entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text('${entry.key.replaceAll('_', ' ')}: Rs ${entry.value}'),
                      );
                    }).toList()),
                    if (route['highlights'] != null) ...[
                      const SizedBox(height: 12),
                      const Text('Highlights:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...((route['highlights'] as List).map((highlight) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppConstants.successGreen)),
                              Expanded(child: Text(highlight)),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                    if (route['tips'] != null) ...[
                      const SizedBox(height: 12),
                      const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...((route['tips'] as List).map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb, size: 16, color: AppConstants.sunsetOrange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusesTab() {
    final routes = _routesData?['bus_routes'] as List? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
          child: ExpansionTile(
            leading: const Icon(Icons.directions_bus, color: AppConstants.tropicalGreen),
            title: Text(
              route['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${route['from']} → ${route['to']}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.straighten, 'Distance', '${route['distance_km']} km'),
                    _buildInfoRow(Icons.schedule, 'Duration', route['duration']),
                    _buildInfoRow(Icons.repeat, 'Frequency', route['frequency']),
                    const SizedBox(height: 12),
                    const Text('Prices:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...((route['prices'] as Map).entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Text('${entry.key.replaceAll('_', ' ')}: Rs ${entry.value}'),
                      );
                    }).toList()),
                    if (route['tips'] != null) ...[
                      const SizedBox(height: 12),
                      const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...((route['tips'] as List).map((tip) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb, size: 16, color: AppConstants.sunsetOrange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        );
                      }).toList()),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmergencyTab() {
    final contacts = _travelInfoData?['emergency_contacts'] as List? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final category = contacts[index];
        final categoryName = category['category'];
        final categoryContacts = category['contacts'] as List;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                categoryName.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.deepOceanBlue,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ...categoryContacts.map((contact) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    _getEmergencyIcon(contact['icon']),
                    color: AppConstants.errorRed,
                  ),
                  title: Text(
                    contact['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['phone'],
                        style: const TextStyle(
                          color: AppConstants.deepOceanBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (contact['description'] != null)
                        Text(contact['description']),
                      if (contact['address'] != null)
                        Text(contact['address'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () => _makeCall(contact['phone']),
                  ),
                  isThreeLine: true,
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTipsTab() {
    final tips = _travelInfoData?['travel_tips'] as List? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final category = tips[index];
        final categoryName = category['category'];
        final categoryTips = category['tips'] as List;

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
          child: ExpansionTile(
            leading: const Icon(Icons.tips_and_updates, color: AppConstants.sunsetOrange),
            title: Text(
              categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: categoryTips.map((tip) {
              return Padding(
                padding: const EdgeInsets.all(AppConstants.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.deepOceanBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(tip['content']),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildCultureTab() {
    final etiquette = _travelInfoData?['cultural_etiquette'] as List? ?? [];
    final phrases = _travelInfoData?['useful_phrases'] as Map? ?? {};

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacing16),
      children: [
        // Cultural Etiquette
        const Text(
          'CULTURAL ETIQUETTE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.deepOceanBlue,
          ),
        ),
        const SizedBox(height: 16),
        ...etiquette.map((category) {
          final categoryName = category['category'];
          final rules = category['rules'] as List;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: const Icon(Icons.menu_book, color: AppConstants.tropicalGreen),
              title: Text(
                categoryName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: rules.map((rule) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: AppConstants.successGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rule['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Text(rule['content']),
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),

        const SizedBox(height: 24),

        // Useful Phrases
        const Text(
          'USEFUL PHRASES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.deepOceanBlue,
          ),
        ),
        const SizedBox(height: 16),

        // Sinhala Phrases
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.translate, color: AppConstants.sunsetOrange),
            title: const Text('Sinhala Phrases', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ...((phrases['sinhala'] as List?) ?? []).map((phrase) {
                return ListTile(
                  title: Text(phrase['sinhala'], style: const TextStyle(fontSize: 18)),
                  subtitle: Text('${phrase['english']}\nPronunciation: ${phrase['pronunciation']}'),
                  isThreeLine: true,
                );
              }).toList(),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tamil Phrases
        Card(
          child: ExpansionTile(
            leading: const Icon(Icons.translate, color: AppConstants.sunsetOrange),
            title: const Text('Tamil Phrases', style: TextStyle(fontWeight: FontWeight.bold)),
            children: [
              ...((phrases['tamil'] as List?) ?? []).map((phrase) {
                return ListTile(
                  title: Text(phrase['tamil'], style: const TextStyle(fontSize: 18)),
                  subtitle: Text('${phrase['english']}\nPronunciation: ${phrase['pronunciation']}'),
                  isThreeLine: true,
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getEmergencyIcon(String? iconName) {
    switch (iconName) {
      case 'local_police':
        return Icons.local_police;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'shield':
        return Icons.shield;
      default:
        return Icons.emergency;
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not dial $phone')),
      );
    }
  }
}
