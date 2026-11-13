import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/password_reset_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/password_reset_state.dart';
import 'auth_cubit_test.dart';

void main() {
  late FakeAuthRepository fakeRepo;
  late PasswordResetCubit cubit;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    cubit = PasswordResetCubit(fakeRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('PasswordResetCubit Tests', () {
    test('initial state is email step with no token and zero countdown', () {
      expect(cubit.state.step, PasswordResetStep.email);
      expect(cubit.state.email, '');
      expect(cubit.state.resetToken, isNull);
      expect(cubit.state.resendCountdown, 0);
      expect(cubit.state.wrongAttempts, 0);
    });

    test('sendResetCode validates empty email', () async {
      await cubit.sendResetCode('   ');
      expect(cubit.state.errorMessage, isNotNull);
      expect(cubit.state.step, PasswordResetStep.email);
    });

    test('sendResetCode moves to otp step and starts countdown on success', () async {
      await cubit.sendResetCode('user@example.com');
      expect(cubit.state.step, PasswordResetStep.otp);
      expect(cubit.state.email, 'user@example.com');
      expect(cubit.state.resendCountdown, 60);
      expect(cubit.state.wrongAttempts, 0);
    });

    test('sendResetCode handles 429 rate limit gracefully', () async {
      fakeRepo.exceptionToThrow = const AppException(
        message: 'Rate limit',
        statusCode: 429,
        errorCode: 'RESEND_OTP_RATE_LIMIT',
      );

      await cubit.sendResetCode('user@example.com');
      expect(cubit.state.errorMessage, contains('chờ hết thời gian'));
      expect(cubit.state.resendCountdown, 60);
    });

    test('verifyResetCode validates 8-char length', () async {
      await cubit.sendResetCode('user@example.com');
      await cubit.verifyResetCode('1234');

      expect(cubit.state.errorMessage, contains('đúng 8 ký tự'));
      expect(cubit.state.step, PasswordResetStep.otp);
    });

    test('verifyResetCode moves to newPassword step on valid code', () async {
      await cubit.sendResetCode('user@example.com');
      await cubit.verifyResetCode('47285BAF');

      expect(cubit.state.step, PasswordResetStep.newPassword);
      expect(cubit.state.resetToken, 'mock_reset_token_32_bytes_random');
      expect(cubit.state.wrongAttempts, 0);
    });

    test('verifyResetCode increments wrongAttempts on error', () async {
      await cubit.sendResetCode('user@example.com');

      fakeRepo.exceptionToThrow = const AppException(
        message: 'Mã không đúng',
        errorCode: 'INVALID_OTP',
      );

      await cubit.verifyResetCode('WRONG123');

      expect(cubit.state.step, PasswordResetStep.otp);
      expect(cubit.state.wrongAttempts, 1);
      expect(cubit.state.errorMessage, 'Mã không đúng');
    });

    test('verifyResetCode locks and returns to email step on RESET_CODE_LOCKED or 5 attempts', () async {
      await cubit.sendResetCode('user@example.com');

      fakeRepo.exceptionToThrow = const AppException(
        message: 'Mã đã bị khóa',
        errorCode: 'RESET_CODE_LOCKED',
      );

      await cubit.verifyResetCode('WRONG123');

      expect(cubit.state.step, PasswordResetStep.email);
      expect(cubit.state.isLocked, isTrue);
      expect(cubit.state.errorMessage, contains('bị khóa do nhập sai quá 5 lần'));
    });

    test('setNewPassword validates minimum length 6 and password match', () async {
      await cubit.sendResetCode('user@example.com');
      await cubit.verifyResetCode('47285BAF');

      // Less than 6 chars
      await cubit.setNewPassword(
        newPassword: '12345',
        confirmPassword: '12345',
      );
      expect(cubit.state.errorMessage, contains('tối thiểu 6 ký tự'));

      // Mismatched
      await cubit.setNewPassword(
        newPassword: 'Password123',
        confirmPassword: 'Password456',
      );
      expect(cubit.state.errorMessage, contains('không khớp'));
    });

    test('setNewPassword succeeds and wipes resetToken from state', () async {
      await cubit.sendResetCode('user@example.com');
      await cubit.verifyResetCode('47285BAF');

      await cubit.setNewPassword(
        newPassword: 'NewPassword123',
        confirmPassword: 'NewPassword123',
      );

      expect(cubit.state.step, PasswordResetStep.success);
      expect(cubit.state.resetToken, isNull);
    });

    test('setNewPassword on INVALID_RESET_TOKEN resets to email step', () async {
      await cubit.sendResetCode('user@example.com');
      await cubit.verifyResetCode('47285BAF');

      fakeRepo.exceptionToThrow = const AppException(
        message: 'Token expired',
        errorCode: 'INVALID_RESET_TOKEN',
      );

      await cubit.setNewPassword(
        newPassword: 'NewPassword123',
        confirmPassword: 'NewPassword123',
      );

      expect(cubit.state.step, PasswordResetStep.email);
      expect(cubit.state.resetToken, isNull);
      expect(cubit.state.errorMessage, contains('hết hạn (5 phút)'));
    });

    test('backToEmailStep switches to email step', () async {
      await cubit.sendResetCode('user@example.com');
      expect(cubit.state.step, PasswordResetStep.otp);

      cubit.backToEmailStep();
      expect(cubit.state.step, PasswordResetStep.email);
    });
  });
}
