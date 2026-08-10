import 'package:education_app/features/topics/domain/entities/topic.dart';
import 'package:education_app/features/topics/domain/repositories/topic_repository.dart';

class GetTopics {
  final TopicRepository repository;

  GetTopics(this.repository);

  Future<List<Topic>> call(int packageId) async {
    return await repository.getTopicsByPackage(packageId);
  }
}
