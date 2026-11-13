import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/group_model.dart';
import '../cubit/groups_cubit.dart';
import 'group_category_helper.dart';

class GroupDetailSheet extends StatefulWidget {
  final GroupModel initialGroup;

  const GroupDetailSheet({super.key, required this.initialGroup});

  static Future<void> show(BuildContext context, GroupModel group) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<GroupsCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
        child: GroupDetailSheet(initialGroup: group),
      ),
    );
  }

  @override
  State<GroupDetailSheet> createState() => _GroupDetailSheetState();
}

class _GroupDetailSheetState extends State<GroupDetailSheet> {
  late GroupModel _group;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
    _fetchLatestDetail();
  }

  Future<void> _fetchLatestDetail() async {
    setState(() => _isLoadingDetail = true);
    final currentId = _group.id;
    final detail = await context.read<GroupsCubit>().loadGroupDetails(currentId);
    if (mounted && detail != null && detail.id == currentId && _group.id == currentId) {
      setState(() {
        _group = detail;
        _isLoadingDetail = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingDetail = false);
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    AppSnackBar.showSuccess(
      context,
      '${context.l10n.groupInviteCodePrefix} $code',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _confirmArchive() async {
    final tr = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.archiveGroupConfirmTitle),
        content: Text(tr.archiveGroupConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.archiveConfirmButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<GroupsCubit>().archiveGroup(_group.id);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _confirmDelete() async {
    final tr = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.deleteGroupConfirmTitle),
        content: Text(tr.deleteGroupConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.deleteConfirmButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<GroupsCubit>().deleteGroup(_group.id);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showEditDialog() {
    final tr = context.l10n;
    final nameCtrl = TextEditingController(text: _group.name);
    final descCtrl = TextEditingController(text: _group.description ?? '');
    String category = _group.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(tr.editGroupTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: tr.groupNameLabel),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(labelText: tr.groupDescLabel),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: InputDecoration(labelText: tr.groupCategoryLabel),
                    items: GroupCategoryHelper.categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GroupCategoryHelper.buildIcon(c, context: context, width: 20, height: 20),
                            const SizedBox(width: 8),
                            Text(GroupCategoryHelper.getLabel(c, context)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(tr.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.emerald),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.of(ctx).pop();
                  final trimmedDesc = descCtrl.text.trim();
                  final isDescEmpty = trimmedDesc.isEmpty;
                  final success = await context.read<GroupsCubit>().updateGroup(
                        _group.id,
                        name: nameCtrl.text.trim(),
                        description: isDescEmpty ? null : trimmedDesc,
                        clearDescription: isDescEmpty,
                        category: category,
                      );
                  if (success && mounted) {
                    _fetchLatestDetail();
                  }
                },
                child: Text(tr.saveChanges, style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final currentUserId = context.watch<AuthCubit>().state.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == _group.ownerId;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                GroupCategoryHelper.buildCategoryBadge(
                  context,
                  _group.category,
                  size: 52,
                  borderRadius: 18,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _group.name,
                        style: AppTextStyle.bold(
                          fontSize: 18,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        GroupCategoryHelper.getLabel(_group.category, context),
                        style: AppTextStyle.medium(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: colors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Status & Description
                if (_group.description != null && _group.description!.isNotEmpty) ...[
                  Text(
                    _group.description!,
                    style: AppTextStyle.regular(
                      fontSize: 14,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Invite Code Box
                if (_group.inviteCode != null && _group.inviteCode!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.inviteCodeCardTitle,
                              style: AppTextStyle.bold(
                                fontSize: 10,
                                color: colors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _group.inviteCode!,
                              style: AppTextStyle.bold(
                                fontSize: 18,
                                color: AppColors.emeraldForest,
                              ),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.emerald),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _copyInviteCode(_group.inviteCode!),
                          icon: const Icon(LucideIcons.copy, size: 14, color: AppColors.emerald),
                          label: Text(
                            tr.copyCodeTooltip,
                            style: AppTextStyle.bold(fontSize: 12, color: AppColors.emerald),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 18),

                // Financial Overview Tile
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.groupFinancialOverviewTitle,
                        style: AppTextStyle.bold(fontSize: 11, color: colors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tr.yourBalanceLabel, style: AppTextStyle.regular(fontSize: 13, color: colors.textSecondary)),
                          Text(
                            CurrencyUtils.formatVnd(_group.userBalance, showSign: true),
                            style: AppTextStyle.bold(
                              fontSize: 14,
                              color: _group.userBalance > 0
                                  ? const Color(0xFF10B981)
                                  : _group.userBalance < 0
                                      ? const Color(0xFFEF4444)
                                      : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (_group.totalSpendingVnd != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr.totalGroupSpendingLabel, style: AppTextStyle.regular(fontSize: 13, color: colors.textSecondary)),
                            Text(
                              CurrencyUtils.formatVnd(_group.totalSpendingVnd!),
                              style: AppTextStyle.bold(fontSize: 14, color: colors.textPrimary),
                            ),
                          ],
                        ),
                      ],
                      if (_group.totalFundCollectedVnd != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tr.totalFundCollectedLabel, style: AppTextStyle.regular(fontSize: 13, color: colors.textSecondary)),
                            Text(
                              CurrencyUtils.formatVnd(_group.totalFundCollectedVnd!),
                              style: AppTextStyle.bold(fontSize: 14, color: AppColors.emerald),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Members List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tr.groupMembersCountTitle(_group.members?.length ?? _group.memberCount),
                      style: AppTextStyle.bold(fontSize: 12, color: colors.textSecondary),
                    ),
                    if (_isLoadingDetail)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_group.members != null && _group.members!.isNotEmpty)
                  ..._group.members!.map((member) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.emerald.withValues(alpha: 0.15),
                            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                                ? NetworkImage(member.avatarUrl!)
                                : null,
                            child: member.avatarUrl == null
                                ? Text(
                                    member.fullName.isNotEmpty ? member.fullName[0].toUpperCase() : '?',
                                    style: AppTextStyle.bold(fontSize: 14, color: AppColors.emeraldForest),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.fullName,
                                  style: AppTextStyle.bold(fontSize: 14, color: colors.textPrimary),
                                ),
                                if (member.email != null)
                                  Text(
                                    member.email!,
                                    style: AppTextStyle.regular(fontSize: 12, color: colors.textMuted),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: member.isAdmin ? AppColors.roleAdminBg : colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              member.isAdmin ? 'ADMIN' : tr.roleMember.toUpperCase(),
                              style: AppTextStyle.bold(
                                fontSize: 9,
                                color: member.isAdmin ? AppColors.roleAdminText : colors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                else
                  Text(
                    tr.groupMemberCountSimple(_group.memberCount),
                    style: AppTextStyle.regular(fontSize: 13, color: colors.textSecondary),
                  ),

                const SizedBox(height: 24),

                // Admin Controls (Section 4.1 & 4.2)
                if (_group.isAdmin && !_group.isArchived) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: colors.cardBorder),
                          ),
                          onPressed: _showEditDialog,
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          label: Text(tr.editGroupAction),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.amber.shade400),
                          ),
                          onPressed: _confirmArchive,
                          icon: Icon(LucideIcons.archive, size: 16, color: Colors.amber.shade800),
                          label: Text(
                            tr.archiveConfirmButton,
                            style: TextStyle(color: Colors.amber.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Delete group button (Owner only as per doc 4.1)
                if (isOwner)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: _confirmDelete,
                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                    label: Text(tr.deleteGroupPermanently, style: const TextStyle(color: AppColors.error)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
