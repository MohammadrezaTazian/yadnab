import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/educational_level.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    int? educationalLevelId,
  });
  Future<List<EducationalLevel>> getEducationalLevels();
}

