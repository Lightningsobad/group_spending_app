import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class GroupMembersTabSkeleton extends StatelessWidget {
  const GroupMembersTabSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: DANH SÁCH THÀNH VIÊN & + Mời thêm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  AppShimmerBox(width: 20, height: 20, borderRadius: 4),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 140, height: 16, borderRadius: 4),
                ],
              ),
              AppShimmerBox(width: 96, height: 40, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Search Text Field Skeleton
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
            child: const Row(
              children: [
                AppShimmerBox(width: 18, height: 18, borderRadius: 4),
                SizedBox(width: 12),
                AppShimmerBox(width: 130, height: 14, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Sub-header: Gợi ý chạm & Số lượng thành viên
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 170, height: 12, borderRadius: 4),
              AppShimmerBox(width: 80, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 10),

          // 4. Member Cards Skeletons (4 cards)
          ...List.generate(4, (index) => _buildMemberTileSkeleton(colors)),
          const SizedBox(height: 20),

          // 5. Danger card skeleton
          _buildDangerCardSkeleton(colors),
        ],
      ),
    );
  }

  Widget _buildMemberTileSkeleton(AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: const Row(
        children: [
          // Avatar
          AppShimmerBox(width: 40, height: 40, shape: CircleBorder()),
          SizedBox(width: 12),
          // Name
          Expanded(
            child: AppShimmerBox(width: 120, height: 14, borderRadius: 4),
          ),
          SizedBox(width: 8),
          // Role badge
          AppShimmerBox(width: 70, height: 22, borderRadius: 12),
          SizedBox(width: 8),
          // Chevron
          AppShimmerBox(width: 16, height: 16, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildDangerCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.errorBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppShimmerBox(width: 34, height: 34, shape: CircleBorder()),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 100, height: 14, borderRadius: 4),
                  SizedBox(height: 4),
                  AppShimmerBox(width: 180, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
          SizedBox(height: 14),
          AppShimmerBox(height: 48, borderRadius: 12),
        ],
      ),
    );
  }
}
