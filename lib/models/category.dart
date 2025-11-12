/// Categories of attractions in Sri Lanka
enum AttractionCategory {
  ancientSites('Ancient Sites'),
  beaches('Beaches'),
  natureWildlife('Nature & Wildlife'),
  hillCountry('Hill Country'),
  cities('Cities'),
  religiousSites('Religious Sites'),
  foodExperiences('Food Experiences'),
  cultureMuseums('Culture & Museums'),
  scenicExperiences('Scenic Experiences');

  const AttractionCategory(this.displayName);

  final String displayName;

  /// Get category from string value
  static AttractionCategory? fromString(String value) {
    return AttractionCategory.values.firstWhere(
      (category) => category.displayName == value,
      orElse: () => AttractionCategory.ancientSites,
    );
  }

  /// Get all category names as list
  static List<String> getAllCategories() {
    return AttractionCategory.values.map((e) => e.displayName).toList();
  }
}
