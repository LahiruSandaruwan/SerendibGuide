import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/country_info.dart';
import '../services/country_info_service.dart';
import '../utils/constants.dart';

/// Screen displaying comprehensive Sri Lanka country information
class SriLankaInfoScreen extends StatefulWidget {
  const SriLankaInfoScreen({super.key});

  @override
  State<SriLankaInfoScreen> createState() => _SriLankaInfoScreenState();
}

class _SriLankaInfoScreenState extends State<SriLankaInfoScreen>
    with SingleTickerProviderStateMixin {
  final CountryInfoService _service = CountryInfoService();

  late TabController _tabController;
  CountryInfo? _countryInfo;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCountryInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCountryInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final info = await _service.getSriLankaInfo();

      if (mounted) {
        setState(() {
          _countryInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load country information';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Sri Lanka'),
        backgroundColor: AppConstants.tropicalGreen,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Quick Facts'),
            Tab(text: 'Travel Tips'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildQuickFactsTab(),
                    _buildTravelTipsTab(),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading country information...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_error ?? 'Failed to load information'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCountryInfo,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_countryInfo == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadCountryInfo,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Flag and basic info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _countryInfo!.flag,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _countryInfo!.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _countryInfo!.officialName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoChip(
                        Icons.location_on,
                        _countryInfo!.region,
                        AppConstants.deepOceanBlue,
                      ),
                      _buildInfoChip(
                        Icons.public,
                        _countryInfo!.subregion,
                        AppConstants.tropicalGreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Key statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Statistics',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    '👥',
                    'Population',
                    _countryInfo!.populationFormatted,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '📏',
                    'Area',
                    _countryInfo!.areaFormatted,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '🏙️',
                    'Capital',
                    _countryInfo!.capital.join(', '),
                  ),
                  const Divider(),
                  _buildStatRow(
                    '🗣️',
                    'Languages',
                    _countryInfo!.languagesFormatted,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '💰',
                    'Currency',
                    _countryInfo!.currenciesFormatted,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '📞',
                    'Calling Code',
                    _countryInfo!.callingCode,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '🕐',
                    'Timezone',
                    _countryInfo!.timezonesFormatted,
                  ),
                  const Divider(),
                  _buildStatRow(
                    '🚗',
                    'Driving Side',
                    _countryInfo!.drivingSide.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Map links
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View on Map',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openMap(_countryInfo!.maps['googleMaps']!),
                          icon: const Icon(Icons.map),
                          label: const Text('Google Maps'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.deepOceanBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _openMap(_countryInfo!.maps['openStreetMaps']!),
                          icon: const Icon(Icons.public),
                          label: const Text('OpenStreetMap'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.tropicalGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFactsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Essential Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...SriLankaFacts.facts.map((fact) => _buildFactCard(
              fact['icon']!,
              fact['title']!,
              fact['fact']!,
            )),
      ],
    );
  }

  Widget _buildTravelTipsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Important Travel Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Essential information for a smooth trip to Sri Lanka',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ...SriLankaFacts.travelTips.map((tip) => _buildTipCard(
              tip['icon']!,
              tip['title']!,
              tip['tip']!,
            )),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildStatRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String emoji, String title, String fact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.deepOceanBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fact,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppConstants.warningAmber.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.sunsetOrange,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tip,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open map')),
      );
    }
  }
}
