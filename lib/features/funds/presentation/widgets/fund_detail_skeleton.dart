import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_shimmer.dart';

class FundDetailSkeleton extends StatelessWidget {
  const FundDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      child: Column(
        children: [
          // 1. Top Header Bar Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Back button skeleton (48x48 touch target area)
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: const AppShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 8),

                // Title & Group Name
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 140, height: 18, borderRadius: 4),
                      SizedBox(height: 4),
                      AppShimmerBox(width: 80, height: 12, borderRadius: 4),
                    ],
                  ),
                ),

                // Admin Action Buttons Skeleton
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppShimmerBox(width: 34, height: 34, borderRadius: 10),
                    SizedBox(width: 8),
                    AppShimmerBox(width: 34, height: 34, borderRadius: 10),
                  ],
                ),
              ],
            ),
          ),

          // 2. Body Scrollable Content Skeleton
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFundInfoCardSkeleton(colors),
                  const SizedBox(height: 16),
                  _buildMembersCardSkeleton(colors),
                  const SizedBox(height: 20),
                  _buildBottomActionsSkeleton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundInfoCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status & CSV chip
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 90, height: 26, borderRadius: 20),
              AppShimmerBox(width: 60, height: 26, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          const AppShimmerBox(width: 200, height: 22, borderRadius: 6),
          const SizedBox(height: 10),

          // Description
          const AppShimmerBox(
            width: double.infinity,
            height: 46,
            borderRadius: 16,
          ),
          const SizedBox(height: 12),

          // Due Date
          const Row(
            children: [
              AppShimmerBox(width: 16, height: 16, borderRadius: 4),
              SizedBox(width: 8),
              AppShimmerBox(width: 140, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),

          // Amounts (Collected vs Target)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBox(width: 80, height: 12, borderRadius: 4),
                  SizedBox(height: 6),
                  AppShimmerBox(width: 110, height: 24, borderRadius: 6),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppShimmerBox(width: 70, height: 12, borderRadius: 4),
                  SizedBox(height: 6),
                  AppShimmerBox(width: 80, height: 16, borderRadius: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          const AppShimmerBox(
            width: double.infinity,
            height: 8,
            borderRadius: 8,
          ),
          const SizedBox(height: 10),

          // Footer summary (ratio & percentage)
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppShimmerBox(width: 120, height: 12, borderRadius: 4),
              AppShimmerBox(width: 40, height: 14, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembersCardSkeleton(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppShimmerBox(width: 16, height: 16, borderRadius: 4),
                  SizedBox(width: 6),
                  AppShimmerBox(width: 100, height: 14, borderRadius: 4),
                ],
              ),
              AppShimmerBox(width: 70, height: 12, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),

          // 4 Member Tiles
          for (int i = 0; i < 4; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  // Avatar
                  const AppShimmerBox(
                    width: 36,
                    height: 36,
                    shape: CircleBorder(),
                  ),
                  const SizedBox(width: 12),

                  // Name & Amount
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppShimmerBox(width: 70, height: 14, borderRadius: 4),
                        SizedBox(height: 4),
                        AppShimmerBox(width: 50, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Pill & Remind button
                  const AppShimmerBox(width: 64, height: 32, borderRadius: 20),
                  const SizedBox(width: 8),
                  const AppShimmerBox(width: 32, height: 32, borderRadius: 10),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionsSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppShimmerBox(width: double.infinity, height: 48, borderRadius: 16),
        SizedBox(height: 10),
        AppShimmerBox(width: double.infinity, height: 48, borderRadius: 16),
        SizedBox(height: 10),
        AppShimmerBox(width: double.infinity, height: 48, borderRadius: 16),
      ],
    );
  }
}
