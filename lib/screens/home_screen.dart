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
import 'achievements_screen.dart';
import 'attraction_detail_screen.dart';
import 'best_time_advisor_screen.dart';
import 'budget_calculator_screen.dart';
import 'currency_converter_screen.dart';
import 'etiquette_guide_screen.dart';
import 'expense_tracker_screen.dart';
import 'favorites_screen.dart';
import 'festival_calendar_screen.dart';
import 'food_dictionary_screen.dart';
import 'golden_hour_calculator_screen.dart';
import 'info_screen.dart';
import 'itinerary_generator_screen.dart';
import 'map_screen.dart';
import 'phrasebook_screen.dart';
import 'premium_screen.dart';
import 'route_optimizer_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'stats_dashboard_screen.dart';
import 'trip_planner_screen.dart';
import 'tuktuk_fare_estimator_screen.dart';

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
              showSearch(
                context: context,
                delegate: AttractionSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MapScreen(),
                ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoritesScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.route),
                title: const Text('My Trips'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TripPlannerScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Gamification section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'YOUR PROGRESS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: AppConstants.tropicalGreen),
                title: const Text('My Stats'),
                subtitle: const Text('View your progress'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatsDashboardScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: AppConstants.premiumGold),
                title: const Text('Achievements'),
                subtitle: const Text('Unlock badges'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AchievementsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Travel Information'),
                subtitle: const Text('Trains, buses, emergency'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InfoScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Tools section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'TOOLS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calculate, color: AppConstants.deepOceanBlue),
                title: const Text('Budget Calculator'),
                subtitle: const Text('Estimate trip costs'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BudgetCalculatorScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long, color: AppConstants.tropicalGreen),
                title: const Text('Expense Tracker'),
                subtitle: const Text('Track your spending'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpenseTrackerScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.currency_exchange, color: AppConstants.sunsetOrange),
                title: const Text('Currency Converter'),
                subtitle: const Text('LKR to 20+ currencies'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CurrencyConverterScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.electric_rickshaw, color: AppConstants.sunsetOrange),
                title: const Text('Tuk-Tuk Fare Estimator'),
                subtitle: const Text('Fair price calculator'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TukTukFareEstimatorScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: AppConstants.sunsetOrange),
                title: const Text('Golden Hour Calculator'),
                subtitle: const Text('Best photo times'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GoldenHourCalculatorScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Cultural section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'CULTURAL GUIDE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: AppConstants.deepOceanBlue),
                title: const Text('Phrasebook'),
                subtitle: const Text('Sinhala & Tamil phrases'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhrasebookScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.restaurant_menu, color: AppConstants.tropicalGreen),
                title: const Text('Food Dictionary'),
                subtitle: const Text('Sri Lankan dishes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodDictionaryScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.diversity_3, color: AppConstants.sunsetOrange),
                title: const Text('Etiquette Guide'),
                subtitle: const Text('Cultural do\'s & don\'ts'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EtiquetteGuideScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.celebration, color: AppConstants.premiumGold),
                title: const Text('Festival Calendar'),
                subtitle: const Text('Holidays & celebrations'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FestivalCalendarScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              // Smart Features section header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'SMART FEATURES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome, color: AppConstants.deepOceanBlue),
                title: const Text('AI Itinerary Generator'),
                subtitle: const Text('Create personalized trips'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItineraryGeneratorScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.route, color: AppConstants.tropicalGreen),
                title: const Text('Route Optimizer'),
                subtitle: const Text('Optimize your route'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RouteOptimizerScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: AppConstants.sunsetOrange),
                title: const Text('Best Time to Visit'),
                subtitle: const Text('Weather & crowd analysis'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BestTimeAdvisorScreen(),
                    ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
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
