import 'package:education_app/features/course_topics/domain/entities/course_topic.dart';
import 'package:education_app/features/course_topics/domain/repositories/course_topic_repository.dart';

class GetCourseTopics {
  final CourseTopicRepository repository;

  GetCourseTopics(this.repository);

  Future<CourseTopic> call(String category) async {
    return await repository.getTopicsByCategory(category);
  }
}
