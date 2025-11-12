import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../utils/constants.dart';

/// Food dictionary with Sri Lankan dishes
class FoodDictionaryScreen extends StatefulWidget {
  const FoodDictionaryScreen({super.key});

  @override
  State<FoodDictionaryScreen> createState() => _FoodDictionaryScreenState();
}

class _FoodDictionaryScreenState extends State<FoodDictionaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showVegetarianOnly = false;
  bool _showVeganOnly = false;
  SpiceLevel? _filterSpiceLevel;

  final List<DishCategory> _categories = [
    DishCategory.rice,
    DishCategory.curry,
    DishCategory.bread,
    DishCategory.breakfast,
    DishCategory.snacks,
    DishCategory.seafood,
    DishCategory.desserts,
    DishCategory.drinks,
    DishCategory.streetFood,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Dish> _getFilteredDishes({DishCategory? category}) {
    var dishes = category == null
        ? FoodDictionaryData.getAllDishes()
        : FoodDictionaryData.getDishesByCategory(category);

    // Apply dietary filters
    if (_showVeganOnly) {
      dishes = dishes.where((d) => d.isVegan).toList();
    } else if (_showVegetarianOnly) {
      dishes = dishes.where((d) => d.isVegetarian).toList();
    }

    // Apply spice level filter
    if (_filterSpiceLevel != null) {
      dishes = dishes.where((d) => d.spiceLevel == _filterSpiceLevel).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      dishes = dishes.where((d) {
        final query = _searchQuery.toLowerCase();
        return d.name.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query) ||
            d.mainIngredients.any((ing) => ing.toLowerCase().contains(query));
      }).toList();
    }

    return dishes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Dictionary'),
        backgroundColor: AppConstants.tropicalGreen,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Column(
            children: [
              // Search bar
              Container(
                color: AppConstants.tropicalGreen,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search dishes...',
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

              // Filters
              Container(
                color: AppConstants.tropicalGreen,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Vegetarian filter
                      FilterChip(
                        label: const Text('Vegetarian'),
                        selected: _showVegetarianOnly,
                        onSelected: (value) {
                          setState(() {
                            _showVegetarianOnly = value;
                            if (value) _showVeganOnly = false;
                          });
                        },
                        avatar: const Icon(Icons.eco, size: 18),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white.withOpacity(0.4),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),

                      // Vegan filter
                      FilterChip(
                        label: const Text('Vegan'),
                        selected: _showVeganOnly,
                        onSelected: (value) {
                          setState(() {
                            _showVeganOnly = value;
                            if (value) _showVegetarianOnly = false;
                          });
                        },
                        avatar: const Icon(Icons.spa, size: 18),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white.withOpacity(0.4),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 8),

                      // Spice level filters
                      ...SpiceLevel.values.map((level) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              '${FoodDictionaryData.spiceLevelEmoji[level]} ${FoodDictionaryData.spiceLevelNames[level]}',
                            ),
                            selected: _filterSpiceLevel == level,
                            onSelected: (value) {
                              setState(() {
                                _filterSpiceLevel = value ? level : null;
                              });
                            },
                            backgroundColor: Colors.white.withOpacity(0.2),
                            selectedColor: Colors.white.withOpacity(0.4),
                            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // Category tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: [
                  const Tab(text: 'All'),
                  ..._categories.map((category) {
                    return Tab(text: FoodDictionaryData.categoryNames[category]);
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDishList(_getFilteredDishes()),
          ..._categories.map((category) {
            return _buildDishList(_getFilteredDishes(category: category));
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDishList(List<Dish> dishes) {
    if (dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No dishes found',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        return _buildDishCard(dishes[index]);
      },
    );
  }

  Widget _buildDishCard(Dish dish) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and tags
            Row(
              children: [
                Expanded(
                  child: Text(
                    dish.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (dish.isVegan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.tropicalGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🌱 Vegan',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (dish.isVegetarian)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🥬 Veg',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Spice level
            Row(
              children: [
                Text(
                  FoodDictionaryData.spiceLevelEmoji[dish.spiceLevel]!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  'Spice Level: ${FoodDictionaryData.spiceLevelNames[dish.spiceLevel]}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              dish.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 12),

            // Ingredients
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: dish.mainIngredients.map((ingredient) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.deepOceanBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ingredient,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),

            // Best place to try
            if (dish.bestPlaceToTry != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.sunsetOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppConstants.sunsetOrange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place,
                      size: 16,
                      color: AppConstants.sunsetOrange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Best at: ${dish.bestPlaceToTry}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],

            // Cultural note
            if (dish.culturalNote != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.tropicalGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppConstants.tropicalGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppConstants.tropicalGreen,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dish.culturalNote!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
