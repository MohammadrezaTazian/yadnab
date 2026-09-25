import '../../domain/entities/content_image.dart';

class ContentImageModel extends ContentImage {
  const ContentImageModel({
    required super.id,
    required super.imageUrl,
    required super.displayOrder,
    super.altText,
    super.imageTypeId = 6,
  });

  factory ContentImageModel.fromJson(Map<String, dynamic> json) {
    return ContentImageModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      altText: json['altText'] as String?,
      imageTypeId: (json['imageTypeId'] as num?)?.toInt() ?? 6,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'altText': altText,
      'imageTypeId': imageTypeId,
    };
  }
}
