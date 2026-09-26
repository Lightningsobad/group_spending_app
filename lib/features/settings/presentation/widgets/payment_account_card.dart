import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class PaymentAccountCard extends StatelessWidget {
  final VoidCallback? onEdit;

  const PaymentAccountCard({super.key, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.creditCard,
                    size: 18,
                    color: AppColors.emeraldForest,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tr.vietqrTitle,
                    style: AppTextStyle.bold(
                      fontSize: 12,
                      color: colors.textSlate800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEdit ?? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr.underDevelopment)),
                  );
                },
                child: Text(
                  tr.edit,
                  style: AppTextStyle.bold(
                    fontSize: 12,
                    color: AppColors.emeraldForest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colors.divider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.defaultBankInfo,
                  style: AppTextStyle.bold(
                    fontSize: 14,
                    color: colors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr.defaultAccountName,
                  style: AppTextStyle.semiBold(
                    fontSize: 11,
                    color: colors.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
