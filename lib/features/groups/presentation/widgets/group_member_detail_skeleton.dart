import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class GroupMemberDetailSkeleton extends StatelessWidget {
  const GroupMemberDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Sub-Header: Back & Group Name
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 130, height: 28, borderRadius: 8),
              AppShimmerBox(width: 100, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Profile Hero Card Skeleton
          _buildHeroCardSkeleton(colors),
          const SizedBox(height: 16),

          // 3. Contact & Bank Card Skeleton
          _buildContactAndBankCardSkeleton(colors),
          const SizedBox(height: 16),

          // 4. Debt Status Card Skeleton
          _buildDebtStatusCardSkeleton(colors),
          const SizedBox(height: 16),

          // 5. Participated Expenses Card Skeleton
          _buildParticipatedExpensesCardSkeleton(colors),
        ],
      ),
    );
  }

  Widget _buildHeroCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.memberHeroCardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.memberHeroCardBorder),
      ),
      child: Column(
        children: [
          // Avatar
          const AppShimmerBox(width: 76, height: 76, shape: CircleBorder()),
          const SizedBox(height: 12),
          // Name
          const AppShimmerBox(width: 150, height: 20, borderRadius: 6),
          const SizedBox(height: 8),
          // Role & group
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppShimmerBox(width: 80, height: 20, borderRadius: 12),
              SizedBox(width: 8),
              AppShimmerBox(width: 90, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Columns Stats Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: colors.memberStatsBoxBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.memberStatsBoxBorder),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AppShimmerBox(width: 60, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      AppShimmerBox(width: 75, height: 14, borderRadius: 4),
                      SizedBox(height: 4),
                      AppShimmerBox(width: 45, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      AppShimmerBox(width: 65, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      AppShimmerBox(width: 50, height: 14, borderRadius: 4),
                      SizedBox(height: 4),
                      AppShimmerBox(width: 40, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      AppShimmerBox(width: 70, height: 10, borderRadius: 4),
                      SizedBox(height: 6),
                      AppShimmerBox(width: 50, height: 14, borderRadius: 4),
                      SizedBox(height: 4),
                      AppShimmerBox(width: 45, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndBankCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppShimmerBox(width: 170, height: 14, borderRadius: 4),
          const SizedBox(height: 14),
          // Email row
          const Row(
            children: [
              AppShimmerBox(width: 32, height: 32, borderRadius: 10),
              SizedBox(width: 12),
              AppShimmerBox(width: 50, height: 14, borderRadius: 4),
              Spacer(),
              AppShimmerBox(width: 130, height: 14, borderRadius: 4),
              SizedBox(width: 8),
              AppShimmerBox(width: 24, height: 24, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Phone row
          const Row(
            children: [
              AppShimmerBox(width: 32, height: 32, borderRadius: 10),
              SizedBox(width: 12),
              AppShimmerBox(width: 80, height: 14, borderRadius: 4),
              Spacer(),
              AppShimmerBox(width: 100, height: 14, borderRadius: 4),
              SizedBox(width: 8),
              AppShimmerBox(width: 24, height: 24, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Bank row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppShimmerBox(width: 32, height: 32, borderRadius: 10),
                  SizedBox(width: 12),
                  AppShimmerBox(width: 120, height: 14, borderRadius: 4),
                ],
              ),
              AppShimmerBox(width: 90, height: 32, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 12),
          // Bank box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.memberHeroCardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.memberHeroCardBorder),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppShimmerBox(width: 90, height: 14, borderRadius: 4),
                    SizedBox(width: 8),
                    AppShimmerBox(width: 100, height: 20, borderRadius: 6),
                    Spacer(),
                    AppShimmerBox(width: 60, height: 16, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 8),
                AppShimmerBox(width: 130, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtStatusCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 150, height: 14, borderRadius: 4),
              AppShimmerBox(width: 90, height: 20, borderRadius: 10),
            ],
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 140, height: 14, borderRadius: 4),
              AppShimmerBox(width: 80, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 150, height: 14, borderRadius: 4),
              AppShimmerBox(width: 70, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 100, height: 14, borderRadius: 4),
              AppShimmerBox(width: 110, height: 16, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipatedExpensesCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 160, height: 14, borderRadius: 4),
              AppShimmerBox(width: 40, height: 18, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(2, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: const Row(
                children: [
                  AppShimmerBox(width: 36, height: 36, borderRadius: 10),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 120, height: 14, borderRadius: 4),
                        SizedBox(height: 4),
                        AppShimmerBox(width: 100, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppShimmerBox(width: 70, height: 14, borderRadius: 4),
                      SizedBox(height: 4),
                      AppShimmerBox(width: 50, height: 12, borderRadius: 4),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
