import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import 'group_debt_card_skeleton.dart';

class GroupDebtDetailSkeleton extends StatelessWidget {
  final VoidCallback? onBack;

  const GroupDebtDetailSkeleton({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Sub-Header: Back Pill & Group Title Pill Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button pill (keeps min 48x48 tap target and active back callback)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onBack,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.arrowLeft,
                          size: 16,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tr.backAction,
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.secondary,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Group Pill Skeleton
              AppShimmer(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.debtReceiveBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.debtReceiveBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      AppShimmerBox(width: 14, height: 14, borderRadius: 4),
                      SizedBox(width: 6),
                      AppShimmerBox(width: 90, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Group Summary Card Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: AppShimmer(
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.cardBorder),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AppShimmerBox(width: 130, height: 16, borderRadius: 4),
                            SizedBox(height: 6),
                            AppShimmerBox(width: 80, height: 12, borderRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AppShimmerBox(width: 76, height: 26, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(height: 1, color: colors.cardBorder),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AppShimmerBox(width: 110, height: 14, borderRadius: 4),
                      AppShimmerBox(width: 85, height: 20, borderRadius: 6),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Segmented Tab Switcher Skeleton
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            child: AppShimmer(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      alignment: Alignment.center,
                      child: const AppShimmerBox(width: 90, height: 16, borderRadius: 6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: const AppShimmerBox(width: 80, height: 16, borderRadius: 6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Content Cards Skeleton List
          ...List.generate(
            3,
            (index) => const GroupDebtCardSkeleton(),
          ),
        ],
      ),
    );
  }
}
