import 'package:education_app/features/auth/domain/entities/user.dart';
import 'package:education_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:education_app/features/profile/domain/entities/grade.dart';
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
    String? grade,
  }) async {
    return await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      grade: grade,
    );
  }

  @override
  Future<List<Grade>> getGrades() async {
    return await remoteDataSource.getGrades();
  }
}
