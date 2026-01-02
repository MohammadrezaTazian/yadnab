import 'package:education_app/features/course_topics/domain/entities/course_topic.dart';
import 'package:education_app/features/course_topics/data/models/topic_item_model.dart';

class CourseTopicModel extends CourseTopic {
  const CourseTopicModel({
    required super.id,
    required super.category,
    required super.title,
    required super.topics,
  });

  factory CourseTopicModel.fromJson(Map<String, dynamic> json) {
    return CourseTopicModel(
      id: json['id'],
      category: json['category'],
      title: json['title'] ?? '',
      topics: (json['topics'] as List<dynamic>)
          .map((e) => TopicItemModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'topics': topics.map((e) => e.toJson()).toList(),
    };
  }
}
