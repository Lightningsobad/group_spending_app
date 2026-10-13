import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';

import '../../../../shared/widgets/app_shimmer.dart';

class DebtsSummaryCards extends StatelessWidget {
  final num totalOwedVnd;
  final num totalReceivableVnd;
  final bool isLoading;

  const DebtsSummaryCards({
    super.key,
    required this.totalOwedVnd,
    required this.totalReceivableVnd,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      children: [
        // 1. Thẻ: Bạn đang nợ
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.debtOweBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.debtOweBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.trendingDown,
                      size: 14,
                      color: colors.debtOweText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.debtsYouOwe,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        color: colors.debtOweText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: AppShimmer(
                          child: AppShimmerBox(
                            width: 90,
                            height: 18,
                            borderRadius: 6,
                          ),
                        ),
                      )
                    : Text(
                        CurrencyUtils.formatVnd(totalOwedVnd),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.h4,
                          color: colors.debtOweAmount,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                const SizedBox(height: 2),
                Text(
                  tr.debtsYouOweSubtitle,
                  style: AppTextStyle.regular(
                    fontSize: AppFontSize.caption,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Thẻ: Bạn nhận
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.debtReceiveBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.debtReceiveBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.trendingUp,
                      size: 14,
                      color: colors.debtReceiveText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.debtsYouReceive,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        color: colors.debtReceiveText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                        child: AppShimmer(
                          child: AppShimmerBox(
                            width: 90,
                            height: 18,
                            borderRadius: 6,
                          ),
                        ),
                      )
                    : Text(
                        CurrencyUtils.formatVnd(totalReceivableVnd),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.h4,
                          color: colors.debtReceiveAmount,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                const SizedBox(height: 2),
                Text(
                  tr.debtsYouReceiveSubtitle,
                  style: AppTextStyle.regular(
                    fontSize: AppFontSize.caption,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
