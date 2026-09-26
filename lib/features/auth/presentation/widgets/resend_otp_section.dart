import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ResendOtpSection extends StatelessWidget {
  final VoidCallback onResend;

  const ResendOtpSection({super.key, required this.onResend});

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return BlocSelector<AuthCubit, AuthState, int>(
      selector: (state) => state.resendCountdown,
      builder: (context, countdown) {
        if (countdown > 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                tr.localeName == 'en' ? 'Resend code in ' : 'Gửi lại mã sau ',
                style: AppTextStyle.medium(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatCountdown(countdown),
                  style: AppTextStyle.bold(
                    fontSize: 13,
                    color: AppColors.emeraldForest,
                  ),
                ),
              ),
            ],
          );
        }

        return TextButton(
          onPressed: onResend,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.emeraldDark,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh, size: 16, color: AppColors.emeraldDark),
              const SizedBox(width: 6),
              Text(
                tr.resendOtpNow,
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: AppColors.emeraldDark,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
