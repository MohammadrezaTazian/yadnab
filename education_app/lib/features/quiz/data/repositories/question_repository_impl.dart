import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final ApiService apiService;

  QuestionRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<Question>>> getQuestionsByTopic(int topicItemId) async {
    try {
      final response = await apiService.getQuestionsByTopic(topicItemId);
      final List<dynamic> data = response;
      final questions = data.map((json) => QuestionModel.fromJson(json)).toList();
      return Right(questions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
