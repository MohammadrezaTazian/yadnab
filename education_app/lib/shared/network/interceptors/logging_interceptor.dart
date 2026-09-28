import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('>>> REQUEST [${options.method}] => ${options.path}');
    debugPrint('>>> Authorization: ${options.headers['Authorization']}');

    developer.log(
      'REQUEST[${options.method}] => PATH: ${options.path}',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '<<< RESPONSE [${response.statusCode}] => ${response.requestOptions.path}',
    );

    developer.log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '<<< ERROR [${err.response?.statusCode}] => ${err.requestOptions.path}',
    );

    debugPrint(
      '<<< ERROR MESSAGE: ${err.message}',
    );

    developer.log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    handler.next(err);
  }
}
