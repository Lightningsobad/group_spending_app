import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final AppPreferences appPreferences;
  final SessionCoordinator? sessionCoordinator;
  final Future<String?> Function()? googleIdTokenProvider;
  final Future<void> Function()? googleSignOutHandler;

  static bool _isGoogleSignInInitialized = false;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.appPreferences,
    this.sessionCoordinator,
    this.googleIdTokenProvider,
    this.googleSignOutHandler,
  });

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final userModel = await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return userModel.toEntity();
  }

  @override
  Future<AuthTokensEntity> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await remoteDataSource.verifyEmailOtp(
      email: email,
      otp: otp,
    );

    if (response.accessToken != null && response.refreshToken != null) {
      if (sessionCoordinator != null) {
        await sessionCoordinator!.commitTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
          forEpoch: sessionCoordinator!.sessionEpoch,
        );
      } else {
        await tokenStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }

      if (response.user != null) {
        await appPreferences.saveUserInfo(
          fullName: response.user!.fullName,
          email: response.user!.email,
        );
      }
    }

    return response.toEntity();
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    await remoteDataSource.resendVerificationOtp(email: email);
  }

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    if (response.accessToken != null && response.refreshToken != null) {
      if (sessionCoordinator != null) {
        await sessionCoordinator!.commitTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
          forEpoch: sessionCoordinator!.sessionEpoch,
        );
      } else {
        await tokenStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }

      if (response.user != null) {
        await appPreferences.saveUserInfo(
          fullName: response.user!.fullName,
          email: response.user!.email,
        );
      }
    }

    return response.toEntity();
  }

  @override
  Future<AuthTokensEntity> refreshToken({required String refreshToken}) async {
    final response = await remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );

    if (response.accessToken != null) {
      if (sessionCoordinator != null) {
        await sessionCoordinator!.commitTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? refreshToken,
          forEpoch: sessionCoordinator!.sessionEpoch,
        );
      } else {
        await tokenStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken ?? refreshToken,
        );
      }
    }

    return response.toEntity();
  }

  @override
  Future<AuthTokensEntity?> signInWithGoogle({String? fcmToken}) async {
    final idToken =
        await (googleIdTokenProvider ?? _defaultGoogleIdTokenProvider)();
    if (idToken == null || idToken.isEmpty) {
      return null;
    }

    final response = await remoteDataSource.loginWithGoogle(
      idToken: idToken,
      fcmToken: fcmToken,
    );

    if (response.accessToken != null && response.refreshToken != null) {
      if (sessionCoordinator != null) {
        await sessionCoordinator!.commitTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
          forEpoch: sessionCoordinator!.sessionEpoch,
        );
      } else {
        await tokenStorage.saveTokens(
          accessToken: response.accessToken!,
          refreshToken: response.refreshToken!,
        );
      }

      if (response.user != null) {
        await appPreferences.saveUserInfo(
          fullName: response.user!.fullName,
          email: response.user!.email,
        );
      }
    }

    return response.toEntity();
  }

  Future<String?> _defaultGoogleIdTokenProvider() async {
    if (!_isGoogleSignInInitialized) {
      await GoogleSignIn.instance.initialize(
        serverClientId: AppConfig.googleServerClientId,
        clientId: AppConfig.googleClientId,
      );
      _isGoogleSignInInitialized = true;
    }
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile', 'openid'],
      );
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AppException(
          message: 'Không lấy được mã xác thực ID Token từ Google.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw AppException(
        message: 'Đăng nhập Google thất bại: ${e.description ?? e.code.name}',
      );
    }
  }

  Future<void> _defaultGoogleSignOutHandler() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    try {
      await remoteDataSource.logout(refreshToken: refreshToken);
    } catch (_) {}
    try {
      await (googleSignOutHandler ?? _defaultGoogleSignOutHandler)();
    } catch (_) {}
    if (sessionCoordinator != null) {
      await sessionCoordinator!.clearSession();
    } else {
      await tokenStorage.clearTokens();
    }
    await appPreferences.clearUserInfo();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await tokenStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getSavedAccessToken() async {
    return tokenStorage.getAccessToken();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final userModel = await remoteDataSource.getCurrentUser();
    await appPreferences.saveUserInfo(
      fullName: userModel.fullName,
      email: userModel.email,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await remoteDataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserEntity> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? fcmToken,
    File? avatarFile,
  }) async {
    final userModel = await remoteDataSource.updateProfile(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountName: bankAccountName,
      fcmToken: fcmToken,
      avatarFile: avatarFile,
    );

    await appPreferences.saveUserInfo(
      fullName: userModel.fullName,
      email: userModel.email,
    );

    return userModel.toEntity();
  }

  @override
  Future<void> updateFcmToken({required String fcmToken}) async {
    await remoteDataSource.updateFcmToken(fcmToken: fcmToken);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await remoteDataSource.forgotPassword(email: email);
  }

  @override
  Future<String> verifyResetPassword({
    required String email,
    required String code,
  }) async {
    return await remoteDataSource.verifyResetPassword(
      email: email,
      code: code,
    );
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
    );
  }
}
