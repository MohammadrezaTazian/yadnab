import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/repositories/education_content_repository.dart';
import '../models/education_content_model.dart';

class EducationContentRepositoryImpl implements EducationContentRepository {
  final ApiService apiService;

  EducationContentRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<EducationContent>>> getEducationContentsByTopic(
    int topicId,
  ) async {
    try {
      final response = await apiService.getEducationContentsByTopic(topicId);

      final List<EducationContent> contents =
          (response as List)
              .map((e) => EducationContentModel.fromJson(e))
              .toList();

      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EducationContent>> getEducationContentById(
    int id,
  ) async {
    try {
      final response = await apiService.getEducationContentById(id);

      final EducationContent content =
          EducationContentModel.fromJson(response);

      return Right(content);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}