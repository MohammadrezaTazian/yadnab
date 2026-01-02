import 'package:dio/dio.dart';
import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';
import 'package:education_app/injection_container.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final prefs = getIt<SharedPreferencesService>();
    final token = prefs.getString(StorageConstants.accessToken);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Handle token refresh logic here
      // For now, just pass the error
    }
    handler.next(err);
  }
}
