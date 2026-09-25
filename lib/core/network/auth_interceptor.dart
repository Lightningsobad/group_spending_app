import 'dart:async';
import 'package:dio/dio.dart';
import '../session/session_coordinator.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final SessionCoordinator? sessionCoordinator;
  final void Function()? onSessionExpired;
  final Dio _refreshDio;

  static const _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/verify-email',
    '/auth/resend-verification',
    '/auth/refresh-token',
  };

  Future<String?>? _refreshFuture;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    this.sessionCoordinator,
    this.onSessionExpired,
    Dio? refreshDio,
  }) : _refreshDio =
           refreshDio ??
           Dio(
             BaseOptions(
               baseUrl: dio.options.baseUrl,
               connectTimeout: dio.options.connectTimeout,
               receiveTimeout: dio.options.receiveTimeout,
               headers: {
                 'Content-Type': 'application/json; charset=UTF-8',
                 'Accept': 'application/json',
               },
             ),
           );

  bool _isPublic(String path) {
    return _publicPaths.any((p) => path.endsWith(p) || path == p);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final isAuthError = statusCode == 401;
    final isPublic = _isPublic(err.requestOptions.path);
    final isAlreadyRetried = err.requestOptions.extra['is_retry'] == true;

    // Không retry nếu là request public, hoặc đã retry 1 lần, hoặc không phải lỗi 401
    if (!isAuthError || isPublic || isAlreadyRetried) {
      return handler.next(err);
    }

    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      return handler.next(err);
    }

    try {
      // Single-flight refresh token: nhiều request 401 cùng await 1 Future duy nhất
      _refreshFuture ??= _executeRefreshToken(refreshToken);
      final newAccessToken = await _refreshFuture;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        options.extra['is_retry'] = true;

        final retryResponse = await dio.fetch(options);
        return handler.resolve(retryResponse);
      }
    } on DioException catch (refreshErr) {
      final refreshStatus = refreshErr.response?.statusCode;
      // Chỉ hủy phiên khi server xác nhận token không hợp lệ (401/403)
      if (refreshStatus == 401 || refreshStatus == 403) {
        await _expireSession();
      }
      // Với lỗi timeout/mạng/5xx, giữ nguyên token trong storage (AUTH-07)
    } catch (_) {
      // Lỗi parse hoặc ngoại lệ khác, không xóa token
    } finally {
      _refreshFuture = null;
    }

    return handler.next(err);
  }

  Future<String?> _executeRefreshToken(String refreshToken) async {
    final response = await _refreshDio.post(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] is Map<String, dynamic>) {
        final data = body['data'] as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken =
            (data['refreshToken'] as String?) ?? refreshToken;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          return newAccessToken;
        }
      }
    }
    return null;
  }

  Future<void> _expireSession() async {
    if (sessionCoordinator != null) {
      await sessionCoordinator!.clearSession(isExpired: true);
    } else {
      await tokenStorage.clearTokens();
    }
    onSessionExpired?.call();
  }
}
