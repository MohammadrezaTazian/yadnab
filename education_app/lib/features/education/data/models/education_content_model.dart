import '../../domain/entities/education_content.dart';


import '../../../quiz/data/models/content_image_model.dart';

class EducationContentModel extends EducationContent {
  const EducationContentModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.contentText,
    super.mediaUrl,
    required super.mediaType,
    super.teacherName,
    required super.createdAt,
    super.isLiked = false,
    required List<ContentImageModel> images,
  }) : super(images: images);

  factory EducationContentModel.fromJson(Map<String, dynamic> json) {
    return EducationContentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      topicId: (json['topicId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      contentText: json['contentText'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String? ?? 'Text',
      teacherName: json['teacherName'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      isLiked: json['isLiked'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e is ContentImageModel
                  ? e
                  : ContentImageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'contentText': contentText,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'teacherName': teacherName,
      'createdAt': createdAt,
      'images': images
          .map((e) => e is ContentImageModel
              ? e.toJson()
              : ContentImageModel(
                  id: e.id,
                  imageUrl: e.imageUrl,
                  displayOrder: e.displayOrder,
                  altText: e.altText,
                  imageTypeId: e.imageTypeId,
                ).toJson())
          .toList(),
      'isLiked': isLiked,
    };
  }
}
