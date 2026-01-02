import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/education_content.dart';
import '../repositories/education_content_repository.dart';

class GetEducationContentsByTopic implements UseCase<List<EducationContent>, int> {
  final EducationContentRepository repository;

  GetEducationContentsByTopic(this.repository);

  @override
  Future<Either<Failure, List<EducationContent>>> call(int topicItemId) async {
    return await repository.getEducationContentsByTopic(topicItemId);
  }
}
