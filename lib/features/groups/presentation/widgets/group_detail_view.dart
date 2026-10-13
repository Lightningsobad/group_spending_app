import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/group_member_models.dart';
import '../../data/models/group_model.dart';
import '../../domain/repositories/groups_repository.dart';
import '../cubit/group_members_cubit.dart';
import '../cubit/groups_cubit.dart';
import 'create_group_sheet.dart';
import 'group_category_helper.dart';
import 'group_invite_qr_sheet.dart';
import 'group_overview_skeleton.dart';
import '../../../funds/presentation/cubit/funds_cubit.dart';
import '../../../funds/presentation/screens/fund_form_screen.dart';
import 'group_member_detail_view.dart';
import 'group_members_tab_view.dart';
import '../../../funds/presentation/widgets/group_funds_tab_view.dart';
import '../../../expenses/presentation/widgets/group_expenses_tab_view.dart';

class GroupDetailView extends StatefulWidget {
  final GroupModel initialGroup;
  final VoidCallback onBack;
  final VoidCallback? onNavigateToDebts;

  const GroupDetailView({
    super.key,
    required this.initialGroup,
    required this.onBack,
    this.onNavigateToDebts,
  });

  @override
  State<GroupDetailView> createState() => _GroupDetailViewState();
}

class _GroupDetailViewState extends State<GroupDetailView> {
  late GroupModel _group;
  int _selectedTabIndex = 0; // 0: Tổng quan, 1: Chi tiêu, 2: Quỹ, 3: Thành viên
  bool _isLoadingDetail = false;
  bool _isCreatingFund = false;
  int? _viewingMemberId;
  GroupMembersCubit? _groupMembersCubit;

  @override
  void initState() {
    super.initState();
    _group = widget.initialGroup;
    _isLoadingDetail = true;
    _fetchLatestDetail();
  }

  @override
  void dispose() {
    _groupMembersCubit?.close();
    super.dispose();
  }

  GroupMembersCubit _getOrCreateGroupMembersCubit([BuildContext? ctx]) {
    if (_groupMembersCubit != null) return _groupMembersCubit!;

    final currentContext = ctx ?? context;
    GroupsRepository repo;
    try {
      repo = currentContext.read<GroupsRepository>();
    } catch (_) {
      repo = _FallbackGroupsRepo(() => _group);
    }

    SessionCoordinator? session;
    try {
      session = currentContext.read<SessionCoordinator>();
    } catch (_) {}

    DataSyncCoordinator? dataSync;
    try {
      dataSync = currentContext.read<DataSyncCoordinator>();
    } catch (_) {}

    _groupMembersCubit = GroupMembersCubit(
      groupId: _group.id,
      isAdmin: _group.isAdmin,
      groupsRepository: repo,
      sessionCoordinator: session,
      dataSyncCoordinator: dataSync,
    );
    return _groupMembersCubit!;
  }

  Future<void> _fetchLatestDetail() async {
    setState(() => _isLoadingDetail = true);
    final detail = await context.read<GroupsCubit>().loadGroupDetails(_group.id);
    if (mounted && detail != null) {
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.l10n.groupInviteCodePrefix} $code'),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openQrModal() {
    GroupInviteQrSheet.show(context, _group);
  }

  void _openEditGroupSheet() {
    CreateGroupSheet.show(
      context,
      groupToEdit: _group,
      onSuccessWithGroup: (updated) {
        setState(() => _group = updated);
        _fetchLatestDetail();
      },
    );
  }

  Future<void> _confirmArchive() async {
    final tr = context.l10n;
    final colors = context.colors;
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
            style: ElevatedButton.styleFrom(backgroundColor: colors.warningAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.archiveConfirmButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<GroupsCubit>().archiveGroup(_group.id);
      if (success && mounted) {
        widget.onBack();
      }
    }
  }

