import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/question.dart';
import '../repositories/question_repository.dart';

class GetQuestionsByTopic implements UseCase<List<Question>, int> {
  final QuestionRepository repository;

  GetQuestionsByTopic(this.repository);

  @override
  Future<Either<Failure, List<Question>>> call(int topicItemId) async {
    return await repository.getQuestionsByTopic(topicItemId);
  }
}
