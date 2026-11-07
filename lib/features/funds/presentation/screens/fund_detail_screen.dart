import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../l10n/l10n.dart';
import '../../../groups/data/models/group_model.dart';
import '../../domain/entities/fund_entities.dart';
import '../../domain/repositories/funds_repository.dart';
import '../cubit/fund_detail_cubit.dart';
import '../cubit/fund_detail_state.dart';
import '../widgets/fund_detail_skeleton.dart';
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
      create: (ctx) {
        DataSyncCoordinator? syncCoordinator;
        try {
          syncCoordinator = ctx.read<DataSyncCoordinator>();
        } catch (_) {}
        return FundDetailCubit(
          ctx.read<FundsRepository>(),
          dataSyncCoordinator: syncCoordinator,
        )..loadFundDetails(fundId);
      },
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
    final colors = context.colors;
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
            style: ElevatedButton.styleFrom(backgroundColor: colors.dangerText),
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
    final colors = context.colors;
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
            style: ElevatedButton.styleFrom(backgroundColor: colors.brandEmerald),
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
          fundId: fund.id,
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

    // Non-linear TextScaler with safe boundary clamping
    final textScaler = MediaQuery.textScalerOf(context).clamp(
      minScaleFactor: 0.85,
      maxScaleFactor: 1.30,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: BlocConsumer<FundDetailCubit, FundDetailState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage ||
            prev.successMessage != curr.successMessage ||
            prev.isDeleted != curr.isDeleted,
        listener: (ctx, state) {
          if (state.errorMessage != null) {
            AppSnackBar.showError(ctx, state.errorMessage!);
            ctx.read<FundDetailCubit>().clearMessages();
          }
          if (state.successMessage != null) {
            AppSnackBar.showSuccess(ctx, state.successMessage!);
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Back Button with minimum 48x48px touch target
                        ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          child: Center(
                            child: InkWell(
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
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Title & Group Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tr.fundDetailTitle,
                                style: AppTextStyle.bold(
                                  fontSize: AppFontSize.h4, // 18px
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (groupName.isNotEmpty)
                                Text(
                                  groupName,
                                  style: AppTextStyle.bold(
                                    fontSize: AppFontSize.caption, // 12px
                                    color: colors.brandEmerald,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),

                        // Header Actions (Admin only: Quick Edit & Quick Delete)
                        if (isAdmin && fund != null) ...[
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            child: Center(
                              child: InkWell(
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
                            ),
                          ),
                          const SizedBox(width: 8), // Gap >= 8px
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            child: Center(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _confirmDelete(fund),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.dangerSurface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    LucideIcons.trash2,
                                    size: 17,
                                    color: colors.dangerText,
                                  ),
                                ),
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
                        ? const FundDetailSkeleton()
                        : fund == null
                            ? Center(
                                child: Text(
                                  tr.underDevelopment,
                                  style: AppTextStyle.medium(
                                    fontSize: AppFontSize.secondary, // 14px
                                    color: colors.textMuted,
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                color: colors.brandEmerald,
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
      ),
    );
  }

  Widget _buildFundInfoCard(
    BuildContext context,
    FundCollectionEntity fund,
    AppThemeColors colors,
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
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Status Chip & CSV Export button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCollecting
                        ? colors.fundStatusCollectingBg
                        : colors.fundStatusCompletedBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCollecting ? LucideIcons.clock : LucideIcons.circleCheck,
                        size: 14,
                        color: isCollecting
                            ? colors.fundStatusCollectingText
                            : colors.fundStatusCompletedText,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isCollecting
                              ? tr.statusCollectingBadge
                              : tr.statusCompletedBadge,
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.caption, // 12px
                            color: isCollecting
                                ? colors.fundStatusCollectingText
                                : colors.fundStatusCompletedText,
                            letterSpacing: 0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // CSV Chip with minimum 48px touch target
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 48,
                  minWidth: 48,
                ),
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => context.read<FundDetailCubit>().exportCsv(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.fundCsvButtonBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.fileSpreadsheet,
                            size: 14,
                            color: colors.fundCsvIcon,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CSV',
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.caption, // 12px
                              color: colors.fundCsvButtonFg,
                            ),
                          ),
                        ],
                      ),
                    ),
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
              fontSize: AppFontSize.h3, // 20px
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
                  fontSize: AppFontSize.secondary, // 14px
                  color: colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Due Date with overflow protection
          Row(
            children: [
              Icon(
                LucideIcons.calendar,
                size: 14,
                color: colors.brandEmerald,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: tr.dueDatePrefix,
                    style: AppTextStyle.regular(
                      fontSize: AppFontSize.caption, // 12px
                      color: colors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: _formatDate(fund.dueDate),
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.caption, // 12px
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Amounts with flex layout to prevent overflow on small screens
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.collectedAmountLabel,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption, // 12px
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyUtils.formatVnd(fund.totalCollectedAmountVnd),
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.h2, // 24px
                        color: colors.fundAmountText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tr.targetAmountLabel,
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.caption, // 12px
                        color: colors.textMuted,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyUtils.formatVnd(fund.totalTargetAmountVnd),
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.secondary, // 14px
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.fundProgressStart,
                            colors.fundProgressEnd,
                          ],
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
              Flexible(
                child: Text(
                  tr.membersPaidRatio(fund.paidCount, fund.totalMemberCount),
                  style: AppTextStyle.medium(
                    fontSize: AppFontSize.caption, // 12px
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${fund.completionPercentage.toStringAsFixed(0)}%',
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.secondary, // 14px
                  color: colors.fundAmountText,
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
    AppThemeColors colors,
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
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with overflow protection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 15,
                      color: colors.brandEmerald,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tr.memberPaymentStatusTitle,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.secondary, // 14px
                          color: colors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tr.tapToChangeStatusHint,
                    style: AppTextStyle.regular(
                      fontSize: AppFontSize.caption, // 12px
                      color: colors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
    AppThemeColors colors,
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
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: colors.fundEditButtonBg,
              foregroundColor: colors.fundEditButtonFg,
              side: BorderSide(color: colors.fundEditButtonBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(LucideIcons.penLine, size: 16, color: colors.fundEditButtonFg),
            label: Text(
              tr.editFundCampaignAction,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary, // 14px
                color: colors.fundEditButtonFg,
              ),
            ),
          ),
          const SizedBox(height: 10), // Gap >= 8px
        ],

        // 2. Xuất báo cáo CSV đợt thu quỹ (All members)
        ElevatedButton.icon(
          onPressed: state.isExporting
              ? null
              : () => context.read<FundDetailCubit>().exportCsv(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(vertical: 13),
            backgroundColor: colors.fundCsvButtonBg,
            foregroundColor: colors.fundCsvButtonFg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: state.isExporting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.fundCsvButtonFg),
                  ),
                )
              : Icon(
                  LucideIcons.fileSpreadsheet,
                  size: 16,
                  color: colors.fundCsvIcon,
                ),
          label: Text(
            tr.exportFundCsvAction,
            style: AppTextStyle.bold(
              fontSize: AppFontSize.secondary, // 14px
              color: colors.fundCsvButtonFg,
            ),
          ),
        ),
        const SizedBox(height: 10), // Gap >= 8px

        // 3. Xóa đợt đóng quỹ này (Admin only)
        if (isAdmin) ...[
          TextButton.icon(
            onPressed: () => _confirmDelete(fund),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: colors.dangerText,
            ),
            icon: Icon(LucideIcons.trash2, size: 16, color: colors.dangerText),
            label: Text(
              tr.deleteFundCampaignAction,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary, // 14px
                color: colors.dangerText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
