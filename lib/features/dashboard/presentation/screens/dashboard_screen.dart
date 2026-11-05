import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
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
import '../../../main_shell/presentation/widgets/app_header.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToGroups;
  final VoidCallback? onNavigateToJoinGroup;
  final void Function(GroupModel group)? onNavigateToGroupDetail;
  final VoidCallback? onNavigateToSettings;

  const DashboardScreen({
    super.key,
    this.onNavigateToGroups,
    this.onNavigateToJoinGroup,
    this.onNavigateToGroupDetail,
    this.onNavigateToSettings,
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
    GroupsCubit? groupsCubit;
    try {
      groupsCubit = context.read<GroupsCubit>();
    } catch (_) {}

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => groupsCubit != null
            ? BlocProvider<GroupsCubit>.value(
                value: groupsCubit,
                child: AddExpenseScreen(group: group),
              )
            : AddExpenseScreen(group: group),
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

    return PopScope(
      canPop: !_isSelectingGroupForExpense,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectingGroupForExpense) {
          setState(() {
            _isSelectingGroupForExpense = false;
          });
        }
      },
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.35,
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            // ponytail: Syncing groups from GroupsCubit in build() as fallback until unified in a shared repository stream.
            List<GroupModel> groups = state.groups;
            bool isGroupsLoading =
                (state.status == DashboardStatus.initial || state.isLoading) &&
                    groups.isEmpty;
            try {
              final groupsState = context.watch<GroupsCubit>().state;
              if (groupsState.groups.isNotEmpty) {
                groups = groupsState.groups;
              }
              if (groupsState.isLoading && groups.isEmpty) {
                isGroupsLoading = true;
              }
            } catch (_) {}

            if (_isSelectingGroupForExpense) {
              return SelectGroupForExpenseView(
                groups: groups,
                isLoading: isGroupsLoading,
                onBack: () => setState(() => _isSelectingGroupForExpense = false),
                onGroupSelected: _handleGroupSelectedForExpense,
                onCreateGroup: _openCreateGroup,
              );
            }

            final isLoadingInitial = isGroupsLoading;

            return SafeArea(
              bottom: false,
              child: Column(
                children: [
                  AppHeader(onProfileTap: widget.onNavigateToSettings),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.emerald,
                      onRefresh: () async {
                        await context.read<DashboardCubit>().loadDashboard(isRefresh: true);
                        if (context.mounted) {
                          try {
                            await context.read<GroupsCubit>().loadGroups(silent: true);
                          } catch (_) {}
                        }
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(16, 12, 16, groups.isEmpty ? 90 : 0),
                            sliver: SliverToBoxAdapter(
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

                                  // 4. Skeleton or empty state
                                  if (isLoadingInitial) ...[
                                    const GroupCardSkeleton(),
                                    const GroupCardSkeleton(),
                                  ] else if (groups.isEmpty)
                                    DashboardEmptyGroupsView(
                                      onCreateGroup: _openCreateGroup,
                                    ),
                                ],
                              ),
                            ),
                          ),

                          // 5. Lazy list of groups
                          if (!isLoadingInitial && groups.isNotEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              sliver: SliverList.builder(
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  final group = groups[index];
                                  return GroupCardWidget(
                                    key: ValueKey(group.id),
                                    group: group,
                                    onTap: () {
                                      if (widget.onNavigateToGroupDetail != null) {
                                        widget.onNavigateToGroupDetail!(group);
                                      } else {
                                        GroupDetailSheet.show(context, group);
                                      }
                                    },
                                    onToggleMute: () {
                                      AppSnackBar.showInfo(
                                        context,
                                        tr.notificationsToggledForGroup(group.name),
                                        duration: const Duration(seconds: 1),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
