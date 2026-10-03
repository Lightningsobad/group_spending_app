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

class ForgotPasswordEmailView extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordEmailView({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordEmailView> createState() => _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final initialEmail = context.read<PasswordResetCubit>().state.email;
    _emailController = TextEditingController(text: initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final email = _emailController.text.trim();
    context.read<PasswordResetCubit>().sendResetCode(email);
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
              icon: LucideIcons.mail,
              backgroundColor: AppColors.successBg,
              iconColor: AppColors.emeraldForest,
              showShield: false,
            ),
            const SizedBox(height: 20),
            Text(
              tr.forgotPasswordTitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.black(
                fontSize: 24,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                tr.forgotPasswordSubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 28),
            AppTextField(
              label: tr.emailLabel,
              controller: _emailController,
              hintText: 'minh.nguyen@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                LucideIcons.mail,
                size: 19,
                color: AppColors.textMuted,
              ),
              errorText: state.fieldErrors?['email'],
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              text: tr.sendResetCodeButton,
              isLoading: state.isLoading,
              onPressed: _onSubmit,
              trailingIcon: const Icon(
                LucideIcons.arrowRight,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: widget.onBackToLogin,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(
                  tr.backToLogin,
                  style: AppTextStyle.semiBold(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
