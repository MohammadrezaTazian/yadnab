import 'package:equatable/equatable.dart';

abstract class CourseTopicEvent extends Equatable {
  const CourseTopicEvent();

  @override
  List<Object> get props => [];
}

class LoadCourseTopics extends CourseTopicEvent {
  final int packageId;

  const LoadCourseTopics(this.packageId);

  @override
  List<Object> get props => [packageId];
}

