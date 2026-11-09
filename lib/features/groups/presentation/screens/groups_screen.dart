import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/groups_cubit.dart';
import '../cubit/groups_state.dart';
import '../../data/models/group_model.dart';
import '../widgets/create_group_sheet.dart';
import '../widgets/group_card_skeleton.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/group_detail_view.dart';
import '../widgets/groups_empty_view.dart';
import '../widgets/groups_filter_bar.dart';
import '../widgets/groups_search_bar.dart';
import '../widgets/join_group_view.dart';
import '../../../main_shell/presentation/widgets/main_tab_app_bar.dart';

class GroupsScreen extends StatefulWidget {
  final bool initialShowJoin;
  final VoidCallback? onNavigateToDebts;
  final ValueChanged<bool>? onDeepViewChanged;

  const GroupsScreen({
    super.key,
    this.initialShowJoin = false,
    this.onNavigateToDebts,
    this.onDeepViewChanged,
  });

  @override
  State<GroupsScreen> createState() => GroupsScreenState();
}

class GroupsScreenState extends State<GroupsScreen> {
  final _searchController = TextEditingController();
  late bool _isJoiningGroup;
  GroupModel? _selectedGroup;
  VoidCallback? _onBackFromJoin;

  bool get isDeepView => _selectedGroup != null || _isJoiningGroup;

  @override
  void initState() {
    super.initState();
    _isJoiningGroup = widget.initialShowJoin;
    final cubit = context.read<GroupsCubit>();
    if (cubit.state.status == GroupsStatus.initial) {
      cubit.loadGroups();
    }
    if (_isJoiningGroup) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _notifyDeepView());
    }
  }

  void _notifyDeepView() {
    widget.onDeepViewChanged?.call(isDeepView);
  }

  void openGroupDetail(GroupModel group) {
    setState(() {
      _selectedGroup = group;
      _isJoiningGroup = false;
    });
    context.read<GroupsCubit>().selectGroup(group);
    _notifyDeepView();
  }

  void closeGroupDetail() {
    setState(() {
      _selectedGroup = null;
    });
    context.read<GroupsCubit>().clearSelectedGroup();
    _notifyDeepView();
  }

  void openJoinGroup([VoidCallback? onBack]) {
    setState(() {
      _isJoiningGroup = true;
      _onBackFromJoin = onBack;
    });
    _notifyDeepView();
  }

  void closeJoinGroup([bool executeBackHandler = true]) {
    final customBack = executeBackHandler ? _onBackFromJoin : null;
    setState(() {
      _isJoiningGroup = false;
      _onBackFromJoin = null;
    });
    _notifyDeepView();
    customBack?.call();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return BlocConsumer<GroupsCubit, GroupsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
          context.read<GroupsCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          AppSnackBar.showSuccess(context, state.successMessage!);
          context.read<GroupsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        if (_selectedGroup != null) {
          final latestSelected = state.groups.cast<GroupModel?>().firstWhere(
                (g) => g?.id == _selectedGroup!.id,
                orElse: () => null,
              ) ??
              _selectedGroup!;
          return GroupDetailView(
            key: ValueKey(latestSelected.id),
            initialGroup: latestSelected,
            onBack: closeGroupDetail,
            onNavigateToDebts: widget.onNavigateToDebts,
          );
        }

        if (_isJoiningGroup) {
          return JoinGroupView(
            onBack: closeJoinGroup,
            onSuccess: () {
              closeJoinGroup(false);
              final latestGroup =
                  context.read<GroupsCubit>().state.groups.firstOrNull;
              if (latestGroup != null) {
                openGroupDetail(latestGroup);
              }
            },
          );
        }

        final filteredGroups = state.filteredGroups;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                MainTabAppBar(
                  icon: LucideIcons.users,
                  title: tr.groupListHeaderTitle,
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: colors.primaryButton,
                    onRefresh: () => context.read<GroupsCubit>().loadGroups(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Text Field
                          GroupsSearchBar(
                            controller: _searchController,
                            onChanged: (val) {
                              context.read<GroupsCubit>().setSearchQuery(val);
                            },
                            onClear: () {
                              _searchController.clear();
                              context.read<GroupsCubit>().setSearchQuery('');
                            },
                          ),
                const SizedBox(height: 14),

                // 3. Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryButton,
                          foregroundColor: colors.onPrimaryButton,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => CreateGroupSheet.show(
                          context,
                          onSuccessWithGroup: (newGroup) {
                            openGroupDetail(newGroup);
                          },
                        ),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: Text(
                          tr.createGroupAction,
                          style: AppTextStyle.bold(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: colors.cardBackground,
                          foregroundColor: colors.textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: colors.cardBorder),
                        ),
                        onPressed: openJoinGroup,
                        icon: Icon(
                          LucideIcons.qrCode,
                          size: 18,
                          color: colors.onPrimaryContainer,
                        ),
                        label: Text(
                          tr.codeOrQrAction,
                          style: AppTextStyle.bold(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Filter Chips Bar
                GroupsFilterBar(
                  activeFilter: state.activeFilter,
                  activeCategory: state.activeCategory,
                  totalCount: state.totalCount,
                  activeCount: state.activeCount,
                  archivedCount: state.archivedCount,
                  adminCount: state.adminCount,
                  onFilterChanged: (filterKey) {
                    context.read<GroupsCubit>().setFilter(filterKey);
                  },
                  onCategoryChanged: (categoryKey) {
                    context.read<GroupsCubit>().setCategory(categoryKey);
                  },
                ),
                const SizedBox(height: 16),

                // 5. Groups List or Skeletons or Empty State
                if ((state.status == GroupsStatus.initial || state.isLoading) &&
                    state.groups.isEmpty)
                  ...List.generate(3, (index) => const GroupCardSkeleton())
                else if (filteredGroups.isEmpty)
                  GroupsEmptyView(
                    isSearching: state.searchQuery.isNotEmpty ||
                        state.activeCategory != 'ALL' ||
                        state.activeFilter != 'ALL',
                  )
                else
                  ...filteredGroups.map(
                    (group) => GroupCardWidget(
                      group: group,
                      onTap: () => openGroupDetail(group),
                      onToggleMute: () {
                        AppSnackBar.showInfo(
                          context,
                          tr.notificationsToggledForGroup(group.name),
                          duration: const Duration(seconds: 1),
                        );
                      },
                    ),
                  ),
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
}
