import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../cubit/group_analytics_cubit.dart';
import '../cubit/group_analytics_state.dart';
import '../widgets/analytics_kpi_card.dart';
import '../widgets/analytics_period_bar.dart';
import '../widgets/category_distribution_bar.dart';
import '../widgets/category_distribution_list.dart';
import '../widgets/leaderboard_section.dart';

class GroupAnalyticsScreen extends StatelessWidget {
  final int groupId;
  final String? groupName;
  final String? groupCategory;
  final int? memberCount;
  final GroupAnalyticsCubit? cubit;

  const GroupAnalyticsScreen({
    super.key,
    required this.groupId,
    this.groupName,
    this.groupCategory,
    this.memberCount,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: _GroupAnalyticsView(
          groupName: groupName,
          groupCategory: groupCategory,
          memberCount: memberCount,
        ),
      );
    }

    return BlocProvider(
      create: (context) => GroupAnalyticsCubit(
        groupId: groupId,
        analyticsRepository: context.read<AnalyticsRepository>(),
        sessionCoordinator: context.read<SessionCoordinator>(),
        dataSyncCoordinator: context.read<DataSyncCoordinator>(),
      )..loadGroupAnalytics(),
      child: _GroupAnalyticsView(
        groupName: groupName,
        groupCategory: groupCategory,
        memberCount: memberCount,
      ),
    );
  }
}

class _GroupAnalyticsView extends StatelessWidget {
  final String? groupName;
  final String? groupCategory;
  final int? memberCount;

  const _GroupAnalyticsView({
    this.groupName,
    this.groupCategory,
    this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<GroupAnalyticsCubit, GroupAnalyticsState>(
          listener: (context, state) {
            if (state.isFailure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final effectiveGroupName = groupName ??
                state.groupStatistics.groupName ??
                tr.groupAnalyticsFallbackTitle(state.groupId);
            final effectiveMembers = memberCount ??
                state.groupStatistics.totalUniqueMembers;

            return Column(
              children: [
                // Top Custom Header
                _buildAppBar(context, effectiveGroupName, effectiveMembers),
                const SizedBox(height: 8),

                // Period Filter Chips
                AnalyticsPeriodBar(
                  currentPeriod: state.period,
                  onPeriodChanged: (p) {
                    context.read<GroupAnalyticsCubit>().setPeriod(p);
                  },
                ),
                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context
                        .read<GroupAnalyticsCubit>()
                        .loadGroupAnalytics(isRefresh: true),
                    color: colors.analyticsAccent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.isLoading && !state.isRefreshing)
                            _buildLoadingShimmer()
                          else if (state.isFailure &&
                              state.groupStatistics.totalSpendingVnd == 0)
                            _buildErrorView(context, state)
                          else ...[
                            // Section: CHỈ SỐ TÀI CHÍNH NHÓM
                            _buildFinancialMetricsSection(context, state),
                            const SizedBox(height: 24),

                            // Section: PHÂN BỐ THEO DANH MỤC CHI TIÊU
                            _buildCategoryDistributionSection(context, state),
                            const SizedBox(height: 24),

                            // Section: ĐÓNG GÓP & CHI TIÊU THÀNH VIÊN
                            LeaderboardSection(
                              title: tr.memberContributionTitle,
                              memberCount: effectiveMembers,
                              members: state.leaderboard,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    String groupTitle,
    int members,
  ) {
    final tr = context.l10n;
    final colors = context.colors;

    final subtitle = groupCategory != null
        ? '$groupCategory • ${tr.membersCountSubtitle(members)}'
        : tr.membersCountSubtitle(members);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.cardBorder.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: colors.textPrimary,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupTitle,
                  style: AppTextStyle.extraBold(
                    color: colors.textPrimary,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyle.regular(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialMetricsSection(
    BuildContext context,
    GroupAnalyticsState state,
  ) {
    final tr = context.l10n;
    final colors = context.colors;
    final stats = state.groupStatistics;

    final remainingDebt = (100 - stats.debtSettlementRate)
        .clamp(0.0, 100.0)
        .toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    size: 18,
                    color: colors.analyticsAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.financialMetricsTitle,
                      style: AppTextStyle.bold(
                        color: colors.textPrimary,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 2x2 Grid
        Row(
          children: [
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.trendingUp,
                iconColor: colors.analyticsAccent,
                iconBgColor: colors.analyticsIconBg,
                label: tr.totalSpendingMetric,
                value: CurrencyUtils.formatVnd(stats.totalSpendingVnd),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.users,
                iconColor: colors.badgeSuccessText,
                iconBgColor: colors.badgeSuccessBg,
                label: tr.averagePerPersonMetric,
                value: CurrencyUtils.formatVnd(stats.averageSpendingPerPersonVnd),
                badgeText: tr.friendsCountBadge(stats.totalUniqueMembers),
                badgeBgColor: colors.badgeSuccessBg,
                badgeTextColor: colors.badgeSuccessText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.receipt,
                iconColor: colors.badgeWarningText,
                iconBgColor: colors.badgeWarningBg,
                label: tr.expenseCountMetric,
                value: '${stats.totalExpenseCount} ${tr.expensesUnit}',
                badgeText: tr.invoicesBadge,
                badgeBgColor: colors.badgeWarningBg,
                badgeTextColor: colors.badgeWarningText,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.checkCircle,
                iconColor: colors.badgeInfoText,
                iconBgColor: colors.badgeInfoBg,
                label: tr.settlementRateMetric,
                value: '${stats.debtSettlementRate.toInt()}% ${tr.paidRateSuffix}',
                badgeText: '${stats.debtSettlementRate.toInt()}%',
                badgeBgColor: colors.badgeInfoBg,
                badgeTextColor: colors.badgeInfoText,
                progressBarPercent: stats.debtSettlementRate / 100,
                progressSubtitleLeft: tr.groupDebtLabel,
                progressSubtitleRight: tr.remainingDebtRate(remainingDebt),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDistributionSection(
    BuildContext context,
    GroupAnalyticsState state,
  ) {
    final tr = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    LucideIcons.pieChart,
                    size: 18,
                    color: colors.analyticsAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr.categoryDistributionTitle,
                      style: AppTextStyle.bold(
                        color: colors.textPrimary,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '100%',
              style: AppTextStyle.regular(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CategoryDistributionBar(
          categories: state.groupStatistics.categoryDistributions,
        ),
        const SizedBox(height: 12),
        CategoryDistributionList(
          categories: state.groupStatistics.categoryDistributions,
        ),
      ],
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppShimmer(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, GroupAnalyticsState state) {
    final tr = context.l10n;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              state.errorMessage ?? tr.loadAnalyticsFailed,
              style: AppTextStyle.regular(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<GroupAnalyticsCubit>().loadGroupAnalytics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.analyticsAccent,
                foregroundColor: Colors.white,
              ),
              child: Text(tr.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}
