import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required this.dio,
    required this.tokenStorage,
    this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final publicPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/verify-email',
      '/auth/resend-verification',
      '/auth/refresh-token',
    ];

    final isPublic = publicPaths.any((path) => options.path.contains(path));
    if (!isPublic) {
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
    final isAuthError = err.response?.statusCode == 401;
    final isRefreshRequest = err.requestOptions.path.contains('/auth/refresh-token');
    final isLoginRequest = err.requestOptions.path.contains('/auth/login');

    if (isAuthError && !isRefreshRequest && !isLoginRequest) {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Call refresh token with a plain Dio instance to prevent infinite loop
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Accept': 'application/json',
              },
            ),
          );

          final response = await refreshDio.post(
            '/auth/refresh-token',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data['success'] == true) {
            final data = response.data['data'];
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = (data['refreshToken'] ?? refreshToken) as String;

            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Retry original request with new token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          // Refresh failed, clear tokens and notify
          await tokenStorage.clearTokens();
          onSessionExpired?.call();
        }
      } else {
        await tokenStorage.clearTokens();
        onSessionExpired?.call();
      }
    }

    return handler.next(err);
  }
}
