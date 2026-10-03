import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../groups/presentation/cubit/groups_state.dart';
import '../../../groups/presentation/widgets/create_group_sheet.dart';
import '../../../groups/presentation/widgets/group_card_skeleton.dart';
import '../../../groups/presentation/widgets/group_card_widget.dart';
import '../../../groups/presentation/widgets/group_detail_sheet.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/widgets/join_group_sheet.dart';
import '../../../expenses/presentation/screens/add_expense_screen.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_empty_groups_view.dart';
import '../widgets/dashboard_groups_header.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/financial_balance_card.dart';
import '../widgets/financial_balance_card_skeleton.dart';
import '../widgets/select_group_for_expense_view.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGroups;
  final VoidCallback? onNavigateToJoinGroup;
  final void Function(GroupModel group)? onNavigateToGroupDetail;

  const DashboardScreen({
    super.key,
    this.onNavigateToGroups,
    this.onNavigateToJoinGroup,
    this.onNavigateToGroupDetail,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSelectingGroupForExpense = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    if (cubit.state.status == DashboardStatus.initial) {
      cubit.loadDashboard();
    }
  }

  void _onAddExpensePressed() {
    setState(() {
      _isSelectingGroupForExpense = true;
    });
    try {
      final groupsCubit = context.read<GroupsCubit>();
      if (groupsCubit.state.status == GroupsStatus.initial) {
        groupsCubit.loadGroups();
      }
    } catch (_) {}
  }

  Future<void> _handleGroupSelectedForExpense(GroupModel group) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(group: group),
      ),
    );
    if (result == true && mounted) {
      setState(() {
        _isSelectingGroupForExpense = false;
      });
    }
  }

  void _openCreateGroup() {
    CreateGroupSheet.show(context);
  }

  void _openJoinGroup() {
    if (widget.onNavigateToJoinGroup != null) {
      widget.onNavigateToJoinGroup!();
    } else {
      JoinGroupSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        List<GroupModel> groups = state.groups;
        try {
          final groupsFromCubit = context.watch<GroupsCubit>().state.groups;
          if (groupsFromCubit.isNotEmpty) {
            groups = groupsFromCubit;
          }
        } catch (_) {}

        if (_isSelectingGroupForExpense) {
          return SelectGroupForExpenseView(
            groups: groups,
            onBack: () => setState(() => _isSelectingGroupForExpense = false),
            onGroupSelected: _handleGroupSelectedForExpense,
            onCreateGroup: _openCreateGroup,
          );
        }

        final isLoadingInitial =
            (state.status == DashboardStatus.initial || state.isLoading) &&
                groups.isEmpty;

        return RefreshIndicator(
          color: AppColors.emerald,
          onRefresh: () async {
            await context.read<DashboardCubit>().loadDashboard(isRefresh: true);
            if (context.mounted) {
              await context.read<GroupsCubit>().loadGroups(silent: true);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Financial balance card or skeleton
                if (isLoadingInitial)
                  const FinancialBalanceCardSkeleton()
                else
                  FinancialBalanceCard(
                    totalOwedVnd: state.debtOverview.totalOwedVnd,
                    totalReceivableVnd: state.debtOverview.totalReceivableVnd,
                  ),

                const SizedBox(height: 16),

                // 2. Quick action buttons
                DashboardQuickActions(
                  onAddExpense: _onAddExpensePressed,
                  onCreateGroup: _openCreateGroup,
                  onJoinGroup: _openJoinGroup,
                ),

                const SizedBox(height: 20),

                // 3. Section Header
                DashboardGroupsHeader(
                  groupCount: groups.length,
                  isLoading: isLoadingInitial,
                  onSeeAll: widget.onNavigateToGroups,
                ),

                const SizedBox(height: 12),

                // 4. Groups list, skeleton, or empty state
                if (isLoadingInitial) ...[
                  const GroupCardSkeleton(),
                  const GroupCardSkeleton(),
                ] else if (groups.isEmpty)
                  DashboardEmptyGroupsView(
                    onCreateGroup: _openCreateGroup,
                  )
                else
                  ...groups.map(
                    (group) => GroupCardWidget(
                      group: group,
                      onTap: () {
                        if (widget.onNavigateToGroupDetail != null) {
                          widget.onNavigateToGroupDetail!(group);
                        } else {
                          GroupDetailSheet.show(context, group);
                        }
                      },
                      onToggleMute: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr.notificationsToggledForGroup(group.name),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
