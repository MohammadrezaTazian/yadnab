import 'package:education_app/features/topics/domain/entities/topic.dart';

class TopicModel extends Topic {
  const TopicModel({
    required super.id,
    super.parentId,
    required super.title,
    super.imageUrl,
    super.children = const [],
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] as int? ?? 0,
      parentId: json['parentId'] as int?,
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => TopicModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'imageUrl': imageUrl,
      'children': (children.cast<TopicModel>()).map((e) => e.toJson()).toList(),
    };
  }
}
