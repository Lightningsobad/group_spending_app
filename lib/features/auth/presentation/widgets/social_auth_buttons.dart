import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleAuth;

  const SocialAuthButtons({super.key, required this.onGoogleAuth});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: onGoogleAuth,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textDark,
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/auth/google.svg', width: 20, height: 20),
              const SizedBox(width: 10),
              Text(
                'Đăng nhập bằng Google',
                style: AppTextStyle.semiBold(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.borderLight, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'HOẶC ĐĂNG NHẬP BẰNG EMAIL',
                style: AppTextStyle.bold(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.borderLight, thickness: 1),
            ),
          ],
        ),
      ],
    );
  }
}
