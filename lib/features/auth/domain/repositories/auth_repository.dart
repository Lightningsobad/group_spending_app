import '../entities/auth_tokens_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  Future<AuthTokensEntity> verifyEmailOtp({
    required String email,
    required String otp,
  });

  Future<void> resendVerificationOtp({required String email});

  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  });

  Future<AuthTokensEntity> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<String?> getSavedAccessToken();
}
