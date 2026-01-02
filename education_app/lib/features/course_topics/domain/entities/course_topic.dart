import 'package:equatable/equatable.dart';
import '../../data/models/topic_item_model.dart';

class CourseTopic extends Equatable {
  final int id;
  final String category;
  final String title;
  final List<TopicItemModel> topics;

  const CourseTopic({
    required this.id,
    required this.category,
    required this.title,
    required this.topics,
  });

  @override
  List<Object?> get props => [id, category, title, topics];
}
