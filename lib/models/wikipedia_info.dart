/// Wikipedia article information
class WikipediaInfo {
  final String title;
  final String extract;
  final String? thumbnail;
  final String? description;
  final String url;
  final int? pageId;

  WikipediaInfo({
    required this.title,
    required this.extract,
    this.thumbnail,
    this.description,
    required this.url,
    this.pageId,
  });

  factory WikipediaInfo.fromJson(Map<String, dynamic> json) {
    return WikipediaInfo(
      title: json['title'] as String? ?? '',
      extract: json['extract'] as String? ?? '',
      thumbnail: json['thumbnail']?['source'] as String?,
      description: json['description'] as String?,
      url: json['content_urls']?['desktop']?['page'] as String? ??
           'https://en.wikipedia.org/wiki/${json['title']}',
      pageId: json['pageid'] as int?,
    );
  }

  /// Get short extract (first 200 characters)
  String get shortExtract {
    if (extract.length <= 200) return extract;
    return '${extract.substring(0, 200)}...';
  }

  /// Check if has thumbnail image
  bool get hasThumbnail => thumbnail != null && thumbnail!.isNotEmpty;

  @override
  String toString() => 'WikipediaInfo(title: $title)';
}
