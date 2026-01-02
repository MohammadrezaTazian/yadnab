import '../../domain/entities/education_content.dart';


import '../../../quiz/data/models/content_image_model.dart';

class EducationContentModel extends EducationContent {
  const EducationContentModel({
    required super.id,
    required super.topicItemId,
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
      id: json['id'],
      topicItemId: json['topicItemId'],
      title: json['title'],
      contentText: json['contentText'] ?? '',
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] ?? 'Text',
      teacherName: json['teacherName'],
      createdAt: json['createdAt'] ?? '',
      isLiked: json['isLiked'] ?? false,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ContentImageModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicItemId': topicItemId,
      'title': title,
      'contentText': contentText,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'teacherName': teacherName,
      'createdAt': createdAt,
      'images': images.map((e) => (e as ContentImageModel).toJson()).toList(),
    };
  }
}
