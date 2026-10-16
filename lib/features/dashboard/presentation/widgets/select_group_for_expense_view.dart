import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';
import '../../../groups/presentation/widgets/group_filter_chip.dart';

class SelectGroupForExpenseView extends StatefulWidget {
  final List<GroupModel> groups;
  final bool isLoading;
  final VoidCallback onBack;
  final ValueChanged<GroupModel> onGroupSelected;
  final VoidCallback onCreateGroup;

  const SelectGroupForExpenseView({
    super.key,
    required this.groups,
    this.isLoading = false,
    required this.onBack,
    required this.onGroupSelected,
    required this.onCreateGroup,
  });

  @override
  State<SelectGroupForExpenseView> createState() => _SelectGroupForExpenseViewState();
}

class _SelectGroupForExpenseViewState extends State<SelectGroupForExpenseView> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'ACTIVE'; // 'ACTIVE', 'ALL', 'ADMIN'
  String _categoryFilter = 'ALL'; // 'ALL' or specific category

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _availableCategories {
    final cats = <String>{};
    for (final g in widget.groups) {
      if (g.category.trim().isNotEmpty) {
        cats.add(g.category);
      }
    }
    return cats.toList();
  }

  List<GroupModel> get _filteredGroups {
    var result = widget.groups;

    // 1. Status / Role filter
    switch (_statusFilter) {
      case 'ACTIVE':
        result = result.where((g) => g.isActive).toList();
        break;
      case 'ADMIN':
        result = result.where((g) => g.isAdmin).toList();
        break;
      case 'ALL':
      default:
        break;
    }

    // 2. Category filter
    if (_categoryFilter != 'ALL') {
      result = result.where((g) => g.category == _categoryFilter).toList();
    }

    // 3. Search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((g) {
        final matchName = g.name.toLowerCase().contains(query);
        final matchDesc = (g.description ?? '').toLowerCase().contains(query);
        final matchCat = g.category.toLowerCase().contains(query);
        final matchCatLabel =
            GroupCategoryHelper.getShortLabel(g.category).toLowerCase().contains(query);
        return matchName || matchDesc || matchCat || matchCatLabel;
      }).toList();
    }

    return result;
  }

  void _handleGroupTap(GroupModel group) {
    if (group.isArchived) {
      AppSnackBar.show(
        context,
        message: context.l10n.cannotAddExpenseToArchivedGroup,
        type: AppSnackBarType.warning,
      );
      return;
    }
    widget.onGroupSelected(group);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.30,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: widget.isLoading
              ? _buildSkeleton(colors, tr)
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header: Back button + Title
                      _buildHeader(colors, tr),
                      const SizedBox(height: 16),

                      // 2. Search Text Field
                      _buildSearchBar(colors, tr),
                      const SizedBox(height: 14),

                      // 3. Filter Rows
                      _buildFilterRows(colors, tr),
                      const SizedBox(height: 16),

                      // 4. Group Cards List / Empty State
                      _buildGroupListOrEmpty(colors, tr),
                      const SizedBox(height: 16),

                      // 5. Bottom Action: "Chưa có nhóm phù hợp? [+ Tạo nhóm]"
                      _buildBottomAction(colors, tr),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(AppThemeColors colors, AppLocalizations tr) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header skeleton (Real interactive back button so user can exit)
            Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.onBack,
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Icon(
                        LucideIcons.arrowLeft,
                        size: 20,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const AppShimmerBox(
                  width: 200,
                  height: 22,
                  borderRadius: 6,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Search bar skeleton
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              child: Row(
                children: const [
                  AppShimmerBox(width: 20, height: 20, borderRadius: 10),
                  SizedBox(width: 12),
                  AppShimmerBox(width: 140, height: 14, borderRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Filter Row 1 skeleton
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: const [
                  AppShimmerBox(width: 110, height: 48, borderRadius: 20),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 90, height: 48, borderRadius: 20),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 100, height: 48, borderRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Filter Row 2 skeleton
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Row(
                children: const [
                  AppShimmerBox(width: 100, height: 48, borderRadius: 20),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 110, height: 48, borderRadius: 20),
                  SizedBox(width: 8),
                  AppShimmerBox(width: 85, height: 48, borderRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Group Card Skeletons (3 items)
            ...List.generate(3, (index) => _buildSkeletonCard(colors)),
            const SizedBox(height: 16),

            // 6. Bottom action skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                AppShimmerBox(width: 140, height: 14, borderRadius: 4),
                AppShimmerBox(width: 110, height: 48, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(AppThemeColors colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [colors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                AppShimmerBox(width: 150, height: 16, borderRadius: 4),
                SizedBox(height: 6),
                AppShimmerBox(width: 65, height: 18, borderRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              AppShimmerBox(width: 55, height: 12, borderRadius: 4),
              SizedBox(height: 4),
              AppShimmerBox(width: 85, height: 16, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors colors, AppLocalizations tr) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onBack,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                size: 20,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tr.chooseGroupToAddExpenseTitle,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.h4,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppThemeColors colors, AppLocalizations tr) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: AppTextStyle.regular(
          fontSize: AppFontSize.secondary,
          color: colors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: tr.searchGroupByNameHint,
          hintStyle: AppTextStyle.regular(
            fontSize: AppFontSize.secondary,
            color: colors.textMuted,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            size: 18,
            color: colors.textMuted,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  splashRadius: 24,
                  icon: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRows(AppThemeColors colors, AppLocalizations tr) {
    final availableCategories = _availableCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter Row 1 (Status/Role)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GroupFilterChip(
                label: tr.filterActiveOnly,
                isSelected: _statusFilter == 'ACTIVE',
                onTap: () => setState(() => _statusFilter = 'ACTIVE'),
              ),
              const SizedBox(width: 8),
              GroupFilterChip(
                label: tr.filterAllGroupsOnly,
                isSelected: _statusFilter == 'ALL',
                onTap: () => setState(() => _statusFilter = 'ALL'),
              ),
              const SizedBox(width: 8),
              GroupFilterChip(
                label: tr.filterAdminOnly,
                isSelected: _statusFilter == 'ADMIN',
                onTap: () => setState(() => _statusFilter = 'ADMIN'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Filter Row 2 (Category/Topic)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GroupFilterChip(
                label: tr.filterAllTopicsOnly,
                isSelected: _categoryFilter == 'ALL',
                onTap: () => setState(() => _categoryFilter = 'ALL'),
              ),
              for (final cat in availableCategories) ...[
                const SizedBox(width: 8),
                GroupFilterChip(
                  label: GroupCategoryHelper.getShortLabel(cat),
                  isSelected: _categoryFilter == cat,
                  onTap: () => setState(() => _categoryFilter = cat),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupListOrEmpty(AppThemeColors colors, AppLocalizations tr) {
    final filtered = _filteredGroups;

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.users,
              size: 40,
              color: colors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              tr.noMatchingGroupsTitle,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.body,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              tr.noMatchingGroupsSubtitle,
              style: AppTextStyle.regular(
                fontSize: AppFontSize.secondary,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: filtered
          .map(
            (group) => _buildGroupCard(
              group: group,
              colors: colors,
              tr: tr,
              onTap: () => _handleGroupTap(group),
            ),
          )
          .toList(),
    );
  }

  Widget _buildGroupCard({
    required GroupModel group,
    required AppThemeColors colors,
    required AppLocalizations tr,
    required VoidCallback onTap,
  }) {
    final isArchived = group.isArchived;
    final balance = group.userBalance;
    final Color balanceColor;
    if (balance > 0) {
      balanceColor = colors.debtReceiveAmount;
    } else if (balance < 0) {
      balanceColor = colors.debtOweAmount;
    } else {
      balanceColor = colors.textMuted;
    }
    final balanceText = CurrencyUtils.formatVnd(balance, showSign: true);

    return Opacity(
      opacity: isArchived ? 0.75 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
          boxShadow: [colors.cardShadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Leading Category Icon Box
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    alignment: Alignment.center,
                    child: GroupCategoryHelper.buildIcon(
                      group.category,
                      width: 26,
                      height: 26,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle: Group Name & Admin badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.body,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (group.isAdmin) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.adminBadgeBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.adminBadgeBorder,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.shieldCheck,
                                    size: 13,
                                    color: colors.adminBadgeText,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Admin',
                                    style: AppTextStyle.bold(
                                      fontSize: AppFontSize.caption,
                                      color: colors.adminBadgeText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Trailing: Balance
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          tr.balanceLabel,
                          style: AppTextStyle.regular(
                            fontSize: AppFontSize.caption,
                            color: colors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            balanceText,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.secondary,
                              color: balanceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction(AppThemeColors colors, AppLocalizations tr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            tr.noSuitableGroupQuestion,
            style: AppTextStyle.regular(
              fontSize: AppFontSize.secondary,
              color: colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: widget.onCreateGroup,
          icon: Icon(
            LucideIcons.plus,
            size: 16,
            color: colors.secondaryActionText,
          ),
          label: Text(
            tr.createGroupAction,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.secondary,
              color: colors.secondaryActionText,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.secondaryActionBorder),
            backgroundColor: colors.secondaryActionBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }
}
