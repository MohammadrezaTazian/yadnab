import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';
import 'package:education_app/injection_container.dart';
import 'package:flutter/foundation.dart';

class AuthInterceptor extends Interceptor {
  void Function()? onSessionExpired;

  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final prefs = getIt<SharedPreferencesService>();
    final token = prefs.getString(StorageConstants.accessToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    debugPrint('### AUTH: onError STATUS = ${err.response?.statusCode}');
    debugPrint('### AUTH: onError PATH = ${err.requestOptions.path}');

    if (err.response?.statusCode != 401) {
      debugPrint('### AUTH: NOT 401 -> passing error');
      handler.next(err);
      return;
    }

    debugPrint('### AUTH: 401 RECEIVED');

    final isRefreshRequest = err.requestOptions.path.contains(
      ApiConstants.refreshToken,
    );

    if (isRefreshRequest) {
      debugPrint('### AUTH: REFRESH REQUEST ITSELF FAILED -> LOGOUT');
      await _doLogout();
      handler.next(err);
      return;
    }

    debugPrint('### AUTH: NOT REFRESH REQUEST');

    if (_isRefreshing) {
      debugPrint('### AUTH: REFRESH ALREADY IN PROGRESS -> QUEUE REQUEST');

      final pendingRequest = _RetryRequest(err, handler);
      _pendingRequests.add(pendingRequest);
      return;
    }

    _isRefreshing = true;

    try {
      debugPrint('### AUTH: STARTING REFRESH');

      final prefs = getIt<SharedPreferencesService>();

      final storedRefreshToken = prefs.getString(
        StorageConstants.refreshToken,
      );

      debugPrint(
        '### AUTH: REFRESH TOKEN NULL = ${storedRefreshToken == null}',
      );
      debugPrint(
        '### AUTH: REFRESH TOKEN LENGTH = ${storedRefreshToken?.length ?? 0}',
      );
      debugPrint(
        '### AUTH: REFRESH ENDPOINT = [${ApiConstants.refreshToken}]',
      );

      if (storedRefreshToken == null ||
          storedRefreshToken.isEmpty) {
        debugPrint('### AUTH: NO REFRESH TOKEN -> LOGOUT');

        await _doLogout();
        handler.next(err);
        return;
      }

      debugPrint('### AUTH: CALLING REFRESH ENDPOINT');

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final refreshResponse = await refreshDio.post(
        ApiConstants.refreshToken,
        data: jsonEncode(storedRefreshToken),
      );

      debugPrint(
        '### AUTH: REFRESH RESPONSE STATUS = ${refreshResponse.statusCode}',
      );
      debugPrint(
        '### AUTH: REFRESH RESPONSE DATA = ${refreshResponse.data}',
      );

      final newAccessToken =
          refreshResponse.data['accessToken'] as String?;

      final newRefreshToken =
          refreshResponse.data['refreshToken'] as String?;

      debugPrint(
        '### AUTH: NEW ACCESS TOKEN NULL = ${newAccessToken == null}',
      );
      debugPrint(
        '### AUTH: NEW REFRESH TOKEN NULL = ${newRefreshToken == null}',
      );

      if (newAccessToken == null ||
          newAccessToken.isEmpty) {
        debugPrint('### AUTH: INVALID REFRESH RESPONSE -> LOGOUT');

        await _doLogout();
        handler.next(err);
        return;
      }

      debugPrint('### AUTH: SAVING NEW TOKENS');

      await prefs.setString(
        StorageConstants.accessToken,
        newAccessToken,
      );

      if (newRefreshToken != null &&
          newRefreshToken.isNotEmpty) {
        await prefs.setString(
          StorageConstants.refreshToken,
          newRefreshToken,
        );
      }

      debugPrint('### AUTH: TOKENS SAVED');

      debugPrint('### AUTH: RETRYING ORIGINAL REQUEST');

      final retryResponse = await _retryRequest(
        err.requestOptions,
        newAccessToken,
      );

      debugPrint(
        '### AUTH: RETRY RESPONSE STATUS = ${retryResponse.statusCode}',
      );

      handler.resolve(retryResponse);

      for (final pending in _pendingRequests) {
        try {
          debugPrint('### AUTH: RETRYING PENDING REQUEST');

          final response = await _retryRequest(
            pending.error.requestOptions,
            newAccessToken,
          );

          pending.handler.resolve(response);
        } catch (e) {
          debugPrint(
            '### AUTH: PENDING REQUEST RETRY FAILED = $e',
          );

          pending.handler.next(pending.error);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('### AUTH: REFRESH FAILED = $e');

      if (e is DioException) {
        debugPrint(
          '### AUTH: REFRESH ERROR STATUS = ${e.response?.statusCode}',
        );
        debugPrint(
          '### AUTH: REFRESH ERROR DATA = ${e.response?.data}',
        );
      }

      debugPrint('### AUTH: STACK TRACE = $stackTrace');

      await _doLogout();

      handler.next(err);

      for (final pending in _pendingRequests) {
        pending.handler.next(pending.error);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();

      debugPrint('### AUTH: REFRESH PROCESS FINISHED');
    }
  }

  Future<Response> _retryRequest(
    RequestOptions options,
    String token,
  ) async {
    final retryDio = Dio(
      BaseOptions(
        baseUrl: options.baseUrl,
      ),
    );

    return retryDio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<void> _doLogout() async {
    debugPrint('### AUTH: LOGOUT / CLEAR TOKENS');

    final prefs = getIt<SharedPreferencesService>();

    await prefs.remove(StorageConstants.accessToken);
    await prefs.remove(StorageConstants.refreshToken);
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.phoneNumber);

    onSessionExpired?.call();
  }
}

class _RetryRequest {
  final DioException error;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.error, this.handler);
}



