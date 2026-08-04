import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:education_app/features/profile/domain/entities/educational_level.dart';
import 'package:education_app/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getProfile() async {
    return await remoteDataSource.getProfile();
  }

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    int? educationalLevelId,
  }) async {
    return await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      educationalLevelId: educationalLevelId,
    );
  }

  @override
  Future<List<EducationalLevel>> getEducationalLevels() async {
    return await remoteDataSource.getEducationalLevels();
  }
}

