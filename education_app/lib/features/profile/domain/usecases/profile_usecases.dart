import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/educational_level.dart';
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
    int? educationalLevelId,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      educationalLevelId: educationalLevelId,
    );
  }
}

class GetEducationalLevelsUseCase {
  final ProfileRepository repository;

  GetEducationalLevelsUseCase(this.repository);

  Future<List<EducationalLevel>> call() {
    return repository.getEducationalLevels();
  }
}

