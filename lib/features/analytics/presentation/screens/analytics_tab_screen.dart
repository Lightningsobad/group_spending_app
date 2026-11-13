import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../groups/data/models/group_summary_model.dart';
import '../../../groups/presentation/widgets/group_filter_chip.dart';
import '../cubit/analytics_tab_cubit.dart';
import '../cubit/analytics_tab_state.dart';
import '../widgets/analytics_group_card.dart';
import '../../../main_shell/presentation/widgets/main_tab_app_bar.dart';

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

  void _onGroupTap(GroupSummaryModel group) {
    if (widget.onNavigateToGroupAnalytics != null) {
      widget.onNavigateToGroupAnalytics!(group.id);
    } else {
      final queryParams = <String, String>{
        'name': group.name,
        if (group.category != null && group.category!.trim().isNotEmpty)
          'category': group.category!,
        'memberCount': group.memberCount.toString(),
      };
      final uri = Uri(
        path: '/groups/${group.id}/analytics',
        queryParameters: queryParams,
      );
      context.push(uri.toString());
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
          AppSnackBar.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainTabAppBar(
                  icon: LucideIcons.barChart3,
                  title: context.l10n.tabAnalyticsTitle,
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<AnalyticsTabCubit>().loadOverview(isRefresh: true),
                    color: colors.analyticsAccent,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                onTap: () => _onGroupTap(g),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            valueColor: colors.analyticsAccent,
          ),
        ),
        const SizedBox(width: 8),
        // Card 3: Số hóa đơn đã ghi
        Expanded(
          child: _buildMiniKpiCard(
            context,
            label: tr.totalInvoicesRecorded,
            value: '${state.overview.totalExpenses} ${tr.invoicesUnit}',
            valueColor: colors.badgeSuccessText,
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
            style: AppTextStyle.semiBold(
              color: colors.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyle.extraBold(
                color: valueColor,
                fontSize: 16,
              ),
              maxLines: 1,
            ),
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
      decoration: BoxDecoration(
        color: colors.bannerBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.bannerBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _onGlobalOverviewTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.analyticsAccent,
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
                    color: colors.analyticsAccent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GroupFilterChip(
            label: tr.filterAllCount(state.allCount),
            isSelected: state.filter == 'ALL',
            onTap: () => context.read<AnalyticsTabCubit>().setFilter('ALL'),
          ),
          const SizedBox(width: 8),
          GroupFilterChip(
            label: tr.filterActiveCount(state.activeCount),
            isSelected: state.filter == 'ACTIVE',
            onTap: () => context.read<AnalyticsTabCubit>().setFilter('ACTIVE'),
          ),
          const SizedBox(width: 8),
          GroupFilterChip(
            label: tr.filterArchivedCount(state.archivedCount),
            isSelected: state.filter == 'ARCHIVED',
            onTap: () => context.read<AnalyticsTabCubit>().setFilter('ARCHIVED'),
          ),
        ],
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
            letterSpacing: 0.3,
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
    final hasSearch = _searchController.text.trim().isNotEmpty;

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
          if (hasSearch) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                context.read<AnalyticsTabCubit>().setSearchQuery('');
              },
              icon: Icon(LucideIcons.x, size: 16, color: colors.analyticsAccent),
              label: Text(
                tr.clearSearchAction,
                style: AppTextStyle.bold(
                  color: colors.analyticsAccent,
                  fontSize: 13,
                ),
              ),
            ),
          ],
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
              backgroundColor: colors.analyticsAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(tr.retryAction),
          ),
        ],
      ),
    );
  }
}
