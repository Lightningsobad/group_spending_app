import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/group_member_models.dart';
import '../cubit/group_members_cubit.dart';
import '../cubit/group_members_state.dart';
import 'viet_qr_modal_sheet.dart';

class GroupMemberDetailView extends StatefulWidget {
  final int groupId;
  final int targetUserId;
  final String groupName;
  final bool isGroupAdmin;
  final bool isGroupArchived;
  final int? currentUserId;
  final VoidCallback onBack;
  final VoidCallback? onMemberKicked;

  const GroupMemberDetailView({
    super.key,
    required this.groupId,
    required this.targetUserId,
    required this.groupName,
    required this.isGroupAdmin,
    required this.isGroupArchived,
    this.currentUserId,
    required this.onBack,
    this.onMemberKicked,
  });

  @override
  State<GroupMemberDetailView> createState() => _GroupMemberDetailViewState();
}

class _GroupMemberDetailViewState extends State<GroupMemberDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupMembersCubit>().loadMemberDetail(widget.targetUserId);
    });
  }

  void _copyToClipboard(String text, String successMsg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmAndKickMember(
    BuildContext context,
    GroupMemberDetailModel detail,
  ) async {
    final tr = context.l10n;
    final cubit = context.read<GroupMembersCubit>();
    bool? confirmed;

    if (detail.debtAmountVnd > 0) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr.debtWarningTitle),
          content: Text(
            tr.debtWarningMessage(
              CurrencyUtils.formatVnd(detail.debtAmountVnd),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                tr.stillKickButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else if (detail.receivableAmountVnd > 0) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr.receivableWarningTitle),
          content: Text(
            tr.receivableWarningMessage(
              CurrencyUtils.formatVnd(detail.receivableAmountVnd),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                tr.continueKickButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr.confirmKickMemberTitle),
          content: Text(
            tr.confirmKickMemberMessage(detail.fullName, widget.groupName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(tr.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                tr.confirmKickButton,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (confirmed == true && mounted) {
      final success = await cubit.kickMember(widget.targetUserId);
      if (success && mounted) {
        if (widget.onMemberKicked != null) {
          widget.onMemberKicked!();
        }
        widget.onBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return BlocConsumer<GroupMembersCubit, GroupMembersState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.successMessage != curr.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<GroupMembersCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.emerald,
            ),
          );
          context.read<GroupMembersCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final detail = state.selectedMemberDetail;
        final isSelf = widget.currentUserId != null &&
            widget.currentUserId == widget.targetUserId;
        final canKick = widget.isGroupAdmin &&
            !isSelf &&
            !widget.isGroupArchived &&
            detail != null &&
            !detail.isAdmin;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Sub-Header: Back & Group Name (Image 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: widget.onBack,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.arrowLeft,
                              size: 18, color: colors.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            tr.backToGroup,
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      widget.groupName.toUpperCase(),
                      style: AppTextStyle.bold(
                        fontSize: 12,
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (state.isLoadingDetail)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.emerald),
                  ),
                )
              else if (detail != null) ...[
                // 2. Profile Hero Card (Image 3)
                _buildHeroCard(context, detail, isSelf),
                const SizedBox(height: 16),

                // 3. THÔNG TIN CÁ NHÂN & TÀI KHOẢN (Image 3)
                _buildContactAndBankCard(context, detail),
                const SizedBox(height: 16),

                // 4. TRẠNG THÁI CÔNG NỢ TRONG NHÓM (Image 4)
                _buildDebtStatusCard(context, detail),
                const SizedBox(height: 16),

                // 5. CÁC KHOẢN CHI ĐÃ THAM GIA (Image 4)
                _buildParticipatedExpensesCard(context, detail),

                // 6. XÓA THÀNH VIÊN KHỎI NHÓM (Dành cho Admin)
                if (canKick) ...[
                  const SizedBox(height: 20),
                  _buildKickMemberCard(context, detail),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    GroupMemberDetailModel detail,
    bool isSelf,
  ) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with active dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.emerald.withValues(alpha: 0.2),
                  backgroundImage: detail.avatarUrl != null &&
                          detail.avatarUrl!.isNotEmpty
                      ? NetworkImage(detail.avatarUrl!)
                      : null,
                  child: detail.avatarUrl == null
                      ? Text(
                          detail.fullName.isNotEmpty
                              ? detail.fullName[0].toUpperCase()
                              : '?',
                          style: AppTextStyle.bold(
                            fontSize: 28,
                            color: AppColors.emeraldForest,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name and "Bạn" tag
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  isSelf ? '${detail.fullName} (${tr.youPill})' : detail.fullName,
                  style: AppTextStyle.bold(
                    fontSize: 17,
                    color: colors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelf) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tr.youPill,
                    style: AppTextStyle.bold(
                      fontSize: 10,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Role pill & Group name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: detail.isAdmin
                      ? const Color(0xFFFEF3C7)
                      : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (detail.isAdmin) ...[
                      const Icon(LucideIcons.shieldCheck,
                          size: 12, color: Color(0xFFB45309)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      detail.isAdmin ? tr.roleLeaderBadge : tr.roleMemberBadge,
                      style: AppTextStyle.bold(
                        fontSize: 10,
                        color: detail.isAdmin
                            ? const Color(0xFFB45309)
                            : colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text('•',
                  style: TextStyle(color: colors.textMuted, fontSize: 12)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  widget.groupName,
                  style: AppTextStyle.regular(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Columns Stats Container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: Row(
              children: [
                // Col 1: Được nhận / Nợ
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        detail.netBalanceVnd >= 0
                            ? tr.youReceiveBadge.toUpperCase()
                            : tr.youOweBadge.toUpperCase(),
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: colors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.formatVnd(detail.netBalanceVnd,
                            showSign: true),
                        style: AppTextStyle.bold(
                          fontSize: 13,
                          color: detail.netBalanceVnd > 0
                              ? const Color(0xFF15803D)
                              : detail.netBalanceVnd < 0
                                  ? AppColors.error
                                  : colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail.netBalanceVnd >= 0
                            ? 'Thu về'
                            : 'Cần trả',
                        style: AppTextStyle.regular(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 1, height: 32, color: const Color(0xFFE2E8F0)),

                // Col 2: Trả đúng hạn
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        tr.onTimeDebtRateLabel,
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: colors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.star,
                              size: 12, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 3),
                          Text(
                            '${detail.debtSettlementRate.toStringAsFixed(detail.debtSettlementRate.truncateToDouble() == detail.debtSettlementRate ? 0 : 1)}%',
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.goodRateLabel,
                        style: AppTextStyle.regular(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: 1, height: 32, color: const Color(0xFFE2E8F0)),

                // Col 3: Đóng quỹ đúng hạn
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        tr.onTimeFundRateLabel,
                        style: AppTextStyle.bold(
                          fontSize: 10,
                          color: colors.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.target,
                              size: 12, color: Color(0xFF15803D)),
                          const SizedBox(width: 3),
                          Text(
                            '${detail.fundContributionOnTimeRate.toStringAsFixed(detail.fundContributionOnTimeRate.truncateToDouble() == detail.fundContributionOnTimeRate ? 0 : 1)}%',
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đúng hạn',
                        style: AppTextStyle.regular(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactAndBankCard(
    BuildContext context,
    GroupMemberDetailModel detail,
  ) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.personalAndAccountInfoSection,
            style: AppTextStyle.bold(
              fontSize: 12,
              color: colors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Email
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.mail,
                    size: 16, color: Color(0xFF2563EB)),
              ),
              const SizedBox(width: 12),
              Text(
                'Email',
                style: AppTextStyle.medium(
                    fontSize: 13, color: colors.textSecondary),
              ),
              const Spacer(),
              Flexible(
                flex: 2,
                child: Text(
                  detail.email,
                  style: AppTextStyle.bold(
                      fontSize: 13, color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.copy, size: 14, color: colors.textMuted),
                onPressed: () =>
                    _copyToClipboard(detail.email, tr.copiedEmail),
              ),
            ],
          ),
          const Divider(height: 16),

          // Phone
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.phone,
                    size: 16, color: Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              Text(
                'Số điện thoại',
                style: AppTextStyle.medium(
                    fontSize: 13, color: colors.textSecondary),
              ),
              const Spacer(),
              Text(
                detail.phone != null && detail.phone!.isNotEmpty
                    ? detail.phone!
                    : '---',
                style:
                    AppTextStyle.bold(fontSize: 13, color: colors.textPrimary),
              ),
              if (detail.phone != null && detail.phone!.isNotEmpty)
                IconButton(
                  icon:
                      Icon(LucideIcons.copy, size: 14, color: colors.textMuted),
                  onPressed: () =>
                      _copyToClipboard(detail.phone!, tr.copiedPhone),
                )
              else
                const SizedBox(width: 40),
            ],
          ),
          const Divider(height: 16),

          // Role
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.shieldAlert,
                    size: 16, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 12),
              Text(
                'Vai trò trong nhóm',
                style: AppTextStyle.medium(
                    fontSize: 13, color: colors.textSecondary),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: detail.isAdmin
                      ? const Color(0xFFFEF3C7)
                      : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  detail.isAdmin ? tr.roleLeaderFull : tr.roleMemberFull,
                  style: AppTextStyle.bold(
                    fontSize: 11,
                    color: detail.isAdmin
                        ? const Color(0xFFB45309)
                        : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Bank Account Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.creditCard,
                        size: 16, color: Color(0xFF15803D)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tr.bankAccountTitle,
                    style: AppTextStyle.medium(
                        fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
              if (detail.hasBankInfo)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    VietQrModalSheet.show(
                      context,
                      bankName: detail.bankName ?? 'Bank',
                      accountNumber: detail.bankAccountNumber!,
                      accountName: detail.bankAccountName ?? detail.fullName,
                    );
                  },
                  icon: const Icon(LucideIcons.qrCode,
                      size: 14, color: Color(0xFF047857)),
                  label: Text(
                    tr.vietQrCodeButton,
                    style: AppTextStyle.bold(
                      fontSize: 11,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Bank Detail Box
          if (detail.hasBankInfo)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        detail.bankName ?? '',
                        style: AppTextStyle.bold(
                          fontSize: 13,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          detail.bankAccountNumber!,
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: const Color(0xFF047857),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _copyToClipboard(
                          detail.bankAccountNumber!,
                          tr.copiedAccountNumber,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.copy,
                                size: 12, color: Color(0xFF047857)),
                            const SizedBox(width: 4),
                            Text(
                              tr.copyAction,
                              style: AppTextStyle.bold(
                                fontSize: 11,
                                color: const Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (detail.bankAccountName ?? detail.fullName).toUpperCase(),
                    style: AppTextStyle.bold(
                      fontSize: 12,
                      color: colors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              tr.noBankInfoYet,
              style: AppTextStyle.regular(
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebtStatusCard(
    BuildContext context,
    GroupMemberDetailModel detail,
  ) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Flexible(
                child: Text(
                  tr.groupDebtStatusSection,
                  style: AppTextStyle.bold(
                    fontSize: 12,
                    color: colors.textMuted,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: detail.netBalanceVnd > 0
                      ? const Color(0xFFDCFCE7)
                      : detail.netBalanceVnd < 0
                          ? const Color(0xFFFFE4E6)
                          : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  detail.netBalanceVnd > 0
                      ? 'Được nhận: ${CurrencyUtils.formatVnd(detail.netBalanceVnd)}'
                      : detail.netBalanceVnd < 0
                          ? 'Cần trả: ${CurrencyUtils.formatVnd(detail.netBalanceVnd.abs())}'
                          : tr.settledBadge,
                  style: AppTextStyle.bold(
                    fontSize: 11,
                    color: detail.netBalanceVnd > 0
                        ? const Color(0xFF15803D)
                        : detail.netBalanceVnd < 0
                            ? AppColors.error
                            : colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1: Tổng số tiền được nhóm hoàn lại
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '• ${tr.totalRefundedByGroup}',
                style: AppTextStyle.regular(
                    fontSize: 13, color: colors.textSecondary),
              ),
              Text(
                CurrencyUtils.formatVnd(detail.receivableAmountVnd,
                    showSign: true),
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: const Color(0xFF15803D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Tổng số tiền cần chi trả cho nhóm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '• ${tr.totalToPayGroup}',
                style: AppTextStyle.regular(
                    fontSize: 13, color: colors.textSecondary),
              ),
              Text(
                detail.debtAmountVnd > 0
                    ? '-${CurrencyUtils.formatVnd(detail.debtAmountVnd)}'
                    : '0 đ',
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: detail.debtAmountVnd > 0
                      ? AppColors.error
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Row 3: Kết quả ròng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.netResultLabel,
                style: AppTextStyle.bold(
                  fontSize: 13,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                detail.netBalanceVnd > 0
                    ? 'Được nhận ${CurrencyUtils.formatVnd(detail.netBalanceVnd)}'
                    : detail.netBalanceVnd < 0
                        ? 'Cần trả ${CurrencyUtils.formatVnd(detail.netBalanceVnd.abs())}'
                        : '0 đ',
                style: AppTextStyle.bold(
                  fontSize: 14,
                  color: detail.netBalanceVnd > 0
                      ? const Color(0xFF15803D)
                      : detail.netBalanceVnd < 0
                          ? AppColors.error
                          : colors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipatedExpensesCard(
    BuildContext context,
    GroupMemberDetailModel detail,
  ) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Text(
                tr.participatedExpensesSection(
                  detail.participatedExpenses.length,
                ),
                style: AppTextStyle.bold(
                  fontSize: 12,
                  color: colors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'VNĐ',
                  style: AppTextStyle.bold(
                    fontSize: 10,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (detail.participatedExpenses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  tr.noExpensesYet,
                  style: AppTextStyle.regular(
                      fontSize: 13, color: colors.textMuted),
                ),
              ),
            )
          else
            ...detail.participatedExpenses.map((expense) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.cardBorder),
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.receipt,
                        size: 18,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: AppTextStyle.bold(
                              fontSize: 13,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${expense.expenseDate} • ${expense.isPaidByMember ? tr.paidFullBadge : tr.paidByMemberPrefix('')}',
                            style: AppTextStyle.regular(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Amount & Share
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyUtils.formatVnd(expense.amountVnd),
                          style: AppTextStyle.bold(
                            fontSize: 13,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr.memberSharePrefix(
                            CurrencyUtils.formatVnd(expense.myAmountOwedVnd),
                          ),
                          style: AppTextStyle.bold(
                            fontSize: 11,
                            color: const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildKickMemberCard(
    BuildContext context,
    GroupMemberDetailModel detail,
  ) {
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.userMinus,
                    size: 18, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.kickMemberDangerTitle,
                      style: AppTextStyle.bold(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tr.kickMemberDangerSubtitle,
                      style: AppTextStyle.regular(
                        fontSize: 11,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => _confirmAndKickMember(context, detail),
            icon: const Icon(LucideIcons.userMinus, size: 16),
            label: Text(
              tr.kickMemberButton,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
