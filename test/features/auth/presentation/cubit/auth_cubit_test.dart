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

    test('login with ACCOUNT_NOT_VERIFIED error emits needsVerification', () async {
      fakeRepo.exceptionToThrow = const AppException(
        message: 'Tài khoản chưa được xác thực email.',
        statusCode: 403,
        errorCode: 'ACCOUNT_NOT_VERIFIED',
      );

      await cubit.login(email: 'unverified@example.com', password: 'password123');

      expect(cubit.state.status, AuthStatus.needsVerification);
      expect(cubit.state.pendingEmail, 'unverified@example.com');
      expect(cubit.state.resendCountdown, 60);
    });

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
  });
}
