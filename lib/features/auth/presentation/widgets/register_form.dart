import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Họ và tên',
          controller: nameController,
          hintText: 'Nguyễn Nhật Minh',
          prefixIcon: const Icon(
            LucideIcons.user,
            size: 19,
            color: AppColors.textMuted,
          ),
          errorText: fieldErrors?['fullName'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Địa chỉ Email',
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
          label: 'Số điện thoại',
          optionalTag: '(Không bắt buộc / Tùy chọn)',
          controller: phoneController,
          hintText: 'VD: 0912 345 678',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(
            LucideIcons.phone,
            size: 19,
            color: AppColors.textMuted,
          ),
          errorText: fieldErrors?['phone'],
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Mật khẩu',
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
          text: 'Tạo tài khoản mới',
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
