import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

import '../session/session_coordinator.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;
  final SessionCoordinator? sessionCoordinator;
  final void Function()? onSessionExpired;

  ApiClient({
    required this.tokenStorage,
    this.sessionCoordinator,
    this.onSessionExpired,
    Dio? customDio,
    Dio? refreshDio,
  }) {
    dio =
        customDio ??
        Dio(
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

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        tokenStorage: tokenStorage,
        sessionCoordinator: sessionCoordinator,
        onSessionExpired: onSessionExpired,
        refreshDio: refreshDio,
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const AppException(
        message:
            'Kết nối mạng quá hạn. Vui lòng kiểm tra đường truyền và thử lại.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AppException(
        message:
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
      );
    }

    final response = error.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final message =
          (data['message'] as String?) ?? 'Đã xảy ra lỗi không xác định.';
      final errorCode = data['errorCode'] as String?;

      Map<String, String>? fieldErrors;
      if (data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map).map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        );
      }

      return AppException(
        message: message,
        statusCode: response.statusCode,
        errorCode: errorCode,
        fieldErrors: fieldErrors,
      );
    }

    return AppException(
      message:
          error.message ?? 'Đã xảy ra sự cố trong quá trình giao tiếp máy chủ.',
      statusCode: response?.statusCode,
    );
  }
}
