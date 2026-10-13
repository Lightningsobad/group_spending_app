import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

/// Hiệu ứng shimmer skeleton đồng bộ toàn trang cho Tab Tổng quan
/// trước khi dữ liệu chi tiết nhóm được tải về.
class GroupOverviewSkeleton extends StatelessWidget {
  final bool enabled;

  const GroupOverviewSkeleton({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1: THÔNG TIN NHÓM SKELETON
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppShimmerBox(width: 120, height: 14, borderRadius: 4),
                const SizedBox(height: 10),
                const AppShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                const AppShimmerBox(width: 220, height: 14, borderRadius: 4),
                const SizedBox(height: 16),

                // 3 Mini info chips
                Row(
                  children: [
                    Expanded(child: _buildChipSkeleton(colors)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildChipSkeleton(colors)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildChipSkeleton(colors)),
                  ],
                ),
                const SizedBox(height: 14),

                // Invite Banner Skeleton
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppShimmerBox(width: 90, height: 12, borderRadius: 4),
                            SizedBox(height: 6),
                            AppShimmerBox(width: 120, height: 20, borderRadius: 4),
                          ],
                        ),
                      ),
                      const AppShimmerBox(width: 100, height: 48, borderRadius: 10),
                      const SizedBox(width: 8),
                      const AppShimmerBox(width: 48, height: 48, borderRadius: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card 2: TỔNG QUAN TÀI CHÍNH NHÓM SKELETON
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppShimmerBox(width: 28, height: 28, borderRadius: 8),
                        SizedBox(width: 8),
                        AppShimmerBox(width: 160, height: 16, borderRadius: 4),
                      ],
                    ),
                    AppShimmerBox(width: 42, height: 20, borderRadius: 10),
                  ],
                ),
                const SizedBox(height: 14),

                // Inner Balance Card Skeleton
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 130, height: 12, borderRadius: 4),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppShimmerBox(width: 150, height: 26, borderRadius: 6),
                          AppShimmerBox(width: 80, height: 24, borderRadius: 12),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2 Summary Cards Skeleton
                Row(
                  children: [
                    Expanded(child: _buildSummaryBoxSkeleton(colors)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildSummaryBoxSkeleton(colors)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Section 3: LỐI TẮT & THAO TÁC NHANH SKELETON
          const AppShimmerBox(width: 170, height: 14, borderRadius: 4),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildActionTileSkeleton(colors)),
              const SizedBox(width: 10),
              Expanded(child: _buildActionTileSkeleton(colors)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildActionTileSkeleton(colors)),
              const SizedBox(width: 10),
              Expanded(child: _buildActionTileSkeleton(colors)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmerBox(width: 50, height: 10, borderRadius: 4),
          SizedBox(height: 6),
          AppShimmerBox(width: 70, height: 14, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildSummaryBoxSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 75, height: 12, borderRadius: 4),
              AppShimmerBox(width: 16, height: 16, borderRadius: 4),
            ],
          ),
          SizedBox(height: 8),
          AppShimmerBox(width: 95, height: 18, borderRadius: 4),
          SizedBox(height: 6),
          AppShimmerBox(width: 70, height: 12, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildActionTileSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        children: [
          AppShimmerBox(width: 38, height: 38, borderRadius: 19),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(width: 75, height: 14, borderRadius: 4),
                SizedBox(height: 4),
                AppShimmerBox(width: 60, height: 10, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
