import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/education_content.dart';

abstract class EducationContentRepository {
  Future<Either<Failure, List<EducationContent>>> getEducationContentsByTopic(int topicItemId);
}
