import 'package:dio/dio.dart';
import 'package:education_app/features/auth/data/models/user_model.dart';
import 'package:education_app/features/profile/data/models/grade_model.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';
import 'package:education_app/core/constants/storage_constants.dart';

class ProfileRemoteDataSource {
  final Dio dio;
  final SharedPreferencesService storageService;

  ProfileRemoteDataSource(this.dio, this.storageService);

  Future<UserModel> getProfile() async {
    final token = storageService.getString(StorageConstants.accessToken);
    
    final response = await dio.get(
      '/user/profile',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? grade,
  }) async {
    final token = storageService.getString(StorageConstants.accessToken);
    
    final response = await dio.put(
      '/user/profile',
      data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (email != null) 'email': email,
        if (grade != null) 'grade': grade,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return UserModel.fromJson(response.data);
  }

  Future<List<GradeModel>> getGrades() async {
    final token = storageService.getString(StorageConstants.accessToken);
    
    final response = await dio.get(
      '/user/grades',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data as List)
        .map((json) => GradeModel.fromJson(json))
        .toList();
  }
}
