import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('>>> REQUEST [${options.method}] => ${options.path}');
    print('>>> Authorization: ${options.headers['Authorization']}');

    developer.log(
      'REQUEST[${options.method}] => PATH: ${options.path}',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '<<< RESPONSE [${response.statusCode}] => ${response.requestOptions.path}',
    );

    developer.log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '<<< ERROR [${err.response?.statusCode}] => ${err.requestOptions.path}',
    );

    print(
      '<<< ERROR MESSAGE: ${err.message}',
    );

    developer.log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    handler.next(err);
  }
}
