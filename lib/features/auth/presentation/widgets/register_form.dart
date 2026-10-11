import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class RegisterForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final VoidCallback onRegister;
  final bool isLoading;
  final Map<String, String>? fieldErrors;

  const RegisterForm({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.onRegister,
    required this.isLoading,
    this.fieldErrors,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: tr.fullNameLabel,
          controller: nameController,
          hintText: tr.fullNameHint,
          prefixIcon: Icon(
            LucideIcons.user,
            size: 19,
            color: colors.textMuted,
          ),
          errorText: fieldErrors?['fullName'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: tr.emailLabel,
          controller: emailController,
          hintText: tr.emailHint,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            LucideIcons.mail,
            size: 19,
            color: colors.textMuted,
          ),
          errorText: fieldErrors?['email'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: tr.phoneLabel,
          optionalTag: tr.phoneOptionalTag,
          controller: phoneController,
          hintText: tr.phoneHint,
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(
            LucideIcons.phone,
            size: 19,
            color: colors.textMuted,
          ),
          errorText: fieldErrors?['phone'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: tr.passwordLabel,
          controller: passwordController,
          hintText: '••••••••',
          isPassword: true,
          prefixIcon: Icon(
            LucideIcons.lock,
            size: 19,
            color: colors.textMuted,
          ),
          errorText: fieldErrors?['password'],
        ),
        const SizedBox(height: 20),
        AppPrimaryButton(
          text: tr.registerButton,
          isLoading: isLoading,
          onPressed: onRegister,
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
