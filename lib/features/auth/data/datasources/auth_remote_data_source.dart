import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<AuthResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<void> resendVerificationOtp({required String email});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    String? fcmToken,
  });

  Future<AuthResponseModel> refreshToken({required String refreshToken});

  Future<void> logout({String? refreshToken});

  Future<UserModel> getCurrentUser();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? fcmToken,
    File? avatarFile,
  });

  Future<void> updateFcmToken({required String fcmToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await _client.post(
      '/auth/register',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'fullName': fullName.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.post(
      '/auth/verify-email',
      data: {'email': email.trim().toLowerCase(), 'otp': otp.trim()},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data, requireTokens: true);
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    await _client.post(
      '/auth/resend-verification',
      data: {'email': email.trim().toLowerCase()},
    );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data, requireTokens: true);
  }

  @override
  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    String? fcmToken,
  }) async {
    final response = await _client.post(
      '/auth/google',
      data: {
        'idToken': idToken,
        if (fcmToken != null && fcmToken.trim().isNotEmpty)
          'fcmToken': fcmToken.trim(),
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data, requireTokens: true);
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    final response = await _client.post(
      '/auth/refresh-token',
      data: {'refreshToken': refreshToken},
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data, requireTokens: true);
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    try {
      await _client.post(
        '/auth/logout',
        data: refreshToken != null ? {'refreshToken': refreshToken} : null,
      );
    } catch (_) {
      // Best-effort logout; ignore network errors on server logout
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _client.get('/users/me');
    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.post(
      '/users/me/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? fcmToken,
    File? avatarFile,
  }) async {
    final profileData = <String, dynamic>{
      'fullName': fullName.trim(),
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (avatarUrl != null && avatarUrl.trim().isNotEmpty)
        'avatarUrl': avatarUrl.trim(),
      if (bankName != null && bankName.trim().isNotEmpty)
        'bankName': bankName.trim(),
      if (bankAccountNumber != null && bankAccountNumber.trim().isNotEmpty)
        'bankAccountNumber': bankAccountNumber.trim(),
      if (bankAccountName != null && bankAccountName.trim().isNotEmpty)
        'bankAccountName': bankAccountName.trim().toUpperCase(),
      if (fcmToken != null && fcmToken.trim().isNotEmpty)
        'fcmToken': fcmToken.trim(),
    };

    final formDataMap = <String, dynamic>{
      'data': MultipartFile.fromString(
        jsonEncode(profileData),
        contentType: DioMediaType('application', 'json'),
      ),
    };

    if (avatarFile != null && await avatarFile.exists()) {
      final fileName = avatarFile.path.split(Platform.isWindows ? '\\' : '/').last;
      final ext = fileName.split('.').last.toLowerCase();
      final mimeSubtype = (ext == 'png') ? 'png' : 'jpeg';
      formDataMap['avatar'] = await MultipartFile.fromFile(
        avatarFile.path,
        filename: fileName,
        contentType: DioMediaType('image', mimeSubtype),
      );
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _client.put(
      '/users/me',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> updateFcmToken({required String fcmToken}) async {
    await _client.put(
      '/users/me/fcm-token',
      queryParameters: {'fcmToken': fcmToken.trim()},
    );
  }
}
