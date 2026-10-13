import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class GroupDebtCardSkeleton extends StatelessWidget {
  final bool enabled;

  const GroupDebtCardSkeleton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppShimmer(
        enabled: enabled,
        child: Row(
          children: [
            // Icon container skeleton (44x44, radius 14)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),

            // Left: Group Name & Status Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppShimmerBox(
                    width: 130,
                    height: 14,
                    borderRadius: 4,
                  ),
                  SizedBox(height: 6),
                  AppShimmerBox(
                    width: 90,
                    height: 11,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right: Amount & Status Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                AppShimmerBox(
                  width: 75,
                  height: 14,
                  borderRadius: 4,
                ),
                SizedBox(height: 6),
                AppShimmerBox(
                  width: 65,
                  height: 18,
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
