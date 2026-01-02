import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/education_content.dart';
import '../../domain/repositories/education_content_repository.dart';
import '../models/education_content_model.dart'; // Ensure this import exists

class EducationContentRepositoryImpl implements EducationContentRepository {
  final ApiService apiService;

  EducationContentRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<EducationContent>>> getEducationContentsByTopic(int topicItemId) async {
    try {
      final response = await apiService.getEducationContentsByTopic(topicItemId);
      // Assuming apiService returns List<dynamic> or List<EducationContentModel>
      // The ApiService update will be handled separately, but let's assume it returns Models directly or maps
      // If ApiService returns raw JSON data:
       final List<EducationContent> contents = (response as List).map((e) => EducationContentModel.fromJson(e)).toList();
      return Right(contents);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
