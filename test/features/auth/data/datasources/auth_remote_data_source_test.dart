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

  group('AuthRemoteDataSource updateProfile & updateFcmToken Tests', () {
    test('updateProfile sends PUT /users/me and deserializes updated user with bank fields', () async {
      RequestOptions? capturedOptions;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({
          'success': true,
          'message': 'Cập nhật thông tin thành công',
          'data': {
            'id': 1,
            'email': 'user@example.com',
            'fullName': 'Nguyễn Văn B',
            'phone': '0987654321',
            'avatarUrl': 'https://res.cloudinary.com/demo/image/upload/user_1.jpg',
            'role': 'USER',
            'isEmailVerified': true,
            'bankName': 'MBBank',
            'bankAccountNumber': '0987654321',
            'bankAccountName': 'NGUYEN VAN B',
            'createdAt': '2026-09-01T10:00:00Z',
          },
        });
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      final user = await dataSource.updateProfile(
        fullName: 'Nguyễn Văn B',
        phone: '0987654321',
        bankName: 'MBBank',
        bankAccountNumber: '0987654321',
        bankAccountName: 'NGUYEN VAN B',
      );

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, 'PUT');
      expect(capturedOptions!.path, '/users/me');
      expect(user.fullName, 'Nguyễn Văn B');
      expect(user.bankName, 'MBBank');
      expect(user.bankAccountNumber, '0987654321');
      expect(user.bankAccountName, 'NGUYEN VAN B');
    });

    test('updateFcmToken sends PUT /users/me/fcm-token with query parameter', () async {
      RequestOptions? capturedOptions;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        return jsonResponse({
          'success': true,
          'message': 'Cập nhật FCM Token thành công',
          'data': null,
        });
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      await dataSource.updateFcmToken(fcmToken: 'fcm_sample_token_123');

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, 'PUT');
      expect(capturedOptions!.path, '/users/me/fcm-token');
      expect(capturedOptions!.queryParameters['fcmToken'], 'fcm_sample_token_123');
    });
  });

  group('AuthRemoteDataSource Password Reset Tests', () {
    test('forgotPassword sends POST /auth/forgot-password with correct payload', () async {
  group('AuthRemoteDataSource loginWithGoogle Tests', () {
    test('loginWithGoogle sends POST /auth/google and parses AuthResponseModel', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Hướng dẫn đặt lại mật khẩu đã được gửi.',
          'data': null,
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      await dataSource.forgotPassword(email: ' User@Example.COM ');

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, 'POST');
      expect(capturedOptions!.path, '/auth/forgot-password');
      expect(capturedData['email'], 'user@example.com');
    });

    test('verifyResetPassword sends POST /auth/verify-reset-password and returns resetToken', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Xác thực mã thành công',
          'data': {
            'resetToken': 'mock_token_abc_123',
            'expiresIn': 300,
          },
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      final token = await dataSource.verifyResetPassword(
        email: ' user@example.com ',
        code: ' 4f9a2b1c ',
      );

      expect(token, 'mock_token_abc_123');
      expect(capturedOptions!.method, 'POST');
      expect(capturedOptions!.path, '/auth/verify-reset-password');
      expect(capturedData['email'], 'user@example.com');
      expect(capturedData['code'], '4F9A2B1C');
    });

    test('resetPassword sends POST /auth/reset-password with token and new password', () async {
      RequestOptions? capturedOptions;
      dynamic capturedData;

      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        capturedOptions = options;
        capturedData = options.data;
        return jsonResponse({
          'success': true,
          'message': 'Đặt lại mật khẩu thành công.',
          'data': null,
        });
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      await dataSource.resetPassword(
        resetToken: 'mock_token_abc_123',
        newPassword: 'MyNewPassword123',
      );

      expect(capturedOptions!.method, 'POST');
      expect(capturedOptions!.path, '/auth/reset-password');
      expect(capturedData['resetToken'], 'mock_token_abc_123');
      expect(capturedData['newPassword'], 'MyNewPassword123');
    });

    test('throws AppException when server returns 400 or 429', () async {
          'message': 'Đăng nhập bằng Google thành công',
          'data': {
            'accessToken': 'google_jwt_access_token',
            'refreshToken': 'google_jwt_refresh_token',
            'tokenType': 'Bearer',
            'user': {
              'id': 15,
              'email': 'user@gmail.com',
              'fullName': 'Nguyễn Văn A',
              'role': 'ROLE_USER',
              'isEmailVerified': true,
            },
          },
          'timestamp': '2026-10-04T00:00:00Z',
        });
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      final response = await dataSource.loginWithGoogle(
        idToken: 'mock_google_id_token_xyz',
        fcmToken: 'mock_fcm_token_123',
      );

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!.method, 'POST');
      expect(capturedOptions!.path, '/auth/google');
      expect(capturedData['idToken'], 'mock_google_id_token_xyz');
      expect(capturedData['fcmToken'], 'mock_fcm_token_123');
      expect(response.accessToken, 'google_jwt_access_token');
      expect(response.refreshToken, 'google_jwt_refresh_token');
      expect(response.user?.email, 'user@gmail.com');
      expect(response.user?.fullName, 'Nguyễn Văn A');
    });

    test('loginWithGoogle throws AppException on 401 INVALID_TOKEN', () async {
      final customDio = Dio(BaseOptions(baseUrl: 'https://api.groupspending.xyz/api/v1'));
      customDio.httpClientAdapter = TestStubAdapter((options) async {
        return jsonResponse({
          'success': false,
          'message': 'Mã đã bị khóa do nhập sai quá 5 lần.',
          'errorCode': 'RESET_CODE_LOCKED',
        }, statusCode: 400);
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, customDio: customDio);
      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      expect(
        () => dataSource.verifyResetPassword(email: 'user@example.com', code: 'WRONG123'),
        throwsA(isA<AppException>().having((e) => e.errorCode, 'errorCode', 'RESET_CODE_LOCKED')),
          'message': 'Mã xác thực Google không hợp lệ hoặc đã hết hạn',
          'errorCode': 'INVALID_TOKEN',
          'errors': null,
        }, statusCode: 401);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        customDio: customDio,
      );

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      expect(
        () => dataSource.loginWithGoogle(idToken: 'invalid_token'),
        throwsA(
          isA<AppException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.errorCode, 'errorCode', 'INVALID_TOKEN')
              .having((e) => e.message, 'message', 'Mã xác thực Google không hợp lệ hoặc đã hết hạn'),
        ),
      );
    });
  });
}
