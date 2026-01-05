class EntitySearchResult {
  final int id;
  final String title;
  final String? existingImageUrl;

  EntitySearchResult({
    required this.id,
    required this.title,
    this.existingImageUrl,
  });

  factory EntitySearchResult.fromJson(Map<String, dynamic> json) {
    return EntitySearchResult(
      id: json['id'],
      title: json['title'],
      existingImageUrl: json['existingImageUrl'],
    );
  }
}
