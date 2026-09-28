import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/presentation/cubit/groups_cubit.dart';
import '../../../groups/presentation/widgets/create_group_sheet.dart';
import '../../../groups/presentation/widgets/group_card_skeleton.dart';
import '../../../groups/presentation/widgets/group_card_widget.dart';
import '../../../groups/presentation/widgets/group_detail_sheet.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/widgets/join_group_sheet.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_empty_groups_view.dart';
import '../widgets/dashboard_groups_header.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/financial_balance_card.dart';
import '../widgets/financial_balance_card_skeleton.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardCubit>().loadDashboard();
    });
  }

  void _showAddExpenseNotice() {
    final tr = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(tr.addExpenseFeatureNotice),
        duration: const Duration(seconds: 2),
      ),
    );
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
        final isLoadingInitial = state.isLoading && state.groups.isEmpty;
        final groups = state.groups;

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
                  onAddExpense: _showAddExpenseNotice,
                  onCreateGroup: _openCreateGroup,
                  onJoinGroup: _openJoinGroup,
                ),

                const SizedBox(height: 20),

                // 3. Section Header
                DashboardGroupsHeader(
                  groupCount: groups.length,
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
