import '../../domain/entities/content_image.dart';

class ContentImageModel extends ContentImage {
  const ContentImageModel({
    required super.id,
    required super.imageUrl,
    required super.displayOrder,
    super.altText,
  });

  factory ContentImageModel.fromJson(Map<String, dynamic> json) {
    return ContentImageModel(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      displayOrder: json['displayOrder'] as int,
      altText: json['altText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'altText': altText,
    };
  }
}
