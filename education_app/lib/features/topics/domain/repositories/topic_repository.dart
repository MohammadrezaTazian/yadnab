import 'package:education_app/features/topics/domain/entities/topic.dart';

abstract class TopicRepository {
  Future<List<Topic>> getTopicsByPackage(int packageId);
}
