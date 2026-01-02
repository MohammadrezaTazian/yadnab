import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/grade.dart';
import 'package:education_app/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<User> call() {
    return repository.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<User> call({
    String? firstName,
    String? lastName,
    String? email,
    String? grade,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      grade: grade,
    );
  }
}

class GetGradesUseCase {
  final ProfileRepository repository;

  GetGradesUseCase(this.repository);

  Future<List<Grade>> call() {
    return repository.getGrades();
  }
}
