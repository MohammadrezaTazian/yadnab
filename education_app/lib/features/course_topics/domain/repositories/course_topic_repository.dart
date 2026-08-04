import 'package:education_app/features/course_topics/domain/entities/course_topic.dart';

abstract class CourseTopicRepository {
  Future<CourseTopic> getTopicsByPackage(int packageId);
}

