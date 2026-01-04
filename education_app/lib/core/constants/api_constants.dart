import 'package:education_app/core/config/config_service.dart';

class ApiConstants {
  static String get baseUrl => ConfigService().apiBaseUrl;
  
  // Auth endpoints
  static const String sendOtp = '/Auth/send-otp';
  static const String login = '/Auth/login';
  static const String refreshToken = '/Auth/refresh-token';
  
  // Products endpoints
  static const String products = '/Products';
  
  // Settings endpoints
  static const String settings = '/Settings';
  static const String theme = '/Settings/theme';
  static const String language = '/Settings/language';
  static const String fontSize = '/Settings/fontsize';
  
  // User endpoints
  static const String userProfile = '/User/profile';
  static const String updateProfile = '/User/profile';
  static const String grades = '/User/grades';
}