  Future<void> _confirmDelete() async {
    final tr = context.l10n;
    final colors = context.colors;
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
            style: ElevatedButton.styleFrom(backgroundColor: colors.errorAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.deleteConfirmButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<GroupsCubit>().deleteGroup(_group.id);
      if (success && mounted) {
        widget.onBack();
      }
    }
  }

  Future<void> _confirmLeaveGroup() async {
    final tr = context.l10n;
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.leaveGroupConfirmTitle),
        content: Text(tr.leaveGroupConfirmMessage(_group.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colors.errorAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.leaveGroupButton,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _groupMembersCubit?.leaveGroup() ?? false;
      if (success && mounted) {
        widget.onBack();
      }
    }
  }

  void _showSettingsBottomSheet(bool isOwner) {
    final tr = context.l10n;
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: colors.cardBackground,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr.groupSettingsAction,
                style: AppTextStyle.bold(fontSize: 16, color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              if (_group.isAdmin && !_group.isArchived)
                ListTile(
                  leading: const Icon(LucideIcons.pencil),
                  title: Text(tr.editGroupAction),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _openEditGroupSheet();
                  },
                ),
              if (_group.isAdmin && !_group.isArchived)
                ListTile(
                  leading: Icon(LucideIcons.archive, color: colors.warningAccent),
                  title: Text(tr.archiveGroupAction, style: TextStyle(color: colors.warningAccent)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmArchive();
                  },
                ),
              if (isOwner)
                ListTile(
                  leading: Icon(LucideIcons.trash2, color: colors.errorAccent),
                  title: Text(tr.deleteGroupPermanently, style: TextStyle(color: colors.errorAccent)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDelete();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '01/01/2024';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreatingFund) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            setState(() => _isCreatingFund = false);
          }
        },
        child: FundFormScreen(
          groupId: _group.id,
          group: _group,
          onBack: () => setState(() => _isCreatingFund = false),
          onSuccess: () {
            setState(() => _isCreatingFund = false);
            try {
              context.read<FundsCubit>().loadGroupFunds(_group.id);
            } catch (_) {}
            _fetchLatestDetail();
          },
        ),
      );
    }

    final colors = context.colors;
    final tr = context.l10n;
    final currentUserId = context.watch<AuthCubit>().state.currentUser?.id;
    final isOwner = currentUserId != null && currentUserId == _group.ownerId;

    if (_viewingMemberId != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            setState(() => _viewingMemberId = null);
          }
        },
        child: BlocProvider<GroupMembersCubit>.value(
          value: _getOrCreateGroupMembersCubit(),
          child: GroupMemberDetailView(
            groupId: _group.id,
            targetUserId: _viewingMemberId!,
            groupName: _group.name,
            isGroupAdmin: _group.isAdmin,
            isGroupArchived: _group.isArchived,
            currentUserId: currentUserId,
            onBack: () => setState(() => _viewingMemberId = null),
            onMemberKicked: () {
              setState(() => _viewingMemberId = null);
              _getOrCreateGroupMembersCubit().loadMembers();
            },
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: colors.primaryButton,
          onRefresh: _fetchLatestDetail,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Group Header Card (Image 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadowColor,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Back button (Touch target 48x48px)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: widget.onBack,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 20,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Group name
                      Expanded(
                        child: Text(
                          _group.name,
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.h3,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_isLoadingDetail)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                      // Quick settings action button (Touch target min 48x48px)
                      if (_group.isAdmin || isOwner)
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          icon: Icon(LucideIcons.moreVertical, color: colors.textMuted, size: 20),
                          onPressed: () => _showSettingsBottomSheet(isOwner),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Horizontal Segmented Tabs (Image 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabPill(index: 0, label: tr.tabOverview, colors: colors),
                      const SizedBox(width: 8),
                      _buildTabPill(index: 1, label: tr.tabExpenses, colors: colors),
                      const SizedBox(width: 8),
                      _buildTabPill(index: 2, label: tr.tabFunds, colors: colors),
                      const SizedBox(width: 8),
                      _buildTabPill(index: 3, label: tr.tabMembers, colors: colors),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Tab Contents
                if (_selectedTabIndex == 0)
                  _isLoadingDetail
                      ? const GroupOverviewSkeleton()
                      : _buildOverviewTab(colors, tr, isOwner)
                else if (_selectedTabIndex == 1)
                  _buildExpensesTab(colors, tr)
                else if (_selectedTabIndex == 2)
                  _buildFundsTab(colors, tr)
                else
                  _buildMembersTab(colors, tr, isOwner, currentUserId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    required AppThemeColors colors,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.tabPillActiveBg : colors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colors.tabPillActiveBg : colors.cardBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.tabPillActiveBg.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyle.bold(
            fontSize: AppFontSize.secondary,
            color: isSelected ? colors.tabPillActiveText : colors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AppThemeColors colors, AppLocalizations tr, bool isOwner) {
    final inviteCode = _group.inviteCode ?? '---';
    final memberCount = _group.members?.length ?? _group.memberCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Card 1: THÔNG TIN NHÓM
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.groupInfoSectionTitle,
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.caption,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _group.description != null && _group.description!.isNotEmpty
                    ? _group.description!
                    : tr.groupDescHint,
                style: AppTextStyle.regular(
                  fontSize: AppFontSize.secondary,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),

              // Bento Grid Metadata: Hàng 1 (Thể loại full-width)
              _buildCategoryCard(colors, tr),
              const SizedBox(height: 8),

              // Bento Grid Metadata: Hàng 2 (Ngày tạo & Thành viên 2 cột)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      label: tr.createdDateLabel,
                      value: _formatDate(_group.createdAt),
                      icon: LucideIcons.calendar,
                      colors: colors,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      label: tr.membersCountLabel,
                      value: '$memberCount ${tr.membersCountLabel.toLowerCase()}',
                      icon: LucideIcons.users,
                      colors: colors,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Theme-adaptive Invite Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.inviteCodeCardTitle,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.caption,
                              color: colors.onPrimaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            inviteCode,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.h4,
                              color: colors.textPrimary,
                              letterSpacing: 0.8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action 1: Sao chép mã mời (Touch target 48x48px)
                    Tooltip(
                      message: tr.copyInviteCodeAction,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _copyInviteCode(inviteCode),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.secondaryActionBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.secondaryActionBorder),
                          ),
                          child: Icon(
                            LucideIcons.copy,
                            size: 20,
                            color: colors.secondaryActionText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action 2: QR Button (Touch target 48x48px)
                    Tooltip(
                      message: tr.viewQrCodeTooltip,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _openQrModal,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primaryButton,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            LucideIcons.qrCode,
                            size: 20,
                            color: colors.onPrimaryButton,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Card 2: TỔNG QUAN TÀI CHÍNH NHÓM
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.wallet,
                          size: 16,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tr.groupFinancialOverviewTitle,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.secondary,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'VNĐ',
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Inner Balance Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.yourBalanceInGroupLabel,
                      style: AppTextStyle.regular(
                        fontSize: AppFontSize.caption,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            CurrencyUtils.formatVnd(_group.userBalance, showSign: true),
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.h2,
                              color: _group.userBalance > 0
                                  ? colors.onPrimaryContainer
                                  : _group.userBalance < 0
                                      ? colors.errorAccent
                                      : colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _group.userBalance > 0
                                ? colors.primaryContainer
                                : _group.userBalance < 0
                                    ? colors.errorSurface
                                    : colors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _group.userBalance > 0
                                  ? colors.cardBorder
                                  : _group.userBalance < 0
                                      ? colors.errorBorder
                                      : colors.cardBorder,
                            ),
                          ),
                          child: Text(
                            _group.userBalance > 0
                                ? tr.youReceiveBadge
                                : _group.userBalance < 0
                                    ? tr.youOweBadge
                                    : tr.settledBadge,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.caption,
                              color: _group.userBalance > 0
                                  ? colors.onPrimaryContainer
                                  : _group.userBalance < 0
                                      ? colors.errorAccent
                                      : colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2 Summary Cards (Spending & Fund)
              Row(
                children: [
                  // Spending Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tr.totalSpendingCard,
                                  style: AppTextStyle.medium(
                                    fontSize: AppFontSize.caption,
                                    color: colors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                LucideIcons.trendingUp,
                                size: 16,
                                color: colors.infoAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyUtils.formatVnd(
                              _group.totalSpendingVnd ?? _group.totalSpending ?? 0,
                            ),
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.body,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              context.push(
                                '/groups/${_group.id}/analytics?name=${Uri.encodeComponent(_group.name)}&category=${Uri.encodeComponent(_group.category)}&memberCount=$memberCount',
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                '${tr.viewReportAction} →',
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.caption,
                                  color: colors.infoAccent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Fund Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  tr.fundCollectedCard,
                                  style: AppTextStyle.medium(
                                    fontSize: AppFontSize.caption,
                                    color: colors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.cardBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Text(
                                  '$memberCount tv',
                                  style: AppTextStyle.bold(
                                    fontSize: AppFontSize.caption,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            CurrencyUtils.formatVnd(
                              _group.totalFundCollectedVnd ?? _group.totalFundCollected ?? 0,
                            ),
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.body,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'VNĐ • ${tr.fundGeneralSubtitle}',
                            style: AppTextStyle.regular(
                              fontSize: AppFontSize.caption,
                              color: colors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section 3: LỐI TẮT & THAO TÁC NHANH (Image 2)
        Text(
          tr.quickActionsTitle,
          style: AppTextStyle.bold(
            fontSize: AppFontSize.caption,
            color: colors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        // 2x2 Grid Actions
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: LucideIcons.arrowLeftRight,
                iconBg: colors.primaryContainer,
                iconColor: colors.onPrimaryContainer,
                title: tr.viewDebtsAction,
                subtitle: tr.settleDebtsSubtitle,
                colors: colors,
                onTap: () {
                  if (widget.onNavigateToDebts != null) {
                    widget.onNavigateToDebts!();
                  } else {
                    context.go('/dashboard?tab=2');
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: LucideIcons.piggyBank,
                iconBg: colors.surfaceMuted,
                iconColor: colors.infoAccent,
                title: tr.generalFundAction,
                subtitle: tr.collectFundSubtitle,
                colors: colors,
                onTap: () => setState(() => _selectedTabIndex = 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                icon: LucideIcons.plusCircle,
                iconBg: colors.surfaceMuted,
                iconColor: colors.orangeAccent,
                title: tr.addExpenseAction,
                subtitle: tr.splitBillSubtitle,
                colors: colors,
                onTap: () => setState(() => _selectedTabIndex = 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionTile(
                icon: LucideIcons.settings,
                iconBg: colors.surfaceMuted,
                iconColor: colors.textSecondary,
                title: tr.groupSettingsAction,
                subtitle: tr.accountAndInterfaceSubtitle,
                colors: colors,
                onTap: () => _showSettingsBottomSheet(isOwner),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Section 4: QUẢN TRỊ NHÓM (Admin & Owner)
        if (_group.isAdmin || isOwner) ...[
          Text(
            tr.groupAdminSectionTitle,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.caption,
              color: colors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          if (_group.isAdmin && !_group.isArchived)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colors.cardBorder),
                    ),
                    onPressed: _openEditGroupSheet,
                    icon: const Icon(LucideIcons.pencil, size: 16),
                    label: Text(
                      tr.editGroupInfo,
                      style: AppTextStyle.bold(fontSize: AppFontSize.secondary, color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colors.warningAccentBorder),
                    ),
                    onPressed: _confirmArchive,
                    icon: Icon(LucideIcons.archive, size: 16, color: colors.warningAccent),
                    label: Text(
                      tr.archiveGroupAction,
                      style: AppTextStyle.bold(fontSize: AppFontSize.secondary, color: colors.warningAccent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          if (isOwner) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: colors.errorAccent),
              ),
              onPressed: _confirmDelete,
              icon: Icon(LucideIcons.trash2, size: 16, color: colors.errorAccent),
              label: Text(
                tr.deleteGroupPermanently,
                style: AppTextStyle.bold(fontSize: AppFontSize.secondary, color: colors.errorAccent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildCategoryCard(AppThemeColors colors, AppLocalizations tr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: GroupCategoryHelper.buildIcon(_group.category, width: 18, height: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr.categoryLabel,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  GroupCategoryHelper.getLabel(_group.category),
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.secondary,
                    color: colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String label,
    required String value,
    IconData? icon,
    Widget? iconWidget,
    required AppThemeColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: colors.textMuted),
                const SizedBox(width: 4),
              ] else if (iconWidget != null) ...[
                iconWidget,
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: colors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.secondary,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.secondary,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyle.regular(
                      fontSize: AppFontSize.caption,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTab(AppThemeColors colors, AppLocalizations tr) {
    return GroupExpensesTabView(group: _group);
  }

  Widget _buildFundsTab(AppThemeColors colors, AppLocalizations tr) {
    return GroupFundsTabView(
      group: _group,
      onCreateFund: () => setState(() => _isCreatingFund = true),
    );
  }

  Widget _buildMembersTab(
    AppThemeColors colors,
    AppLocalizations tr,
    bool isOwner,
    int? currentUserId,
  ) {
    return BlocProvider<GroupMembersCubit>.value(
      value: _getOrCreateGroupMembersCubit(),
      child: GroupMembersTabView(
        group: _group,
        isAdmin: _group.isAdmin,
        isOwner: isOwner,
        currentUserId: currentUserId,
        onInviteMore: _openQrModal,
        onSelectMember: (memberId) {
          setState(() {
            _viewingMemberId = memberId;
          });
        },
        onDeleteGroup: _confirmDelete,
        onLeaveGroup: _confirmLeaveGroup,
      ),
    );
  }
}

class _FallbackGroupsRepo implements GroupsRepository {
  final GroupModel Function() _getGroup;
  _FallbackGroupsRepo(this._getGroup);

  @override
  Future<List<GroupMemberSummaryModel>> getGroupMembers(
    int groupId, {
    String? name,
  }) async {
    final g = _getGroup();
    if (g.members != null && g.members!.isNotEmpty) {
      return g.members!
          .map<GroupMemberSummaryModel>((m) => GroupMemberSummaryModel(
                userId: m.id,
                fullName: m.fullName,
                avatarUrl: m.avatarUrl,
                role: m.role,
              ))
          .toList();
    }
    return List.generate(
      g.memberCount,
      (i) => GroupMemberSummaryModel(
        userId: i + 1,
        fullName: 'Thành viên ${i + 1}',
        avatarUrl: null,
        role: i == 0 ? 'ADMIN' : 'MEMBER',
      ),
    );
  }

  @override
  Future<GroupJoinRequestsResult> getPendingJoinRequests(int groupId) async {
    return GroupJoinRequestsResult(
      groupId: groupId,
      totalRequests: 0,
      requests: const [],
    );
  }

  @override
  Future<void> reviewJoinRequest(
    int requestId, {
    required bool approved,
    bool includePastFundCollections = false,
  }) async {}

  @override
  Future<GroupMemberDetailModel> getMemberDetails(
    int groupId,
    int targetUserId,
  ) async {
    return GroupMemberDetailModel(
      userId: targetUserId,
      fullName: 'Thành viên $targetUserId',
      role: 'MEMBER',
      groupId: groupId,
      groupName: _getGroup().name,
      email: 'member$targetUserId@fairshare.app',
      debtAmountVnd: 0,
      receivableAmountVnd: 0,
      netBalanceVnd: 0,
      participatedExpenses: const [],
    );
  }

  @override
  Future<void> removeMember(int groupId, int targetUserId) async {}

  @override
  Future<void> leaveGroup(int groupId) async {}

  @override
  Future<void> transferOwnership(int groupId, int newOwnerId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
