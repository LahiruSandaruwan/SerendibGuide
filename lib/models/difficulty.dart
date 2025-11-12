/// Difficulty levels for attractions (primarily for hiking/trekking)
enum Difficulty {
  easy('Easy'),
  moderate('Moderate'),
  challenging('Challenging');

  const Difficulty(this.displayName);

  final String displayName;

  /// Get difficulty from string value
  static Difficulty? fromString(String? value) {
    if (value == null) return null;
    try {
      return Difficulty.values.firstWhere(
        (difficulty) => difficulty.displayName == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all difficulty names as list
  static List<String> getAllDifficulties() {
    return Difficulty.values.map((e) => e.displayName).toList();
  }
}
