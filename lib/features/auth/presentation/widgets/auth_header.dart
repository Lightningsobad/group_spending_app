import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/wallet_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return Column(
      children: [
        const WalletLogo(
          size: 56,
          iconSize: 28,
          outlineWidth: 4,
          borderRadius: 20,
        ),
        const SizedBox(height: 14),
        Text(
          tr.authHeaderTitle,
          textAlign: TextAlign.center,
          style: AppTextStyle.black(
            fontSize: 28,
            color: AppColors.textDark,
            letterSpacing: -0.4,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          tr.authHeaderSubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyle.medium(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
