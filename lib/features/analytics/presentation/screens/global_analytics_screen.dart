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
import '../cubit/global_analytics_cubit.dart';
import '../cubit/global_analytics_state.dart';
import '../widgets/analytics_kpi_card.dart';
import '../widgets/analytics_period_bar.dart';
import '../widgets/category_distribution_bar.dart';
import '../widgets/category_distribution_list.dart';
import '../widgets/leaderboard_section.dart';
import '../widgets/recent_expenses_section.dart';

class GlobalAnalyticsScreen extends StatelessWidget {
  final GlobalAnalyticsCubit? cubit;

  const GlobalAnalyticsScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider.value(
        value: cubit!,
        child: const _GlobalAnalyticsView(),
      );
    }

    return BlocProvider(
      create: (context) => GlobalAnalyticsCubit(
        analyticsRepository: context.read<AnalyticsRepository>(),
        sessionCoordinator: context.read<SessionCoordinator>(),
        dataSyncCoordinator: context.read<DataSyncCoordinator>(),
      )..loadAnalytics(),
      child: const _GlobalAnalyticsView(),
    );
  }
}

class _GlobalAnalyticsView extends StatelessWidget {
  const _GlobalAnalyticsView();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<GlobalAnalyticsCubit, GlobalAnalyticsState>(
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
            return Column(
              children: [
                // Top Custom App Bar
                _buildAppBar(context),
                const SizedBox(height: 8),

                // Period Filter Chips
                AnalyticsPeriodBar(
                  currentPeriod: state.period,
                  onPeriodChanged: (p) {
                    context.read<GlobalAnalyticsCubit>().setPeriod(p);
                  },
                ),
                const SizedBox(height: 12),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context
                        .read<GlobalAnalyticsCubit>()
                        .loadAnalytics(isRefresh: true),
                    color: const Color(0xFF6366F1),
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
                          else if (state.isFailure && state.details.totalSpendingVnd == 0)
                            _buildErrorView(context, state)
                          else ...[
                            // Section: CHỈ SỐ TÀI CHÍNH NHÓM
                            _buildFinancialMetricsSection(context, state),
                            const SizedBox(height: 24),

                            // Section: PHÂN BỐ THEO DANH MỤC CHI TIÊU
                            _buildCategoryDistributionSection(context, state),
                            const SizedBox(height: 24),

                            // Section: BẢNG XẾP HẠNG ĐÓNG GÓP
                            LeaderboardSection(
                              title: tr.memberContributionTitle,
                              memberCount: state.details.totalUniqueMembers,
                              members: state.leaderboard,
                            ),
                            const SizedBox(height: 24),

                            // Section: HÓA ĐƠN CHI TIÊU GẦN ĐÂY
                            RecentExpensesSection(
                              expenses: state.recentExpenses,
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

  Widget _buildAppBar(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

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
              border: Border.all(color: colors.cardBorder),
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
                  tr.overallReportTitle,
                  style: AppTextStyle.extraBold(
                    color: colors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr.overallReportSubtitle,
                  style: AppTextStyle.regular(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
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
    GlobalAnalyticsState state,
  ) {
    final tr = context.l10n;
    final colors = context.colors;
    final details = state.details;

    final remainingDebt = (100 - details.debtSettlementRate)
        .clamp(0.0, 100.0)
        .toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  tr.financialMetricsTitle,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 2x2 Grid of KPI Cards
        Row(
          children: [
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.trendingUp,
                iconColor: const Color(0xFF6366F1),
                iconBgColor: const Color(0xFFEEF2FF),
                label: tr.totalSpendingMetric,
                value: CurrencyUtils.formatVnd(details.totalSpendingVnd),
                badgeText: '↑ 4.5%',
                badgeBgColor: const Color(0xFFDCFCE7),
                badgeTextColor: const Color(0xFF15803D),
                subtitle: tr.commonGroupSpendingSubtitle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.users,
                iconColor: const Color(0xFF10B981),
                iconBgColor: const Color(0xFFD1FAE5),
                label: tr.averagePerPersonMetric,
                value: CurrencyUtils.formatVnd(details.averageSpendingPerPersonVnd),
                badgeText: tr.friendsCountBadge(details.totalUniqueMembers),
                badgeBgColor: const Color(0xFFDCFCE7),
                badgeTextColor: const Color(0xFF15803D),
                subtitle: tr.splitEquallySubtitle,
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
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFEF3C7),
                label: tr.expenseCountMetric,
                value: '${details.totalExpenseCount} ${tr.expensesUnit}',
                badgeText: tr.invoicesBadge,
                badgeBgColor: const Color(0xFFFEF3C7),
                badgeTextColor: const Color(0xFFB45309),
                subtitle: tr.recordedAndAuditedSubtitle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnalyticsKpiCard(
                icon: LucideIcons.checkCircle,
                iconColor: const Color(0xFF06B6D4),
                iconBgColor: const Color(0xFFCFFAFE),
                label: tr.settlementRateMetric,
                value: '${details.debtSettlementRate.toInt()}% ${tr.paidRateSuffix}',
                badgeText: '${details.debtSettlementRate.toInt()}%',
                badgeBgColor: const Color(0xFFCFFAFE),
                badgeTextColor: const Color(0xFF0E7490),
                progressBarPercent: details.debtSettlementRate / 100,
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
    GlobalAnalyticsState state,
  ) {
    final tr = context.l10n;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🕒', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  tr.categoryDistributionTitle,
                  style: AppTextStyle.bold(
                    color: colors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
          categories: state.details.categoryDistributions,
        ),
        const SizedBox(height: 12),
        CategoryDistributionList(
          categories: state.details.categoryDistributions,
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

  Widget _buildErrorView(BuildContext context, GlobalAnalyticsState state) {
    final tr = context.l10n;

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
                  context.read<GlobalAnalyticsCubit>().loadAnalytics(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
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
