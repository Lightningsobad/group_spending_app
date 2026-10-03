import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import 'otp_input_field.dart';
import 'password_reset_header_icon.dart';

class ForgotPasswordOtpView extends StatefulWidget {
  const ForgotPasswordOtpView({super.key});

  @override
  State<ForgotPasswordOtpView> createState() => _ForgotPasswordOtpViewState();
}

class _ForgotPasswordOtpViewState extends State<ForgotPasswordOtpView> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onVerify() {
    final code = _otpController.text.trim();
    if (code.length == 8) {
      context.read<PasswordResetCubit>().verifyResetCode(code);
    }
  }

  void _onResend() {
    context.read<PasswordResetCubit>().resendResetCode();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      builder: (context, state) {
        final isCodeComplete = _otpController.text.length == 8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const PasswordResetHeaderIcon(
              icon: LucideIcons.key,
              gradientColors: [Color(0xFF065F46), Color(0xFF047857)],
              iconColor: Colors.white,
              showShield: true,
            ),
            const SizedBox(height: 18),
            Text(
              tr.verifyResetPasswordTitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.black(
                fontSize: 22,
                color: AppColors.textDark,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tr.verifyResetPasswordSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.mail,
                      size: 14,
                      color: AppColors.emeraldForest,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      state.email,
                      style: AppTextStyle.bold(
                        fontSize: 12.5,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        context.read<PasswordResetCubit>().backToEmailStep();
                      },
                      child: const Icon(
                        LucideIcons.pencil,
                        size: 13,
                        color: AppColors.emeraldDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    tr.resetOtpInputLabel,
                    style: AppTextStyle.bold(
                      fontSize: 12,
                      color: AppColors.textSlate800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tr.resetOtpInputHint,
                    textAlign: TextAlign.end,
                    style: AppTextStyle.medium(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OtpInputField(
              controller: _otpController,
              focusNode: _focusNode,
              length: 8,
              isAlphanumeric: true,
              onChanged: () => setState(() {}),
              onCompleted: (_) => _onVerify(),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              text: tr.verifyAndProceedButton,
              isLoading: state.isLoading,
              onPressed: isCodeComplete ? _onVerify : null,
              trailingIcon: const Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: state.resendCountdown > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr.resendCodeIn,
                          style: AppTextStyle.medium(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _formatCountdown(state.resendCountdown),
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: AppColors.emeraldForest,
                            ),
                          ),
                        ),
                      ],
                    )
                  : TextButton(
                      onPressed: _onResend,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.emeraldDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.refreshCw,
                            size: 15,
                            color: AppColors.emeraldDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tr.resendCodeNow,
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}
