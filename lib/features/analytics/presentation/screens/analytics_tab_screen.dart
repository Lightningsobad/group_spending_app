import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../cubit/analytics_tab_cubit.dart';
import '../cubit/analytics_tab_state.dart';
import '../widgets/analytics_group_card.dart';

class AnalyticsTabScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGlobalOverview;
  final ValueChanged<int>? onNavigateToGroupAnalytics;

  const AnalyticsTabScreen({
    super.key,
    this.onNavigateToGlobalOverview,
    this.onNavigateToGroupAnalytics,
  });

  @override
  State<AnalyticsTabScreen> createState() => _AnalyticsTabScreenState();
}

class _AnalyticsTabScreenState extends State<AnalyticsTabScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AnalyticsTabCubit>();
    if (cubit.state.status == AnalyticsTabStatus.initial) {
      cubit.loadOverview();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onGroupTap(int groupId) {
    if (widget.onNavigateToGroupAnalytics != null) {
      widget.onNavigateToGroupAnalytics!(groupId);
    } else {
      context.push('/groups/$groupId/analytics');
    }
  }

  void _onGlobalOverviewTap() {
    if (widget.onNavigateToGlobalOverview != null) {
      widget.onNavigateToGlobalOverview!();
    } else {
      context.push('/analytics/overview');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<AnalyticsTabCubit, AnalyticsTabState>(
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
        return Scaffold(
          backgroundColor: colors.background,
          body: RefreshIndicator(
            onRefresh: () => context.read<AnalyticsTabCubit>().loadOverview(isRefresh: true),
            color: const Color(0xFF6366F1),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title row
                  _buildHeaderTitle(context),
                  const SizedBox(height: 16),

                  // Top 3 KPI Cards
                  if (state.isLoading && !state.isRefreshing)
                    _buildLoadingKpiCards()
                  else
                    _buildTopKpiCards(context, state),
                  const SizedBox(height: 16),

                  // Banner "Báo cáo tổng quan"
                  _buildOverallReportBanner(context),
                  const SizedBox(height: 16),

                  // Search bar
                  _buildSearchBar(context),
                  const SizedBox(height: 12),

                  // Filter chips (Tất cả, Đang hoạt động, Đã lưu trữ)
                  _buildFilterChips(context, state),
                  const SizedBox(height: 18),

                  // Section Header: DANH SÁCH NHÓM CHI TIÊU
                  _buildSectionHeader(context, state),
                  const SizedBox(height: 12),

                  // Group List
                  if (state.isLoading && !state.isRefreshing)
                    _buildLoadingGroupList()
                  else if (state.isFailure && state.groups.isEmpty)
                    _buildErrorState(context, state)
                  else if (state.filteredGroups.isEmpty)
                    _buildEmptyGroupsState(context)
                  else
                    ...state.filteredGroups.map(
                      (g) => AnalyticsGroupCard(
                        group: g,
                        onTap: () => _onGroupTap(g.id),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderTitle(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            LucideIcons.barChart3,
            size: 22,
            color: Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          tr.tabAnalyticsTitle,
          style: AppTextStyle.extraBold(
            color: colors.textPrimary,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildTopKpiCards(BuildContext context, AnalyticsTabState state) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      children: [
        // Card 1: Tổng chi tất cả nhóm
        Expanded(
          child: _buildMiniKpiCard(
            context,
            label: tr.totalSpendingAllGroups,
            value: CurrencyUtils.formatVnd(state.overview.totalSpendingVnd),
            valueColor: colors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        // Card 2: Số nhóm tham gia
        Expanded(
          child: _buildMiniKpiCard(
            context,
            label: tr.activeGroupsJoinedCount,
            value: '${state.overview.activeGroupCount} ${tr.groupsUnit}',
            valueColor: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 8),
        // Card 3: Số hóa đơn đã ghi
        Expanded(
          child: _buildMiniKpiCard(
            context,
            label: tr.totalInvoicesRecorded,
            value: '${state.overview.totalExpenses} ${tr.invoicesUnit}',
            valueColor: AppColors.emerald,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniKpiCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color valueColor,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyle.regular(
              color: colors.textSecondary,
              fontSize: 11,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyle.extraBold(
              color: valueColor,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingKpiCards() {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < 2 ? 8.0 : 0.0),
            child: AppShimmer(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallReportBanner(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE9D5FF),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _onGlobalOverviewTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.layers,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tr.overallReportBannerTitle,
                style: AppTextStyle.bold(
                  color: colors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '${tr.viewOverallReportAction} >',
              style: AppTextStyle.bold(
                color: const Color(0xFF6366F1),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyle.regular(color: colors.textPrimary, fontSize: 14),
        onChanged: (val) {
          context.read<AnalyticsTabCubit>().setSearchQuery(val);
        },
        decoration: InputDecoration(
          hintText: tr.searchGroupByHint,
          hintStyle: AppTextStyle.regular(color: colors.textMuted, fontSize: 13),
          prefixIcon: Icon(LucideIcons.search, size: 18, color: colors.textMuted),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
                  onPressed: () {
                    _searchController.clear();
                    context.read<AnalyticsTabCubit>().setSearchQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AnalyticsTabState state) {
    final tr = context.l10n;
    final colors = context.colors;

    final filters = [
      {'key': 'ALL', 'label': tr.filterAllTab(state.allCount)},
      {'key': 'ACTIVE', 'label': tr.filterActiveTab},
      {'key': 'ARCHIVED', 'label': tr.filterArchivedTab},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = state.filter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<AnalyticsTabCubit>().setFilter(f['key'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : colors.cardBorder,
                    width: 1,
                  ),
                ),
                child: Text(
                  f['label'] as String,
                  style: isSelected
                      ? AppTextStyle.bold(
                          color: Colors.white,
                          fontSize: 12,
                        )
                      : AppTextStyle.semiBold(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, AnalyticsTabState state) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          tr.groupSpendingListTitle,
          style: AppTextStyle.bold(
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          '${state.filteredGroups.length} ${tr.groupsUnit}',
          style: AppTextStyle.regular(
            color: colors.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingGroupList() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AppShimmer(
            child: Container(
              height: 100,
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

  Widget _buildEmptyGroupsState(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(LucideIcons.users, size: 40, color: colors.textMuted),
          const SizedBox(height: 8),
          Text(
            tr.noMatchingGroupsTitle,
            style: AppTextStyle.bold(color: colors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            tr.noMatchingGroupsSubtitle,
            style: AppTextStyle.regular(color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AnalyticsTabState state) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            state.errorMessage ?? tr.loadAnalyticsFailed,
            style: AppTextStyle.regular(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => context.read<AnalyticsTabCubit>().loadOverview(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: Text(tr.retryAction),
          ),
        ],
      ),
    );
  }
}
