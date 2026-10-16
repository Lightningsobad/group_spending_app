import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';
import '../widgets/debts_empty_view.dart';
import '../widgets/debts_filter_bar.dart';
import '../widgets/debts_header_title.dart';
import '../widgets/debts_search_bar.dart';
import '../widgets/debts_summary_cards.dart';
import '../widgets/group_debt_card_skeleton.dart';
import '../widgets/group_debt_card_widget.dart';
import 'group_debt_detail_view.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DebtsCubit>().loadOverview();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DebtsCubit, DebtsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
          context.read<DebtsCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          AppSnackBar.showSuccess(context, state.successMessage!);
          context.read<DebtsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        // If a group is selected, display the Group Debt Detail View
        if (state.selectedGroupId != null) {
          return GroupDebtDetailView(
            groupId: state.selectedGroupId!,
            groupName: state.selectedGroupName,
          );
        }

        final cubit = context.read<DebtsCubit>();
        final colors = context.colors;
        final filteredGroups = state.filteredGroupBalances;
        final overview = state.overview;

        return MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.35,
          child: RefreshIndicator(
            color: colors.brandEmerald,
            onRefresh: () => cubit.loadOverview(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Title: Icon layers + "Công nợ theo nhóm"
                const DebtsHeaderTitle(),
                const SizedBox(height: 16),

                // 2. Summary Balance Cards: "Bạn đang nợ" & "Bạn nhận"
                DebtsSummaryCards(
                  totalOwedVnd: overview?.totalOwedVnd ?? 0,
                  totalReceivableVnd: overview?.totalReceivableVnd ?? 0,
                  isLoading: state.isLoading && overview == null,
                ),
                const SizedBox(height: 14),

                // 3. Search Bar
                DebtsSearchBar(
                  controller: _searchController,
                  onChanged: (val) => cubit.setSearchQuery(val),
                  onClear: () {
                    _searchController.clear();
                    cubit.setSearchQuery('');
                  },
                ),
                const SizedBox(height: 14),

                // 4. Filter Chips Bar
                DebtsFilterBar(
                  activeFilter: state.activeFilter,
                  totalCount: state.totalGroupCount,
                  hasDebtCount: state.hasDebtGroupCount,
                  settledCount: state.settledGroupCount,
                  onFilterChanged: (filter) => cubit.setFilter(filter),
                ),
                const SizedBox(height: 16),

                // 5. Group Debt List or Loading Skeletons / Empty View
                if (state.isLoading && overview == null)
                  ...List.generate(
                    4,
                    (index) => const GroupDebtCardSkeleton(),
                  )
                else if (filteredGroups.isEmpty)
                  DebtsEmptyView(isSearching: state.searchQuery.isNotEmpty)
                else
                  ...filteredGroups.map(
                    (group) => GroupDebtCardWidget(
                      item: group,
                      onTap: () => cubit.selectGroup(
                        group.groupId,
                        groupName: group.groupName,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
    );
  }
}
