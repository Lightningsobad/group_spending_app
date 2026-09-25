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

  Future<void> resendVerificationOtp({
    required String email,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> refreshToken({
    required String refreshToken,
  });

  Future<void> logout({String? refreshToken});
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
      data: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<void> resendVerificationOtp({
    required String email,
  }) async {
    await _client.post(
      '/auth/resend-verification',
      data: {
        'email': email.trim().toLowerCase(),
      },
    );
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<AuthResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _client.post(
      '/auth/refresh-token',
      data: {
        'refreshToken': refreshToken,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
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
}
