import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  Timer? _countdownTimer;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrors: true));
    try {
      final result = await _repository.login(email: email, password: password);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          currentUser: result.user,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      if (e.errorCode == 'ACCOUNT_NOT_VERIFIED' ||
          (e.statusCode == 403 &&
              (e.message.contains('chưa được xác thực') ||
                  e.message.toLowerCase().contains('not verified')))) {
        startResendCountdown(60);
        emit(
          state.copyWith(
            status: AuthStatus.needsVerification,
            pendingEmail: email,
            errorMessage: e.message,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng nhập không thành công. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrors: true));
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      startResendCountdown(60);
      emit(
        state.copyWith(
          status: AuthStatus.needsVerification,
          pendingEmail: email,
          currentUser: user,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Đăng ký không thành công. Vui lòng thử lại.',
        ),
      );
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrors: true));
    try {
      final result = await _repository.verifyEmailOtp(email: email, otp: otp);
      cancelCountdown();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          currentUser: result.user,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Mã xác thực không hợp lệ hoặc đã xảy ra lỗi.',
        ),
      );
    }
  }

  Future<void> resendOtp({required String email}) async {
    if (state.resendCountdown > 0) return;

    emit(state.copyWith(clearErrors: true));
    try {
      await _repository.resendVerificationOtp(email: email);
      startResendCountdown(60);
    } on AppException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Không thể gửi lại mã xác thực. Vui lòng thử lại sau.',
        ),
      );
    }
  }

  void startResendCountdown(int seconds) {
    _countdownTimer?.cancel();
    emit(state.copyWith(resendCountdown: seconds, clearErrors: true));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.resendCountdown;
      if (current <= 1) {
        timer.cancel();
        emit(state.copyWith(resendCountdown: 0, clearErrors: true));
      } else {
        emit(state.copyWith(resendCountdown: current - 1, clearErrors: true));
      }
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    emit(state.copyWith(resendCountdown: 0));
  }

  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    cancelCountdown();
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void setPendingEmail(String email) {
    emit(state.copyWith(pendingEmail: email));
  }

  void resetAuthStatus() {
    cancelCountdown();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        pendingEmail: null,
        clearErrors: true,
      ),
    );
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
