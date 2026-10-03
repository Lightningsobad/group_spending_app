import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/password_reset_cubit.dart';
import '../cubit/password_reset_state.dart';
import 'password_reset_header_icon.dart';

class ForgotPasswordNewPasswordView extends StatefulWidget {
  const ForgotPasswordNewPasswordView({super.key});

  @override
  State<ForgotPasswordNewPasswordView> createState() =>
      _ForgotPasswordNewPasswordViewState();
}

class _ForgotPasswordNewPasswordViewState
    extends State<ForgotPasswordNewPasswordView> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    context.read<PasswordResetCubit>().setNewPassword(
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const PasswordResetHeaderIcon(
              icon: LucideIcons.lock,
              gradientColors: [Color(0xFF065F46), Color(0xFF047857)],
              iconColor: Colors.white,
              showShield: true,
            ),
            const SizedBox(height: 18),
            Text(
              tr.setNewPasswordTitle,
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
                tr.setNewPasswordSubtitle,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: tr.newPasswordLabel,
              controller: _newPasswordController,
              hintText: tr.newPasswordHint,
              isPassword: true,
              prefixIcon: const Icon(
                LucideIcons.lock,
                size: 19,
                color: AppColors.textMuted,
              ),
              errorText: state.fieldErrors?['newPassword'],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: tr.confirmNewPasswordLabel,
              controller: _confirmPasswordController,
              hintText: tr.confirmNewPasswordHint,
              isPassword: true,
              prefixIcon: const Icon(
                LucideIcons.lock,
                size: 19,
                color: AppColors.textMuted,
              ),
              errorText: state.fieldErrors?['confirmPassword'],
            ),
            const SizedBox(height: 26),
            AppPrimaryButton(
              text: tr.savePasswordButton,
              isLoading: state.isLoading,
              onPressed: _onSubmit,
              trailingIcon: const Icon(
                LucideIcons.arrowRight,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
