import 'package:education_app/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<String> sendOtp(String phoneNumber);
  Future<User> verifyOtp(String phoneNumber, String otp);
  Future<User> refreshToken(String refreshToken);
  Future<void> logout();
}
