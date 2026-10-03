import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  final AuthRepository _repository;
  Timer? _countdownTimer;

  PasswordResetCubit(this._repository) : super(const PasswordResetState());

  Future<void> sendResetCode(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Vui lòng nhập địa chỉ email.',
          fieldErrors: {'email': 'Vui lòng nhập địa chỉ email.'},
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrors: true));
    try {
      await _repository.forgotPassword(email: trimmedEmail);
      startResendCountdown(60);
      emit(
        state.copyWith(
          step: PasswordResetStep.otp,
          email: trimmedEmail,
          wrongAttempts: 0,
          isLocked: false,
          isLoading: false,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      if (e.errorCode == 'RESEND_OTP_RATE_LIMIT' || e.statusCode == 429) {
        startResendCountdown(60);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Vui lòng chờ hết thời gian đếm ngược trước khi yêu cầu gửi lại mã.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể gửi yêu cầu đặt lại mật khẩu. Vui lòng thử lại sau.',
        ),
      );
    }
  }

  Future<void> verifyResetCode(String code) async {
    if (state.isLocked) {
      emit(
        state.copyWith(
          step: PasswordResetStep.email,
          errorMessage:
              'Mã xác thực đã bị khóa do nhập sai quá 5 lần. Vui lòng yêu cầu mã mới.',
        ),
      );
      return;
    }

    final trimmedCode = code.trim().toUpperCase();
    if (trimmedCode.length != 8) {
      emit(
        state.copyWith(
          errorMessage: 'Mã xác thực phải gồm đúng 8 ký tự.',
          fieldErrors: {'code': 'Mã xác thực phải gồm đúng 8 ký tự.'},
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrors: true));
    try {
      final resetToken = await _repository.verifyResetPassword(
        email: state.email,
        code: trimmedCode,
      );

      cancelCountdown();
      emit(
        state.copyWith(
          step: PasswordResetStep.newPassword,
          resetToken: resetToken,
          wrongAttempts: 0,
          isLoading: false,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      final newAttempts = state.wrongAttempts + 1;
      final isLocked =
          e.errorCode == 'RESET_CODE_LOCKED' || newAttempts >= 5;

      if (isLocked) {
        cancelCountdown();
        emit(
          state.copyWith(
            step: PasswordResetStep.email,
            wrongAttempts: newAttempts,
            isLocked: true,
            isLoading: false,
            errorMessage:
                'Mã xác thực đã bị khóa do nhập sai quá 5 lần. Vui lòng yêu cầu mã mới.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            wrongAttempts: newAttempts,
            isLoading: false,
            errorMessage: e.message,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Xác thực mã thất bại. Vui lòng kiểm tra lại.',
        ),
      );
    }
  }

  Future<void> resendResetCode() async {
    if (state.resendCountdown > 0) return;

    emit(state.copyWith(isLoading: true, clearErrors: true));
    try {
      await _repository.forgotPassword(email: state.email);
      startResendCountdown(60);
      emit(
        state.copyWith(
          wrongAttempts: 0,
          isLocked: false,
          isLoading: false,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể gửi lại mã xác thực. Vui lòng thử lại sau.',
        ),
      );
    }
  }

  Future<void> setNewPassword({
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword.length < 6) {
      emit(
        state.copyWith(
          errorMessage: 'Mật khẩu phải có tối thiểu 6 ký tự.',
          fieldErrors: {'newPassword': 'Mật khẩu phải có tối thiểu 6 ký tự.'},
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      emit(
        state.copyWith(
          errorMessage: 'Mật khẩu xác nhận không khớp.',
          fieldErrors: {'confirmPassword': 'Mật khẩu xác nhận không khớp.'},
        ),
      );
      return;
    }

    if (state.resetToken == null || state.resetToken!.isEmpty) {
      emit(
        state.copyWith(
          step: PasswordResetStep.email,
          clearResetToken: true,
          errorMessage:
              'Phiên đặt lại mật khẩu đã hết hạn (5 phút). Vui lòng thực hiện lại từ đầu.',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrors: true));
    try {
      await _repository.resetPassword(
        resetToken: state.resetToken!,
        newPassword: newPassword,
      );

      // Successfully reset password. Clean up in-memory token.
      emit(
        state.copyWith(
          step: PasswordResetStep.success,
          clearResetToken: true,
          isLoading: false,
          clearErrors: true,
        ),
      );
    } on AppException catch (e) {
      if (e.errorCode == 'INVALID_RESET_TOKEN') {
        emit(
          state.copyWith(
            step: PasswordResetStep.email,
            clearResetToken: true,
            isLoading: false,
            errorMessage:
                'Phiên đặt lại mật khẩu đã hết hạn (5 phút). Vui lòng thực hiện lại từ đầu.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: e.message,
            fieldErrors: e.fieldErrors,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể đặt lại mật khẩu. Vui lòng thử lại sau.',
        ),
      );
    }
  }

  void backToEmailStep() {
    emit(
      state.copyWith(
        step: PasswordResetStep.email,
        clearErrors: true,
      ),
    );
  }

  void startResendCountdown(int seconds) {
    _countdownTimer?.cancel();
    emit(state.copyWith(resendCountdown: seconds));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state.resendCountdown;
      if (current <= 1) {
        timer.cancel();
        emit(state.copyWith(resendCountdown: 0));
      } else {
        emit(state.copyWith(resendCountdown: current - 1));
      }
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    emit(state.copyWith(resendCountdown: 0));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
