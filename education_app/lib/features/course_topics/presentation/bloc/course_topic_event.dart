import 'package:equatable/equatable.dart';

abstract class CourseTopicEvent extends Equatable {
  const CourseTopicEvent();

  @override
  List<Object> get props => [];
}

class LoadCourseTopics extends CourseTopicEvent {
  final String category;

  const LoadCourseTopics(this.category);

  @override
  List<Object> get props => [category];
}
