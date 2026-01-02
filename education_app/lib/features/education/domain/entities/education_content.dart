import 'package:equatable/equatable.dart';
import '../../../quiz/domain/entities/content_image.dart';

class EducationContent extends Equatable {
  final int id;
  final int topicItemId;
  final String title;
  final String contentText;
  final String? mediaUrl;
  final String mediaType;
  final String? teacherName;
  final String createdAt;
  final bool isLiked;
  final List<ContentImage> images;

  const EducationContent({
    required this.id,
    required this.topicItemId,
    required this.title,
    required this.contentText,
    this.mediaUrl,
    required this.mediaType,
    this.teacherName,
    required this.createdAt,
    this.isLiked = false,
    required this.images,
  });

  EducationContent copyWith({
    int? id,
    int? topicItemId,
    String? title,
    String? contentText,
    String? mediaUrl,
    String? mediaType,
    String? teacherName,
    String? createdAt,
    bool? isLiked,
    List<ContentImage>? images,
  }) {
    return EducationContent(
      id: id ?? this.id,
      topicItemId: topicItemId ?? this.topicItemId,
      title: title ?? this.title,
      contentText: contentText ?? this.contentText,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      teacherName: teacherName ?? this.teacherName,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
        id,
        topicItemId,
        title,
        contentText,
        mediaUrl,
        mediaType,
        teacherName,
        createdAt,
        isLiked,
        images,
      ];
}

