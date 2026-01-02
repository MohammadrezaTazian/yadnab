import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/domain/entities/grade.dart';

abstract class ProfileRepository {
  Future<User> getProfile();
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? grade,
  });
  Future<List<Grade>> getGrades();
}
