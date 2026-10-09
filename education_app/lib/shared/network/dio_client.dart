import 'package:dio/dio.dart';
import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/shared/network/interceptors/auth_interceptor.dart';
import 'package:education_app/shared/network/interceptors/logging_interceptor.dart';
import 'browser_credentials.dart'
    if (dart.library.js_interop) 'browser_credentials_web.dart';

class DioClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    enableBrowserCredentials(_dio);

    _authInterceptor = AuthInterceptor();

    _dio.interceptors.addAll([_authInterceptor, LoggingInterceptor()]);
  }

  set onSessionExpired(void Function()? callback) {
    _authInterceptor.onSessionExpired = callback;
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
