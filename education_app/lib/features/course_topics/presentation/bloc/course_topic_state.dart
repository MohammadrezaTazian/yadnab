import 'package:education_app/features/course_topics/domain/entities/course_topic.dart';
import 'package:equatable/equatable.dart';

abstract class CourseTopicState extends Equatable {
  const CourseTopicState();

  @override
  List<Object> get props => [];
}

class CourseTopicInitial extends CourseTopicState {}

class CourseTopicLoading extends CourseTopicState {}

class CourseTopicLoaded extends CourseTopicState {
  final CourseTopic courseTopic;

  const CourseTopicLoaded(this.courseTopic);

  @override
  List<Object> get props => [courseTopic];
}

class CourseTopicError extends CourseTopicState {
  final String message;

  const CourseTopicError(this.message);

  @override
  List<Object> get props => [message];
}
