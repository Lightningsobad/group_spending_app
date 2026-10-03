import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:group_spending_app/features/auth/data/models/auth_response_model.dart';
import 'package:group_spending_app/features/auth/data/models/user_model.dart';
import 'package:group_spending_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  String? lastGoogleIdToken;
  String? lastGoogleFcmToken;
  bool logoutCalled = false;

  final sampleUserModel = const UserModel(
    id: 10,
    email: 'google_user@example.com',
    fullName: 'Google User',
    role: 'ROLE_USER',
    isEmailVerified: true,
  );

  @override
  Future<AuthResponseModel> loginWithGoogle({
    required String idToken,
    String? fcmToken,
  }) async {
    lastGoogleIdToken = idToken;
    lastGoogleFcmToken = fcmToken;
    return AuthResponseModel(
      accessToken: 'access_from_google',
      refreshToken: 'refresh_from_google',
      user: sampleUserModel,
    );
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    logoutCalled = true;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) => throw UnimplementedError();

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) =>
      throw UnimplementedError();

  @override
  Future<AuthResponseModel> verifyEmailOtp({
    required String email,
    required String otp,
  }) => throw UnimplementedError();

  @override
  Future<void> resendVerificationOtp({required String email}) =>
      throw UnimplementedError();

  @override
  Future<UserModel> getCurrentUser() => throw UnimplementedError();

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) => throw UnimplementedError();

  @override
  Future<UserModel> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
    String? bankName,
    String? bankAccountNumber,
    String? bankAccountName,
    String? fcmToken,
    dynamic avatarFile,
  }) => throw UnimplementedError();

  @override
  Future<void> updateFcmToken({required String fcmToken}) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});

  late MockAuthRemoteDataSource mockRemoteDataSource;
  late TokenStorage tokenStorage;
  late AppPreferences appPreferences;
  late SessionCoordinator sessionCoordinator;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    tokenStorage = TokenStorage();
    appPreferences = await AppPreferences.init();
    sessionCoordinator = SessionCoordinator(tokenStorage: tokenStorage);
    mockRemoteDataSource = MockAuthRemoteDataSource();
  });

  group('AuthRepositoryImpl Google Sign-In Tests', () {
    test('signInWithGoogle saves tokens and user preferences on success', () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenStorage: tokenStorage,
        appPreferences: appPreferences,
        sessionCoordinator: sessionCoordinator,
        googleIdTokenProvider: () async => 'valid_google_id_token',
      );

      final result = await repository.signInWithGoogle();

      expect(result, isNotNull);
      expect(result!.accessToken, 'access_from_google');
      expect(result.refreshToken, 'refresh_from_google');
      expect(mockRemoteDataSource.lastGoogleIdToken, 'valid_google_id_token');

      // Check tokens saved
      final savedAccessToken = await tokenStorage.getAccessToken();
      expect(savedAccessToken, 'access_from_google');

      // Check session coordinator state
      expect(sessionCoordinator.isAuthenticated, isTrue);

      // Check user preferences saved
      expect(appPreferences.getUserFullName(), 'Google User');
      expect(appPreferences.getUserEmail(), 'google_user@example.com');
    });

    test('signInWithGoogle returns null when idToken is null (user cancelled)', () async {
      final repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenStorage: tokenStorage,
        appPreferences: appPreferences,
        sessionCoordinator: sessionCoordinator,
        googleIdTokenProvider: () async => null,
      );

      final result = await repository.signInWithGoogle();

      expect(result, isNull);
      expect(mockRemoteDataSource.lastGoogleIdToken, isNull);
      expect(sessionCoordinator.isAuthenticated, isFalse);
    });

    test('logout calls both remote logout and googleSignOutHandler', () async {
      bool googleSignOutCalled = false;

      final repository = AuthRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        tokenStorage: tokenStorage,
        appPreferences: appPreferences,
        sessionCoordinator: sessionCoordinator,
        googleSignOutHandler: () async {
          googleSignOutCalled = true;
        },
      );

      await tokenStorage.saveTokens(
        accessToken: 'some_access_token',
        refreshToken: 'some_refresh_token',
      );

      await repository.logout();

      expect(mockRemoteDataSource.logoutCalled, isTrue);
      expect(googleSignOutCalled, isTrue);
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(sessionCoordinator.isAuthenticated, isFalse);
    });
  });
}
