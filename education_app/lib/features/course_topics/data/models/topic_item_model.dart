import 'package:equatable/equatable.dart';

class TopicItemModel extends Equatable {
  final int id;
  final int courseTopicId;
  final int? parentId; // New
  final String title;
  final String? imageUrl;
  final List<TopicItemModel> children; // New

  const TopicItemModel({
    required this.id,
    required this.courseTopicId,
    this.parentId,
    required this.title,
    this.imageUrl,
    this.children = const [],
  });

  factory TopicItemModel.fromJson(Map<String, dynamic> json) {
    return TopicItemModel(
      id: json['id'],
      courseTopicId: json['courseTopicId'],
      parentId: json['parentId'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      children: json['children'] != null
          ? (json['children'] as List)
              .map((e) => TopicItemModel.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseTopicId': courseTopicId,
      'parentId': parentId,
      'title': title,
      'imageUrl': imageUrl,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, courseTopicId, parentId, title, imageUrl, children];
}
