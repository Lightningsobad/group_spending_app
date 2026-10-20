import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class FinancialBalanceCardSkeleton extends StatelessWidget {
  final bool enabled;

  const FinancialBalanceCardSkeleton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colors.financialCardBgStart,
            colors.financialCardBgMiddle,
            colors.financialCardBgEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.financialCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          colors.financialCardShadow,
        ],
      ),
      child: AppShimmer(
        enabled: enabled,
        baseColor: colors.financialCardIconBg,
        highlightColor: colors.financialCardBoxBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row Skeleton
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.financialCardIconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 10),
                const AppShimmerBox(width: 160, height: 14, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 16),

            // Two balance boxes skeleton
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.financialCardBoxBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.financialCardBoxBorder,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 70, height: 12, borderRadius: 4),
                        SizedBox(height: 8),
                        AppShimmerBox(width: 110, height: 18, borderRadius: 6),
                        SizedBox(height: 6),
                        AppShimmerBox(width: 85, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.financialCardBoxBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.financialCardBoxBorder,
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 60, height: 12, borderRadius: 4),
                        SizedBox(height: 8),
                        AppShimmerBox(width: 110, height: 18, borderRadius: 6),
                        SizedBox(height: 6),
                        AppShimmerBox(width: 85, height: 10, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
