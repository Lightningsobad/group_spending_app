import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../groups/data/models/group_model.dart';
import '../cubit/funds_cubit.dart';
import '../cubit/funds_state.dart';
import 'fund_card_widget.dart';
import 'fund_filter_bar.dart';
import 'fund_overview_card.dart';

class GroupFundsTabView extends StatefulWidget {
  final GroupModel group;

  const GroupFundsTabView({
    super.key,
    required this.group,
  });

  @override
  State<GroupFundsTabView> createState() => _GroupFundsTabViewState();
}

class _GroupFundsTabViewState extends State<GroupFundsTabView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FundsCubit>().loadGroupFunds(widget.group.id);
      }
    });
  }

  @override
  void didUpdateWidget(covariant GroupFundsTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group.id != widget.group.id) {
      _searchController.clear();
      context.read<FundsCubit>().loadGroupFunds(widget.group.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateFund() {
    context.push(
      '/groups/${widget.group.id}/funds/create',
      extra: widget.group,
    );
  }

  void _openFundDetails(int fundId) {
    context.push(
      '/groups/${widget.group.id}/funds/$fundId',
      extra: widget.group,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return BlocBuilder<FundsCubit, FundsState>(
      builder: (context, state) {
        final overview = state.overview;
        final filteredFunds = state.filteredFunds;
        final isLoading = state.isLoading && overview == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Overview Card ("TỔNG TIỀN QUỸ CHUNG")
            FundOverviewCard(
              overview: overview,
              isAdmin: widget.group.isAdmin,
              onNewFundTap: _openCreateFund,
            ),
            const SizedBox(height: 14),

            // 2. Search Bar
            Container(
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => context.read<FundsCubit>().setSearchQuery(val),
                style: AppTextStyle.medium(fontSize: 13, color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: tr.searchFundPlaceholder,
                  hintStyle: AppTextStyle.regular(fontSize: 13, color: colors.textMuted),
                  prefixIcon: Icon(LucideIcons.search, size: 18, color: colors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(LucideIcons.x, size: 16, color: colors.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            context.read<FundsCubit>().setSearchQuery('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Filter Bar (Status & Time)
            FundFilterBar(
              selectedStatus: state.selectedStatusFilter,
              selectedTime: state.selectedTimeFilter,
              totalCount: state.totalFundsCount,
              collectingCount: state.collectingCount,
              completedCount: state.completedCount,
              filteredCount: filteredFunds.length,
              onStatusChanged: (status) =>
                  context.read<FundsCubit>().setStatusFilter(status),
              onTimeChanged: (time) =>
                  context.read<FundsCubit>().setTimeFilter(time),
            ),
            const SizedBox(height: 16),

            // 4. Fund Collection Items List
            if (isLoading) ...[
              _buildShimmerList(colors),
            ] else if (filteredFunds.isEmpty) ...[
              _buildEmptyState(colors, tr),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFunds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, index) {
                  final fund = filteredFunds[index];
                  return FundCardWidget(
                    fund: fund,
                    onTap: () => _openFundDetails(fund.id),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(dynamic colors, dynamic tr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.piggyBank,
              size: 36,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            tr.fundEmptyList,
            style: AppTextStyle.bold(
              fontSize: 15,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            tr.fundEmptySubtitle,
            style: AppTextStyle.regular(
              fontSize: 12,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(dynamic colors) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Row(
            children: [
              AppShimmer(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(
                      child: Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppShimmer(
                      child: Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
