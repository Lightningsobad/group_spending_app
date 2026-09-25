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

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
    required this.appPreferences,
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
      await tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );

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
  Future<void> resendVerificationOtp({
    required String email,
  }) async {
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
      await tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken!,
      );

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
  Future<AuthTokensEntity> refreshToken({
    required String refreshToken,
  }) async {
    final response = await remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );

    if (response.accessToken != null) {
      await tokenStorage.saveTokens(
        accessToken: response.accessToken!,
        refreshToken: response.refreshToken ?? refreshToken,
      );
    }

    return response.toEntity();
  }

  @override
  Future<void> logout() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    await remoteDataSource.logout(refreshToken: refreshToken);
    await tokenStorage.clearTokens();
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
}
