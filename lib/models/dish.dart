/// Sri Lankan dish model
class Dish {
  final String name;
  final String description;
  final DishCategory category;
  final SpiceLevel spiceLevel;
  final List<String> mainIngredients;
  final bool isVegetarian;
  final bool isVegan;
  final String? culturalNote;
  final String? bestPlaceToTry;

  const Dish({
    required this.name,
    required this.description,
    required this.category,
    required this.spiceLevel,
    required this.mainIngredients,
    this.isVegetarian = false,
    this.isVegan = false,
    this.culturalNote,
    this.bestPlaceToTry,
  });
}

enum DishCategory {
  rice,
  curry,
  bread,
  snacks,
  breakfast,
  seafood,
  desserts,
  drinks,
  streetFood,
}

enum SpiceLevel {
  mild,
  medium,
  hot,
  veryHot,
}

/// Food dictionary data
class FoodDictionaryData {
  static const Map<DishCategory, String> categoryNames = {
    DishCategory.rice: 'Rice Dishes',
    DishCategory.curry: 'Curries',
    DishCategory.bread: 'Breads & Rotis',
    DishCategory.snacks: 'Snacks',
    DishCategory.breakfast: 'Breakfast',
    DishCategory.seafood: 'Seafood',
    DishCategory.desserts: 'Desserts',
    DishCategory.drinks: 'Drinks',
    DishCategory.streetFood: 'Street Food',
  };

  static const Map<SpiceLevel, String> spiceLevelNames = {
    SpiceLevel.mild: 'Mild',
    SpiceLevel.medium: 'Medium',
    SpiceLevel.hot: 'Hot',
    SpiceLevel.veryHot: 'Very Hot',
  };

  static const Map<SpiceLevel, String> spiceLevelEmoji = {
    SpiceLevel.mild: '🟢',
    SpiceLevel.medium: '🟡',
    SpiceLevel.hot: '🟠',
    SpiceLevel.veryHot: '🔴',
  };

