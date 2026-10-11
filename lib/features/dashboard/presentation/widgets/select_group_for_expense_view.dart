import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';

class SelectGroupForExpenseView extends StatefulWidget {
  final List<GroupModel> groups;
  final VoidCallback onBack;
  final ValueChanged<GroupModel> onGroupSelected;
  final VoidCallback onCreateGroup;

  const SelectGroupForExpenseView({
    super.key,
    required this.groups,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cannotAddExpenseToArchivedGroup),
          backgroundColor: Colors.amber[800],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    widget.onGroupSelected(group);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final filtered = _filteredGroups;
    final availableCategories = _availableCategories;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header: Back button + Title
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
                Expanded(
                  child: Text(
                    tr.chooseGroupToAddExpenseTitle,
                    style: AppTextStyle.bold(
                      fontSize: 18,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Search Text Field
            Container(
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: AppTextStyle.regular(
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên nhóm...',
                  hintStyle: AppTextStyle.regular(
                    fontSize: 14,
                    color: colors.textMuted,
                  ),
                  prefixIcon: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: colors.textMuted,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
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
            ),
            const SizedBox(height: 14),

            // 3. Filter Row 1 (Status/Role)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: tr.filterActiveOnly,
                    isSelected: _statusFilter == 'ACTIVE',
                    onTap: () => setState(() => _statusFilter = 'ACTIVE'),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: tr.filterAllGroupsOnly,
                    isSelected: _statusFilter == 'ALL',
                    onTap: () => setState(() => _statusFilter = 'ALL'),
                    colors: colors,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: tr.filterAdminOnly,
                    isSelected: _statusFilter == 'ADMIN',
                    onTap: () => setState(() => _statusFilter = 'ADMIN'),
                    colors: colors,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. Filter Row 2 (Category/Topic)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: tr.filterAllTopicsOnly,
                    isSelected: _categoryFilter == 'ALL',
                    onTap: () => setState(() => _categoryFilter = 'ALL'),
                    colors: colors,
                  ),
                  for (final cat in availableCategories) ...[
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: GroupCategoryHelper.getShortLabel(cat),
                      isSelected: _categoryFilter == cat,
                      onTap: () => setState(() => _categoryFilter = cat),
                      colors: colors,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Group Cards List / Empty State
            if (filtered.isEmpty)
              Container(
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
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr.noMatchingGroupsSubtitle,
                      style: AppTextStyle.regular(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...filtered.map(
                (group) => _buildGroupCard(
                  group: group,
                  colors: colors,
                  tr: tr,
                  onTap: () => _handleGroupTap(group),
                ),
              ),

            const SizedBox(height: 16),

            // 6. Bottom Action: "Chưa có nhóm phù hợp? [+ Tạo nhóm mới]"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr.noSuitableGroupQuestion,
                  style: AppTextStyle.regular(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: widget.onCreateGroup,
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 16,
                    color: Color(0xFF15803D),
                  ),
                  label: Text(
                    tr.createGroupAction,
                    style: AppTextStyle.bold(
                      fontSize: 13,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    backgroundColor: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeColors colors,
  }) {
    final bgColor = isSelected ? const Color(0xFF166534) : colors.surfaceMuted;
    final textColor = isSelected ? Colors.white : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: colors.cardBorder),
          ),
          child: Text(
            label,
            style: AppTextStyle.bold(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ),
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
      balanceColor = const Color(0xFF10B981);
    } else if (balance < 0) {
      balanceColor = const Color(0xFFEF4444);
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
                            fontSize: 15,
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.shieldCheck,
                                  size: 12,
                                  color: colors.adminBadgeText,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Admin',
                                  style: AppTextStyle.bold(
                                    fontSize: 11,
                                    color: colors.adminBadgeText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Trailing: Balance
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         tr.balanceLabel,
                         style: AppTextStyle.regular(
                           fontSize: 12,
                           color: colors.textMuted,
                         ),
                       ),
                      const SizedBox(height: 2),
                      Text(
                        balanceText,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: balanceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
