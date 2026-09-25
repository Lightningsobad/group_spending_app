import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsVerification,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserEntity? currentUser;
  final String? pendingEmail;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;
  final int resendCountdown;

  const AuthState({
    this.status = AuthStatus.initial,
    this.currentUser,
    this.pendingEmail,
    this.errorMessage,
    this.fieldErrors,
    this.resendCountdown = 0,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get needsVerification => status == AuthStatus.needsVerification;
  bool get hasError => status == AuthStatus.error;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? currentUser,
    String? pendingEmail,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    int? resendCountdown,
    bool clearErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      currentUser: currentUser ?? this.currentUser,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: clearErrors ? null : (fieldErrors ?? this.fieldErrors),
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }
}