  static List<Dish> getAllDishes() {
    return [
      // Rice Dishes
      const Dish(
        name: 'Rice and Curry',
        description: 'The national dish - steamed rice served with multiple curries, sambols, and papadums. A complete meal with vegetables, meat or fish, and lentils.',
        category: DishCategory.rice,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Rice', 'Curry', 'Sambol', 'Papadum'],
        bestPlaceToTry: 'Any local restaurant',
        culturalNote: 'Typically eaten for lunch. Mix everything together on your plate!',
      ),
      const Dish(
        name: 'Biryani',
        description: 'Fragrant spiced rice cooked with meat (chicken, mutton, or beef) and aromatic spices. Often served with raita and curry.',
        category: DishCategory.rice,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Basmati rice', 'Meat', 'Spices', 'Saffron'],
        bestPlaceToTry: 'Colombo Muslim restaurants',
      ),
      const Dish(
        name: 'Fried Rice',
        description: 'Sri Lankan style fried rice with vegetables, egg, and choice of chicken, seafood or vegetables. Mildly spiced.',
        category: DishCategory.rice,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice', 'Vegetables', 'Egg', 'Soy sauce'],
        isVegetarian: true,
      ),
      const Dish(
        name: 'Lamprais',
        description: 'Dutch Burgher specialty - rice cooked in stock, served with frikkadels (meatballs), blachan, eggplant curry, and wrapped in banana leaf.',
        category: DishCategory.rice,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Rice', 'Meatballs', 'Curry', 'Banana leaf'],
        culturalNote: 'Influenced by Dutch colonial period',
      ),

      // Curries
      const Dish(
        name: 'Dhal Curry',
        description: 'Red lentils cooked with coconut milk, turmeric, and spices. A staple in every rice and curry meal.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Red lentils', 'Coconut milk', 'Turmeric', 'Curry leaves'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Fish Curry',
        description: 'Fresh fish cooked in a spicy coconut gravy with tamarind, goraka (garcinia), and aromatic spices.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.hot,
        mainIngredients: ['Fish', 'Coconut milk', 'Tamarind', 'Chili'],
        bestPlaceToTry: 'Coastal areas (Negombo, Galle)',
      ),
      const Dish(
        name: 'Chicken Curry',
        description: 'Tender chicken pieces in a rich, spicy coconut gravy. Available in white (mild) or red (spicy) varieties.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Chicken', 'Coconut milk', 'Curry powder', 'Onions'],
      ),
      const Dish(
        name: 'Parippu (Lentil Curry)',
        description: 'Simple yet flavorful red lentil curry tempered with mustard seeds, curry leaves, and dried chilies.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Red lentils', 'Turmeric', 'Mustard seeds', 'Curry leaves'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Pol Sambol',
        description: 'Spicy coconut relish made with fresh coconut, chili, onions, and lime juice. Essential condiment.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.hot,
        mainIngredients: ['Fresh coconut', 'Chili', 'Onions', 'Lime'],
        isVegetarian: true,
        isVegan: true,
        culturalNote: 'Traditionally made fresh daily',
      ),
      const Dish(
        name: 'Brinjal Moju',
        description: 'Sweet and sour eggplant pickle with mustard seeds, vinegar, and sugar. A popular side dish.',
        category: DishCategory.curry,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Eggplant', 'Vinegar', 'Sugar', 'Mustard'],
        isVegetarian: true,
        isVegan: true,
      ),

      // Breads
      const Dish(
        name: 'Roti',
        description: 'Thin, unleavened flatbread made from wheat flour and coconut. Often served with curry or dhal.',
        category: DishCategory.bread,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Wheat flour', 'Coconut', 'Water'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Kottu Roti',
        description: 'Chopped roti stir-fried with vegetables, eggs, and meat. Made with rhythmic chopping sounds on a griddle.',
        category: DishCategory.bread,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Chopped roti', 'Vegetables', 'Egg', 'Meat'],
        bestPlaceToTry: 'Street food stalls',
        culturalNote: 'Listen for the distinctive "chop chop" sound!',
      ),
      const Dish(
        name: 'Pol Roti',
        description: 'Coconut roti - flatbread mixed with scraped coconut. Commonly eaten for breakfast with sambol.',
        category: DishCategory.bread,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Wheat flour', 'Coconut', 'Onions'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Paratha',
        description: 'Flaky, layered flatbread. Often served with curry or as a sweet version with sugar.',
        category: DishCategory.bread,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Wheat flour', 'Oil', 'Water'],
        isVegetarian: true,
      ),

      // Breakfast
      const Dish(
        name: 'Hoppers (Appa)',
        description: 'Bowl-shaped pancakes made from fermented rice flour and coconut milk. Can be plain or with an egg.',
        category: DishCategory.breakfast,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice flour', 'Coconut milk', 'Yeast'],
        isVegetarian: true,
        culturalNote: 'Crispy edges, soft center. Eat with lunu miris!',
      ),
      const Dish(
        name: 'String Hoppers (Idiyappam)',
        description: 'Steamed rice noodle nests. Served with curry, sambol, or coconut milk and sugar.',
        category: DishCategory.breakfast,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice flour', 'Water'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Kiribath',
        description: 'Milk rice - rice cooked in coconut milk, cut into diamond shapes. Eaten with lunu miris (chili onion sambol).',
        category: DishCategory.breakfast,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice', 'Coconut milk'],
        isVegetarian: true,
        isVegan: true,
        culturalNote: 'Traditional for New Year and special occasions',
      ),
      const Dish(
        name: 'Pittu',
        description: 'Steamed cylinders of ground rice layered with coconut. Served with curry or banana and coconut milk.',
        category: DishCategory.breakfast,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice flour', 'Coconut', 'Water'],
        isVegetarian: true,
        isVegan: true,
      ),

      // Snacks
      const Dish(
        name: 'Vadai',
        description: 'Deep-fried savory doughnut made from urad dhal. Crispy outside, soft inside.',
        category: DishCategory.snacks,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Urad dhal', 'Onions', 'Curry leaves', 'Chili'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Isso Vadai',
        description: 'Crispy prawn fritters. Popular tea-time snack.',
        category: DishCategory.snacks,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Prawns', 'Chickpea flour', 'Spices'],
      ),
      const Dish(
        name: 'Samosa',
        description: 'Triangular pastry filled with spiced potatoes, peas, and sometimes meat. Fried until golden.',
        category: DishCategory.snacks,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Pastry', 'Potato', 'Peas', 'Spices'],
        isVegetarian: true,
      ),
      const Dish(
        name: 'Patties',
        description: 'Flaky pastry filled with spiced fish, chicken, or vegetables.',
        category: DishCategory.snacks,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Puff pastry', 'Fish/Chicken', 'Spices'],
      ),
      const Dish(
        name: 'Kavum',
        description: 'Deep-fried sweet made from rice flour and treacle, shaped like a flower. Traditional New Year sweet.',
        category: DishCategory.snacks,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice flour', 'Treacle', 'Oil'],
        isVegetarian: true,
        isVegan: true,
      ),

      // Seafood
      const Dish(
        name: 'Ambul Thiyal',
        description: 'Sour fish curry from Southern Sri Lanka. Tuna cooked with goraka (garcinia) - dry and intensely flavored.',
        category: DishCategory.seafood,
        spiceLevel: SpiceLevel.hot,
        mainIngredients: ['Tuna', 'Goraka', 'Black pepper', 'Curry leaves'],
        bestPlaceToTry: 'Galle and Southern coast',
      ),
      const Dish(
        name: 'Cuttlefish Curry',
        description: 'Tender cuttlefish in rich, dark curry with tamarind and spices.',
        category: DishCategory.seafood,
        spiceLevel: SpiceLevel.hot,
        mainIngredients: ['Cuttlefish', 'Tamarind', 'Curry powder', 'Coconut milk'],
        bestPlaceToTry: 'Negombo',
      ),
      const Dish(
        name: 'Prawn Curry',
        description: 'Large prawns cooked in spicy coconut gravy. A coastal delicacy.',
        category: DishCategory.seafood,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Prawns', 'Coconut milk', 'Curry leaves', 'Spices'],
      ),
      const Dish(
        name: 'Crab Curry',
        description: 'Fresh crab in rich, spicy curry sauce. Best eaten with your hands!',
        category: DishCategory.seafood,
        spiceLevel: SpiceLevel.hot,
        mainIngredients: ['Crab', 'Coconut milk', 'Tamarind', 'Chili'],
        culturalNote: 'Messy but delicious - use your fingers!',
      ),

      // Desserts
      const Dish(
        name: 'Watalappan',
        description: 'Steamed coconut custard pudding made with jaggery, cashews, and cardamom. A must-try dessert.',
        category: DishCategory.desserts,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Coconut milk', 'Jaggery', 'Cashews', 'Cardamom'],
        isVegetarian: true,
      ),
      const Dish(
        name: 'Curd and Honey',
        description: 'Buffalo curd (thick yogurt) topped with kithul treacle or honey. Simple and delicious.',
        category: DishCategory.desserts,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Buffalo curd', 'Kithul treacle', 'Cashews'],
        isVegetarian: true,
        bestPlaceToTry: 'Anywhere, especially in clay pots',
      ),
      const Dish(
        name: 'Kokis',
        description: 'Crispy, flower-shaped deep-fried cookies. Traditional for New Year.',
        category: DishCategory.desserts,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Rice flour', 'Coconut milk', 'Sugar'],
        isVegetarian: true,
      ),
      const Dish(
        name: 'Kalu Dodol',
        description: 'Dense, dark toffee-like sweet made from coconut milk, jaggery, and rice flour. Very rich.',
        category: DishCategory.desserts,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Coconut milk', 'Jaggery', 'Rice flour', 'Cashews'],
        isVegetarian: true,
      ),

      // Drinks
      const Dish(
        name: 'Ceylon Tea',
        description: 'World-famous black tea from Sri Lankan highlands. Best enjoyed plain or with milk.',
        category: DishCategory.drinks,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Tea leaves'],
        isVegetarian: true,
        isVegan: true,
        culturalNote: 'Visit a tea plantation in Nuwara Eliya!',
      ),
      const Dish(
        name: 'King Coconut Water',
        description: 'Fresh water from orange king coconuts. Sweet, refreshing, and full of electrolytes.',
        category: DishCategory.drinks,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['King coconut'],
        isVegetarian: true,
        isVegan: true,
        culturalNote: 'The orange ones are sweeter than green coconuts',
      ),
      const Dish(
        name: 'Faluda',
        description: 'Sweet milk drink with jelly, basil seeds, and ice cream. Popular dessert drink.',
        category: DishCategory.drinks,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Milk', 'Jelly', 'Basil seeds', 'Ice cream'],
        isVegetarian: true,
      ),
      const Dish(
        name: 'Arrack',
        description: 'Traditional Sri Lankan spirit distilled from coconut flowers. Strong and distinctive.',
        category: DishCategory.drinks,
        spiceLevel: SpiceLevel.mild,
        mainIngredients: ['Coconut flower sap'],
        culturalNote: 'National spirit of Sri Lanka - drink responsibly!',
      ),

      // Street Food
      const Dish(
        name: 'Isso Rolls',
        description: 'Prawn rolls - crispy fried spring rolls filled with spiced prawns and vegetables.',
        category: DishCategory.streetFood,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Prawns', 'Vegetables', 'Pastry'],
      ),
      const Dish(
        name: 'Wade',
        description: 'Fried lentil cakes. Crispy, savory snack sold by street vendors.',
        category: DishCategory.streetFood,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Urad dhal', 'Onions', 'Chili'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Bonda',
        description: 'Deep-fried potato balls coated in chickpea batter. Popular evening snack.',
        category: DishCategory.streetFood,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Potato', 'Chickpea flour', 'Spices'],
        isVegetarian: true,
        isVegan: true,
      ),
      const Dish(
        name: 'Egg Roti',
        description: 'Thin flatbread with an egg cooked on top, often with vegetables and spices.',
        category: DishCategory.streetFood,
        spiceLevel: SpiceLevel.medium,
        mainIngredients: ['Wheat flour', 'Egg', 'Vegetables'],
        isVegetarian: true,
      ),
    ];
  }

  static List<Dish> getDishesByCategory(DishCategory category) {
    return getAllDishes().where((d) => d.category == category).toList();
  }

  static List<Dish> getVegetarianDishes() {
    return getAllDishes().where((d) => d.isVegetarian).toList();
  }

  static List<Dish> getVeganDishes() {
    return getAllDishes().where((d) => d.isVegan).toList();
  }
}
