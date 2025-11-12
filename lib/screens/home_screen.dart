import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/attraction.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../services/admob_service.dart';
import '../utils/constants.dart';
import '../widgets/attraction_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_widget.dart';
import 'attraction_detail_screen.dart';

/// Home screen with category filters and attraction list
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Attraction> _attractions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttractions();
  }

  Future<void> _loadAttractions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appState = context.read<AppStateProvider>();
      final attractions = await _databaseService.getAttractions(
        category: appState.selectedCategory,
        includePremium: appState.isPremium,
      );

      if (mounted) {
        setState(() {
          _attractions = attractions;
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

  Future<void> _onAttractionTap(Attraction attraction) async {
    final appState = context.read<AppStateProvider>();

    // Increment ad impressions
    final shouldShowInterstitial = await appState.incrementAdImpressions();

    // Show interstitial ad if needed
    if (shouldShowInterstitial && !appState.isPremium) {
      await AdMobService.loadAndShowInterstitial();
    }

    // Navigate to detail screen
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttractionDetailScreen(attraction: attraction),
      ),
    );

    // Reload in case favorites changed
    _loadAttractions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              AppConstants.appName,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              AppConstants.appTagline,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              // TODO: Navigate to map screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map coming soon!')),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryFilter(),

          // Attraction list
          Expanded(
            child: _buildContent(),
          ),

          // Ad banner (only for free users)
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.deepOceanBlue,
                      AppConstants.tropicalGreen,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.explore,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppConstants.appName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appState.isPremium ? '✨ Premium User' : 'Free Version',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites'),
                subtitle: Text('${appState.favoriteIds.length} saved'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to favorites
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Favorites coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.route),
                title: const Text('My Trips'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to trips
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trips coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.train),
                title: const Text('Train Routes'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to info screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Travel info coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Travel Information'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to info screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Travel info coming soon!')),
                  );
                },
              ),
              const Divider(),
              if (!appState.isPremium)
                ListTile(
                  leading: const Icon(Icons.star, color: AppConstants.premiumGold),
                  title: const Text('Upgrade to Premium'),
                  subtitle: const Text('Unlock all features'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Navigate to premium screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Premium upgrade coming soon!')),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing16),
            children: [
              CategoryChip(
                label: 'All',
                isSelected: appState.selectedCategory == null,
                onTap: () {
                  appState.setSelectedCategory(null);
                  _loadAttractions();
                },
                icon: Icons.apps,
              ),
              ...AppConstants.categories.map((category) {
                return CategoryChip(
                  label: category,
                  isSelected: appState.selectedCategory == category,
                  onTap: () {
                    appState.setSelectedCategory(category);
                    _loadAttractions();
                  },
                  icon: CategoryConfig.getCategoryIcon(category),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading attractions...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _loadAttractions,
      );
    }

    if (_attractions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.explore_off,
        title: 'No attractions found',
        subtitle: 'Try selecting a different category',
        actionLabel: 'Show All',
        onAction: () {
          context.read<AppStateProvider>().setSelectedCategory(null);
          _loadAttractions();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttractions,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.spacing16),
        itemCount: _attractions.length,
        itemBuilder: (context, index) {
          final attraction = _attractions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.spacing16),
            child: AttractionCard(
              attraction: attraction,
              onTap: () => _onAttractionTap(attraction),
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.explore, size: 48),
      children: [
        const Text(
          AppConstants.appTagline,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        const Text(
          'Complete offline travel guide for Sri Lanka featuring 300+ curated attractions, offline maps, and essential travel information.',
        ),
      ],
    );
  }
}
