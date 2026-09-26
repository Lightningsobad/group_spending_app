import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;
  final Map<String, String>? fieldErrors;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onForgotPassword,
    required this.isLoading,
    this.fieldErrors,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: tr.emailLabel,
          controller: emailController,
          hintText: 'minh.nguyen@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            LucideIcons.mail,
            size: 19,
            color: AppColors.textMuted,
          ),
          errorText: fieldErrors?['email'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: tr.passwordLabel,
          labelTrailing: GestureDetector(
            onTap: onForgotPassword,
            child: Text(
              tr.forgotPassword,
              style: AppTextStyle.semiBold(
                fontSize: 12.5,
                color: AppColors.emeraldForest,
              ),
            ),
          ),
          controller: passwordController,
          hintText: '••••••••',
          isPassword: true,
          prefixIcon: const Icon(
            LucideIcons.lock,
            size: 19,
            color: AppColors.textMuted,
          ),
          errorText: fieldErrors?['password'],
        ),
        const SizedBox(height: 20),
        AppPrimaryButton(
          text: tr.loginButton,
          isLoading: isLoading,
          onPressed: onLogin,
          trailingIcon: const Icon(
            LucideIcons.arrowRight,
            size: 18,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
