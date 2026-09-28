import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
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

class GroupsScreen extends StatefulWidget {
  final bool initialShowJoin;
  final VoidCallback? onNavigateToDebts;

  const GroupsScreen({
    super.key,
    this.initialShowJoin = false,
    this.onNavigateToDebts,
  });

  @override
  State<GroupsScreen> createState() => GroupsScreenState();
}

class GroupsScreenState extends State<GroupsScreen> {
  final _searchController = TextEditingController();
  late bool _isJoiningGroup;
  GroupModel? _selectedGroup;

  @override
  void initState() {
    super.initState();
    _isJoiningGroup = widget.initialShowJoin;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsCubit>().loadGroups();
    });
  }

  void openGroupDetail(GroupModel group) {
    setState(() {
      _selectedGroup = group;
      _isJoiningGroup = false;
    });
  }

  void closeGroupDetail() {
    setState(() {
      _selectedGroup = null;
    });
  }

  void openJoinGroup() {
    setState(() {
      _isJoiningGroup = true;
    });
  }

  void closeJoinGroup() {
    setState(() {
      _isJoiningGroup = false;
    });
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<GroupsCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.emerald,
            ),
          );
          context.read<GroupsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        if (_selectedGroup != null) {
          return GroupDetailView(
            initialGroup: _selectedGroup!,
            onBack: closeGroupDetail,
            onNavigateToDebts: widget.onNavigateToDebts,
          );
        }

        if (_isJoiningGroup) {
          return JoinGroupView(
            onBack: closeJoinGroup,
            onSuccess: closeJoinGroup,
          );
        }

        final filteredGroups = state.filteredGroups;

        return RefreshIndicator(
          color: AppColors.emerald,
          onRefresh: () => context.read<GroupsCubit>().loadGroups(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Title Header Pill
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        LucideIcons.users,
                        size: 22,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tr.groupListHeaderTitle,
                      style: AppTextStyle.bold(
                        fontSize: 18,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Search Text Field
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
                          backgroundColor: const Color(0xFF166534),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => CreateGroupSheet.show(context),
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: Text(
                          tr.createGroupAction,
                          style: AppTextStyle.bold(fontSize: 13),
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
                        icon: const Icon(
                          LucideIcons.qrCode,
                          size: 18,
                          color: Color(0xFF15803D),
                        ),
                        label: Text(
                          tr.codeOrQrAction,
                          style: AppTextStyle.bold(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 4. Filter Chips Bar
                GroupsFilterBar(
                  activeFilter: state.activeFilter,
                  totalCount: state.totalCount,
                  activeCount: state.activeCount,
                  archivedCount: state.archivedCount,
                  adminCount: state.adminCount,
                  onFilterChanged: (filterKey) {
                    context.read<GroupsCubit>().setFilter(filterKey);
                  },
                ),
                const SizedBox(height: 16),

                // 5. Groups List or Skeletons or Empty State
                if (state.isLoading && state.groups.isEmpty)
                  ...List.generate(3, (index) => const GroupCardSkeleton())
                else if (filteredGroups.isEmpty)
                  GroupsEmptyView(isSearching: state.searchQuery.isNotEmpty)
                else
                  ...filteredGroups.map(
                    (group) => GroupCardWidget(
                      group: group,
                      onTap: () => openGroupDetail(group),
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
