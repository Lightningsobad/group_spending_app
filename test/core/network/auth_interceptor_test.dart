import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/network/auth_interceptor.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';

class StubAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  StubAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Map<String, dynamic> data, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  late TokenStorage tokenStorage;
  late SessionCoordinator sessionCoordinator;
  late Dio dio;
  late Dio refreshDio;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage();
    sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);

    dio = Dio(BaseOptions(baseUrl: 'https://test.api.com'));
    refreshDio = Dio(BaseOptions(baseUrl: 'https://test.api.com'));
  });

  group('AuthInterceptor Tests', () {
    test('Attaches Authorization header to authenticated routes', () async {
      await tokenStorage.saveTokens(
        accessToken: 'my_access_token',
        refreshToken: 'my_refresh_token',
      );

      RequestOptions? capturedOptions;
      dio.httpClientAdapter = StubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({'success': true});
      });

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStorage: tokenStorage,
          sessionCoordinator: sessionCoordinator,
          refreshDio: refreshDio,
        ),
      );

      await dio.get('/users/me');

      expect(
        capturedOptions?.headers['Authorization'],
        'Bearer my_access_token',
      );
    });

    test('Does NOT attach Authorization header to public routes', () async {
      await tokenStorage.saveTokens(
        accessToken: 'my_access_token',
        refreshToken: 'my_refresh_token',
      );

      RequestOptions? capturedOptions;
      dio.httpClientAdapter = StubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({'success': true});
      });

      dio.interceptors.add(
        AuthInterceptor(
          dio: dio,
          tokenStorage: tokenStorage,
          sessionCoordinator: sessionCoordinator,
          refreshDio: refreshDio,
        ),
      );

      await dio.post('/auth/login');

      expect(capturedOptions?.headers['Authorization'], isNull);
    });

    test(
      'AUTH-07: Network timeout during refresh does NOT delete stored tokens',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'stale_access',
          refreshToken: 'valid_refresh',
        );

        dio.httpClientAdapter = StubAdapter((options) async {
          return jsonResponse({'message': 'Unauthorized'}, statusCode: 401);
        });

        refreshDio.httpClientAdapter = StubAdapter((options) async {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          );
        });

        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            tokenStorage: tokenStorage,
            sessionCoordinator: sessionCoordinator,
            refreshDio: refreshDio,
          ),
        );

        try {
          await dio.get('/groups');
        } catch (_) {}

        // Tokens MUST still be in storage (not logged out on network hiccup)
        expect(await tokenStorage.getRefreshToken(), 'valid_refresh');
      },
    );

    test(
      'AUTH-01: Requests with is_retry flag are never retried again (prevents infinite loop/deadlock)',
      () async {
        await tokenStorage.saveTokens(
          accessToken: 'initial_access',
          refreshToken: 'initial_refresh',
        );

        var callCount = 0;
        dio.httpClientAdapter = StubAdapter((options) async {
          callCount++;
          return jsonResponse({'message': 'Unauthorized'}, statusCode: 401);
        });

        refreshDio.httpClientAdapter = StubAdapter((options) async {
          return jsonResponse({
            'success': true,
            'data': {'accessToken': 'new_token', 'refreshToken': 'new_refresh'},
          });
        });

        dio.interceptors.add(
          AuthInterceptor(
            dio: dio,
            tokenStorage: tokenStorage,
            sessionCoordinator: sessionCoordinator,
            refreshDio: refreshDio,
          ),
        );

        try {
          await dio.get('/groups');
        } catch (_) {}

        // Original request (1) + Retry request with new token (2) = 2 calls total, never infinite loop!
        expect(callCount, 2);
      },
    );
  });
}
