enum PasswordResetStep {
  email,
  otp,
  newPassword,
  success,
}

class PasswordResetState {
  final PasswordResetStep step;
  final String email;
  final String? resetToken;
  final int resendCountdown;
  final int wrongAttempts;
  final bool isLocked;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;

  const PasswordResetState({
    this.step = PasswordResetStep.email,
    this.email = '',
    this.resetToken,
    this.resendCountdown = 0,
    this.wrongAttempts = 0,
    this.isLocked = false,
    this.isLoading = false,
    this.errorMessage,
    this.fieldErrors,
  });

  bool get isEmailStep => step == PasswordResetStep.email;
  bool get isOtpStep => step == PasswordResetStep.otp;
  bool get isNewPasswordStep => step == PasswordResetStep.newPassword;
  bool get isSuccessStep => step == PasswordResetStep.success;

  PasswordResetState copyWith({
    PasswordResetStep? step,
    String? email,
    String? resetToken,
    int? resendCountdown,
    int? wrongAttempts,
    bool? isLocked,
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    bool clearErrors = false,
    bool clearResetToken = false,
  }) {
    return PasswordResetState(
      step: step ?? this.step,
      email: email ?? this.email,
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
      resendCountdown: resendCountdown ?? this.resendCountdown,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      isLocked: isLocked ?? this.isLocked,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: clearErrors ? null : (fieldErrors ?? this.fieldErrors),
    );
  }
}
