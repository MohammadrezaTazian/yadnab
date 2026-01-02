import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/course_topics/data/models/course_topic_model.dart';
import 'package:education_app/features/course_topics/domain/entities/course_topic.dart';
import 'package:education_app/features/course_topics/domain/repositories/course_topic_repository.dart';

class CourseTopicRepositoryImpl implements CourseTopicRepository {
  final ApiService apiService;

  CourseTopicRepositoryImpl(this.apiService);

  @override
  Future<CourseTopic> getTopicsByCategory(String category) async {
    final response = await apiService.getCourseTopics(category);
    return CourseTopicModel.fromJson(response);
  }
}
