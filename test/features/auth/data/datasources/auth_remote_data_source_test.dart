import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/network/api_client.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/auth/data/datasources/auth_remote_data_source.dart';

class TestStubAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;
  TestStubAdapter(this.handler);

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

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    tokenStorage = TokenStorage();
    await tokenStorage.saveTokens(
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );
  });

  group('AuthRemoteDataSource changePassword Tests', () {
    test('changePassword sends POST /users/me/change-password with correct body', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đổi mật khẩu thành công',
          'data': null,
        });
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      await dataSource.changePassword(
        oldPassword: 'myOldPassword123',
        newPassword: 'myNewPassword456',
      );

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, 'POST');
      expect(capturedOptions!.path, '/users/me/change-password');
      expect(capturedData, isA<Map<String, dynamic>>());
      final mapData = capturedData as Map<String, dynamic>;
      expect(mapData['oldPassword'], 'myOldPassword123');
      expect(mapData['newPassword'], 'myNewPassword456');
    });

    test('changePassword maps 400 error response to AppException', () async {
      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        return jsonResponse({
          'success': false,
          'message': 'Mật khẩu cũ không chính xác',
          'data': null,
        }, statusCode: 400);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      expect(
        () => dataSource.changePassword(
          oldPassword: 'wrongPassword',
          newPassword: 'myNewPassword456',
        ),
        throwsA(
          isA<AppException>()
              .having((e) => e.message, 'message', 'Mật khẩu cũ không chính xác')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });
}
