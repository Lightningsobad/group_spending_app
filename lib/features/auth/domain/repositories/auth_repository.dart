import 'dart:io';
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

  Future<AuthTokensEntity?> signInWithGoogle({String? fcmToken});

  Future<AuthTokensEntity> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<bool> isAuthenticated();

  Future<String?> getSavedAccessToken();

  Future<UserEntity> getCurrentUser();

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<UserEntity> updateProfile({
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

  Future<void> forgotPassword({required String email});

  Future<String> verifyResetPassword({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
