import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/data/models/group_model.dart';
import '../../domain/entities/fund_entities.dart';
import '../../domain/repositories/funds_repository.dart';
import '../cubit/fund_detail_cubit.dart';
import '../cubit/fund_detail_state.dart';
import '../widgets/fund_member_tile.dart';
import 'fund_form_screen.dart';

class FundDetailScreen extends StatelessWidget {
  final int fundId;
  final GroupModel? group;

  const FundDetailScreen({
    super.key,
    required this.fundId,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FundDetailCubit>(
      create: (ctx) => FundDetailCubit(
        ctx.read<FundsRepository>(),
      )..loadFundDetails(fundId),
      child: _FundDetailView(
        fundId: fundId,
        group: group,
      ),
    );
  }
}

class _FundDetailView extends StatefulWidget {
  final int fundId;
  final GroupModel? group;

  const _FundDetailView({
    required this.fundId,
    this.group,
  });

  @override
  State<_FundDetailView> createState() => _FundDetailViewState();
}

class _FundDetailViewState extends State<_FundDetailView> {
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '---';
    try {
      final dt = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return rawDate;
    }
  }

  Future<void> _confirmDelete(FundCollectionEntity fund) async {
    final tr = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.confirmDeleteFundTitle),
        content: Text(tr.confirmDeleteFundMessage),
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
      final success = await context.read<FundDetailCubit>().deleteFund();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _confirmMarkPaid(
    FundMemberEntity member,
    num amountVnd,
  ) async {
    final tr = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.confirmMarkPaidTitle),
        content: Text(
          tr.confirmMarkPaidMessage(
            member.fullName,
            CurrencyUtils.formatVnd(amountVnd),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14532D)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(tr.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<FundDetailCubit>().markMemberPaid(member.userId);
    }
  }

