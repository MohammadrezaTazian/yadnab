import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/features/auth/data/models/user_model.dart';
import 'package:education_app/shared/network/dio_client.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  Future<String> sendOtp(String phoneNumber) async {
    final response = await dioClient.post(
      ApiConstants.sendOtp,
      data: {'phoneNumber': phoneNumber},
    );
    return response.data['otp'] ?? '12345';
  }

  Future<UserModel> verifyOtp(String phoneNumber, String otp) async {
    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'phoneNumber': phoneNumber,
        'otp': otp,
      },
    );
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> refreshToken(String refreshToken) async {
    final response = await dioClient.post(
      ApiConstants.refreshToken,
      data: refreshToken,
    );
    return UserModel.fromJson(response.data);
  }
}
