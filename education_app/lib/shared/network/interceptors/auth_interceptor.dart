import 'package:dio/dio.dart';
import 'package:education_app/core/constants/api_constants.dart';
import 'package:education_app/core/constants/storage_constants.dart';
import 'package:education_app/shared/storage/shared_preferences_service.dart';
import 'package:education_app/injection_container.dart';

class AuthInterceptor extends Interceptor {
  // جلوگیری از Refresh Token loop — اگر همزمان چند 401 بیاید فقط یک بار refresh می‌شود
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

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
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // جلوگیری از retry loop — اگر خود درخواست refresh-token هم 401 داد
    final isRefreshRequest =
        err.requestOptions.path.contains(ApiConstants.refreshToken);
    if (isRefreshRequest) {
      await _doLogout();
      handler.next(err);
      return;
    }

    // اگر در حال refresh هستیم، درخواست را در صف نگه می‌داریم
    if (_isRefreshing) {
      final pendingRequest = _RetryRequest(err, handler);
      _pendingRequests.add(pendingRequest);
      return;
    }

    _isRefreshing = true;

    try {
      final prefs = getIt<SharedPreferencesService>();
      final storedRefreshToken = prefs.getString(StorageConstants.refreshToken);

      if (storedRefreshToken == null) {
        await _doLogout();
        handler.next(err);
        return;
      }

      // ایجاد یک Dio جدید برای refresh (بدون interceptor تا از loop جلوگیری شود)
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
        data: storedRefreshToken,
      );

      final newAccessToken = refreshResponse.data['accessToken'] as String?;
      final newRefreshToken = refreshResponse.data['refreshToken'] as String?;

      if (newAccessToken == null) {
        await _doLogout();
        handler.next(err);
        return;
      }

      // ذخیره توکن‌های جدید
      await prefs.setString(StorageConstants.accessToken, newAccessToken);
      if (newRefreshToken != null) {
        await prefs.setString(StorageConstants.refreshToken, newRefreshToken);
      }

      // retry درخواست اصلی با توکن جدید
      final retryResponse = await _retryRequest(err.requestOptions, newAccessToken);
      handler.resolve(retryResponse);

      // retry درخواست‌های در صف
      for (final pending in _pendingRequests) {
        try {
          final response = await _retryRequest(
            pending.error.requestOptions,
            newAccessToken,
          );
          pending.handler.resolve(response);
        } catch (e) {
          pending.handler.next(pending.error);
        }
      }
    } catch (_) {
      // Refresh ناموفق بود — logout کن
      await _doLogout();
      handler.next(err);

      for (final pending in _pendingRequests) {
        pending.handler.next(pending.error);
      }
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response> _retryRequest(RequestOptions options, String token) async {
    final retryDio = Dio(
      BaseOptions(baseUrl: options.baseUrl),
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
    final prefs = getIt<SharedPreferencesService>();
    await prefs.remove(StorageConstants.accessToken);
    await prefs.remove(StorageConstants.refreshToken);
    await prefs.remove(StorageConstants.userId);
    await prefs.remove(StorageConstants.phoneNumber);
    // AuthBloc از طریق BlocListener در root widget به AuthUnauthenticated emit می‌کند
    // تنها کافی است token پاک شود؛ UI از طریق stream اطلاع می‌یابد
  }
}

class _RetryRequest {
  final DioException error;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.error, this.handler);
}
