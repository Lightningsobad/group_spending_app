import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleAuth;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    required this.onGoogleAuth,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: isLoading ? null : onGoogleAuth,
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
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.emeraldForest,
                    ),
                  ),
                )
              else
                SvgPicture.asset('assets/auth/google.svg', width: 20, height: 20),
              const SizedBox(width: 10),
              Text(
                tr.continueWithGoogle,
                style: AppTextStyle.semiBold(
                  fontSize: 14,
                  color: isLoading ? AppColors.textSecondary : AppColors.textDark,
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
                tr.orLoginWithEmail,
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
