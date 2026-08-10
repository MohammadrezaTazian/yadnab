import 'package:education_app/core/services/api_service.dart';
import 'package:education_app/features/topics/data/models/topic_model.dart';
import 'package:education_app/features/topics/domain/entities/topic.dart';
import 'package:education_app/features/topics/domain/repositories/topic_repository.dart';

class TopicRepositoryImpl implements TopicRepository {
  final ApiService apiService;

  TopicRepositoryImpl(this.apiService);

  @override
  Future<List<Topic>> getTopicsByPackage(int packageId) async {
    final response = await apiService.getTopics(packageId);
    if (response is List) {
      return response
          .map((json) => TopicModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
