import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/fund_entities.dart';

class FundCardWidget extends StatelessWidget {
  final FundCollectionItemEntity fund;
  final VoidCallback onTap;

  const FundCardWidget({
    super.key,
    required this.fund,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isCollecting = fund.isCollecting;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Piggy bank icon box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.fundPiggyBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                LucideIcons.piggyBank,
                size: 20,
                color: colors.fundPiggyIcon,
              ),
            ),
            const SizedBox(width: 12),

            // Center details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fund.name,
                    style: AppTextStyle.bold(
                      fontSize: 15,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: CurrencyUtils.formatVnd(fund.totalCollectedAmountVnd ?? 0),
                          style: AppTextStyle.bold(
                            fontSize: 13,
                            color: colors.fundAmountText,
                          ),
                        ),
                        if (fund.totalTargetAmountVnd != null) ...[
                          TextSpan(
                            text: ' / ${CurrencyUtils.formatVnd(fund.totalTargetAmountVnd!)}',
                            style: AppTextStyle.regular(
                              fontSize: 12,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Status Badge + Chevron Right
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCollecting
                        ? colors.fundStatusCollectingBg
                        : colors.fundStatusCompletedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    fund.statusText,
                    style: AppTextStyle.bold(
                      fontSize: 11.5,
                      color: isCollecting
                          ? colors.fundStatusCollectingText
                          : colors.fundStatusCompletedText,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: colors.textMuted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