  void _openEditScreen(FundCollectionEntity fund) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FundFormScreen(
          groupId: fund.groupId,
          group: widget.group,
          initialFund: fund,
          isEdit: true,
        ),
      ),
    );

    if (updated == true && mounted) {
      context.read<FundDetailCubit>().loadFundDetails(fund.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final isAdmin = widget.group?.isAdmin ?? false;
    final groupName = widget.group?.name ?? '';

    return BlocConsumer<FundDetailCubit, FundDetailState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          prev.successMessage != curr.successMessage ||
          prev.isDeleted != curr.isDeleted,
      listener: (ctx, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          ctx.read<FundDetailCubit>().clearMessages();
        }
        if (state.successMessage != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.emerald,
            ),
          );
          ctx.read<FundDetailCubit>().clearMessages();
        }
      },
      builder: (ctx, state) {
        final fund = state.fund;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      // Back Button
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.arrowLeft,
                            size: 18,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Group Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.fundDetailTitle,
                              style: AppTextStyle.bold(
                                fontSize: 18,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (groupName.isNotEmpty)
                              Text(
                                groupName,
                                style: AppTextStyle.bold(
                                  fontSize: 11,
                                  color: const Color(0xFF047857),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),

                      // Header Actions (Admin only: Quick Edit & Quick Delete)
                      if (isAdmin && fund != null) ...[
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _openEditScreen(fund),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              LucideIcons.penLine,
                              size: 17,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _confirmDelete(fund),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              size: 17,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: state.isLoading && fund == null
                      ? const Center(child: CircularProgressIndicator())
                      : fund == null
                          ? Center(
                              child: Text(
                                tr.underDevelopment,
                                style: AppTextStyle.medium(
                                  fontSize: 14,
                                  color: colors.textMuted,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              color: AppColors.emerald,
                              onRefresh: () => ctx
                                  .read<FundDetailCubit>()
                                  .loadFundDetails(fund.id, silent: true),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Card 1: Fund Info & Progress
                                    _buildFundInfoCard(context, fund, colors, tr),
                                    const SizedBox(height: 16),

                                    // Card 2: Members Payment Status List
                                    _buildMemberStatusCard(
                                      context,
                                      fund,
                                      state,
                                      colors,
                                      tr,
                                      isAdmin,
                                    ),
                                    const SizedBox(height: 20),

                                    // Bottom 3 Full-Width Action Buttons
                                    _buildBottomActions(
                                      context,
                                      fund,
                                      state,
                                      colors,
                                      tr,
                                      isAdmin,
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

  Widget _buildFundInfoCard(
    BuildContext context,
    FundCollectionEntity fund,
    dynamic colors,
    dynamic tr,
  ) {
    final isCollecting = fund.isCollecting;
    final progressFraction = (fund.completionPercentage / 100.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status Chip & Close fund / refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isCollecting
                      ? const Color(0xFFDBEAFE)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCollecting ? LucideIcons.clock : LucideIcons.circleCheck,
                      size: 13,
                      color: isCollecting
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCollecting
                          ? tr.statusCollectingBadge
                          : tr.statusCompletedBadge,
                      style: AppTextStyle.bold(
                        fontSize: 10,
                        color: isCollecting
                            ? const Color(0xFF1E40AF)
                            : const Color(0xFF15803D),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => context.read<FundDetailCubit>().exportCsv(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.fileSpreadsheet,
                        size: 13,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CSV',
                        style: AppTextStyle.bold(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            fund.name,
            style: AppTextStyle.bold(
              fontSize: 19,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Description box
          if (fund.description != null && fund.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                fund.description!,
                style: AppTextStyle.regular(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Due Date
          Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                size: 14,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 6),
              Text(
                tr.dueDatePrefix,
                style: AppTextStyle.regular(
                  fontSize: 12,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                _formatDate(fund.dueDate),
                style: AppTextStyle.bold(
                  fontSize: 12,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr.collectedAmountLabel,
                    style: AppTextStyle.bold(
                      fontSize: 10,
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatVnd(fund.totalCollectedAmountVnd),
                    style: AppTextStyle.bold(
                      fontSize: 22,
                      color: const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr.targetAmountLabel,
                    style: AppTextStyle.bold(
                      fontSize: 10,
                      color: colors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.formatVnd(fund.totalTargetAmountVnd),
                    style: AppTextStyle.bold(
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: colors.surfaceMuted,
                  ),
                  FractionallySizedBox(
                    widthFactor: progressFraction,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Progress Summary footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.membersPaidRatio(fund.paidCount, fund.totalMemberCount),
                style: AppTextStyle.medium(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                '${fund.completionPercentage.toStringAsFixed(0)}%',
                style: AppTextStyle.bold(
                  fontSize: 12,
                  color: const Color(0xFF047857),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberStatusCard(
    BuildContext context,
    FundCollectionEntity fund,
    FundDetailState state,
    dynamic colors,
    dynamic tr,
    bool isAdmin,
  ) {
    final isCooldownActive = state.remindCooldownSeconds > 0;
    final cooldownSeconds = state.remindCooldownSeconds;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
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
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.users,
                    size: 15,
                    color: Color(0xFF047857),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tr.memberPaymentStatusTitle,
                    style: AppTextStyle.bold(
                      fontSize: 11,
                      color: colors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (isAdmin)
                Text(
                  tr.tapToChangeStatusHint,
                  style: AppTextStyle.regular(
                    fontSize: 11,
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // List of members
          ...fund.members.map((m) {
            return FundMemberTile(
              member: m,
              amountVnd: fund.targetAmountPerPersonVnd,
              isAdmin: isAdmin,
              isCooldownActive: isCooldownActive,
              cooldownSeconds: cooldownSeconds,
              onToggleStatus: () => _confirmMarkPaid(
                m,
                fund.targetAmountPerPersonVnd,
              ),
              onRemind: () => context.read<FundDetailCubit>().sendReminder(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    FundCollectionEntity fund,
    FundDetailState state,
    dynamic colors,
    dynamic tr,
    bool isAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Chỉnh sửa đợt đóng quỹ (Admin only)
        if (isAdmin) ...[
          OutlinedButton.icon(
            onPressed: () => _openEditScreen(fund),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFFF0FDF4),
              foregroundColor: const Color(0xFF15803D),
              side: const BorderSide(color: Color(0xFF86EFAC)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(LucideIcons.penLine, size: 16, color: Color(0xFF15803D)),
            label: Text(
              tr.editFundCampaignAction,
              style: AppTextStyle.bold(
                fontSize: 13,
                color: const Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 2. Xuất báo cáo CSV đợt thu quỹ (All members)
        ElevatedButton.icon(
          onPressed: state.isExporting
              ? null
              : () => context.read<FundDetailCubit>().exportCsv(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13),
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF334155),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: state.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  LucideIcons.fileSpreadsheet,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
          label: Text(
            tr.exportFundCsvAction,
            style: AppTextStyle.bold(
              fontSize: 12,
              color: const Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 3. Xóa đợt đóng quỹ này (Admin only)
        if (isAdmin) ...[
          TextButton.icon(
            onPressed: () => _confirmDelete(fund),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              foregroundColor: const Color(0xFFDC2626),
            ),
            icon: const Icon(LucideIcons.trash2, size: 15, color: Color(0xFFDC2626)),
            label: Text(
              tr.deleteFundCampaignAction,
              style: AppTextStyle.bold(
                fontSize: 12,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
