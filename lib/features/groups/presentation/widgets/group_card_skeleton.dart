import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class GroupCardSkeleton extends StatelessWidget {
  final bool enabled;

  const GroupCardSkeleton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [colors.cardShadow],
      ),
      child: AppShimmer(
        enabled: enabled,
        child: Column(
          children: [
            // Top Row
            Row(
              children: [
                // Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and badge skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppShimmerBox(
                        width: 140,
                        height: 15,
                        borderRadius: 6,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          AppShimmerBox(
                            width: 60,
                            height: 18,
                            borderRadius: 6,
                          ),
                          SizedBox(width: 6),
                          AppShimmerBox(
                            width: 80,
                            height: 18,
                            borderRadius: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action icon placeholder
                const AppShimmerBox(
                  width: 24,
                  height: 24,
                  borderRadius: 12,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Divider skeleton
            Container(
              height: 1,
              color: colors.cardBorder.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),

            // Bottom balance row skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmerBox(width: 70, height: 10, borderRadius: 4),
                    SizedBox(height: 4),
                    AppShimmerBox(width: 90, height: 14, borderRadius: 4),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppShimmerBox(width: 60, height: 10, borderRadius: 4),
                    SizedBox(height: 4),
                    AppShimmerBox(width: 80, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
