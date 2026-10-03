import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/auth/domain/entities/auth_tokens_entity.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';

class FakeAuthRepository implements AuthRepository {
  bool isAuth = false;
  AppException? exceptionToThrow;
  final dynamic sessionCoordinator;

  FakeAuthRepository({this.sessionCoordinator});

  final sampleUser = const UserEntity(
    id: 1,
    email: 'test@example.com',
    fullName: 'Test User',
    role: 'ROLE_USER',
    isEmailVerified: true,
  );

  @override
  Future<bool> isAuthenticated() async => isAuth;

  @override
  Future<String?> getSavedAccessToken() async => isAuth ? 'token' : null;

  @override
  Future<AuthTokensEntity> login({
    required String email,
    required String password,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    if (sessionCoordinator != null) {
      await sessionCoordinator.commitTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
        forEpoch: sessionCoordinator.sessionEpoch,
      );
    }
    return AuthTokensEntity(
      accessToken: 'access_123',
      refreshToken: 'refresh_123',
      user: sampleUser,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return UserEntity(
      id: 2,
      email: email,
      fullName: fullName,
      role: 'ROLE_USER',
      isEmailVerified: false,
    );
  }

  @override
  Future<AuthTokensEntity> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return AuthTokensEntity(
      accessToken: 'access_123',
      refreshToken: 'refresh_123',
      user: sampleUser,
    );
  }

  @override
  Future<void> resendVerificationOtp({required String email}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<AuthTokensEntity> refreshToken({required String refreshToken}) async {
    return const AuthTokensEntity(accessToken: 'new_token');
  }

  @override
  Future<void> logout() async {
    isAuth = false;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return sampleUser;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
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
    if (exceptionToThrow != null) throw exceptionToThrow!;
    final updated = sampleUser.copyWith(
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      bankName: bankName,
      bankAccountNumber: bankAccountNumber,
      bankAccountName: bankAccountName,
    );
    return updated;
  }

  @override
  Future<void> updateFcmToken({required String fcmToken}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }

  @override
  Future<String> verifyResetPassword({
    required String email,
    required String code,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return 'mock_reset_token_32_bytes_random';
  }

  @override
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }
}

void main() {
  late FakeAuthRepository fakeRepo;
  late AuthCubit cubit;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    cubit = AuthCubit(fakeRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('AuthCubit Tests', () {
    test('initial state is correct', () {
      expect(cubit.state.status, AuthStatus.initial);
      expect(cubit.state.currentUser, isNull);
    });

    test('checkAuthStatus emits authenticated when token exists', () async {
      fakeRepo.isAuth = true;
      await cubit.checkAuthStatus();
      expect(cubit.state.status, AuthStatus.authenticated);
    });

    test('checkAuthStatus emits unauthenticated when no token', () async {
      fakeRepo.isAuth = false;
      await cubit.checkAuthStatus();
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });

    test('login success emits authenticated', () async {
      await cubit.login(email: 'test@example.com', password: 'password123');
      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.currentUser?.email, 'test@example.com');
    });

    test(
      'login with ACCOUNT_NOT_VERIFIED error emits needsVerification',
      () async {
        fakeRepo.exceptionToThrow = const AppException(
          message: 'Tài khoản chưa được xác thực email.',
          statusCode: 403,
          errorCode: 'ACCOUNT_NOT_VERIFIED',
        );

        await cubit.login(
          email: 'unverified@example.com',
          password: 'password123',
        );

        expect(cubit.state.status, AuthStatus.needsVerification);
        expect(cubit.state.pendingEmail, 'unverified@example.com');
        expect(cubit.state.resendCountdown, 60);
      },
    );

    test('login with invalid credentials emits error', () async {
      fakeRepo.exceptionToThrow = const AppException(
        message: 'Email hoặc mật khẩu không chính xác',
        statusCode: 401,
        errorCode: 'INVALID_CREDENTIALS',
      );

      await cubit.login(email: 'wrong@example.com', password: 'wrong');

      expect(cubit.state.status, AuthStatus.error);
      expect(cubit.state.errorMessage, 'Email hoặc mật khẩu không chính xác');
    });

    test(
      'AUTH-03: 403 forbidden/account locked error emits error and does NOT route to verification',
      () async {
        fakeRepo.exceptionToThrow = const AppException(
          message: 'Tài khoản của bạn đã bị khóa.',
          statusCode: 403,
          errorCode: 'ACCOUNT_LOCKED',
        );

        await cubit.login(email: 'locked@example.com', password: 'password123');

        expect(cubit.state.status, AuthStatus.error);
        expect(cubit.state.errorMessage, 'Tài khoản của bạn đã bị khóa.');
      },
    );

    test('register success emits needsVerification and sets email', () async {
      await cubit.register(
        email: 'newuser@example.com',
        password: 'password123',
        fullName: 'New User',
      );

      expect(cubit.state.status, AuthStatus.needsVerification);
      expect(cubit.state.pendingEmail, 'newuser@example.com');
      expect(cubit.state.resendCountdown, 60);
    });

    test('verifyOtp success emits authenticated', () async {
      await cubit.verifyOtp(email: 'test@example.com', otp: '123456');

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.resendCountdown, 0);
    });

    test('logout emits unauthenticated', () async {
      await cubit.logout();
      expect(cubit.state.status, AuthStatus.unauthenticated);
    });

    test('loadUserProfile updates currentUser', () async {
      await cubit.loadUserProfile();
      expect(cubit.state.currentUser, equals(fakeRepo.sampleUser));
    });
  });
}
