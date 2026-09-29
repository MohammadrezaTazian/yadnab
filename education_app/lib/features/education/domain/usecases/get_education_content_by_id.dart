import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/education_content.dart';
import '../repositories/education_content_repository.dart';

class GetEducationContentById
    implements UseCase<EducationContent, int> {
  final EducationContentRepository repository;

  GetEducationContentById(this.repository);

  @override
  Future<Either<Failure, EducationContent>> call(int id) async {
    return await repository.getEducationContentById(id);
  }
}