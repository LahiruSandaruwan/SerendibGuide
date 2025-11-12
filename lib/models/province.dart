/// Provinces of Sri Lanka
enum Province {
  western('Western'),
  central('Central'),
  southern('Southern'),
  northern('Northern'),
  eastern('Eastern'),
  northWestern('North Western'),
  northCentral('North Central'),
  uva('Uva'),
  sabaragamuwa('Sabaragamuwa');

  const Province(this.displayName);

  final String displayName;

  /// Get province from string value
  static Province? fromString(String value) {
    return Province.values.firstWhere(
      (province) => province.displayName == value,
      orElse: () => Province.western,
    );
  }

  /// Get all province names as list
  static List<String> getAllProvinces() {
    return Province.values.map((e) => e.displayName).toList();
  }
}
