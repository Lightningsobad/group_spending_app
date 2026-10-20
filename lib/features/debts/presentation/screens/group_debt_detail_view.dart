import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../../groups/presentation/widgets/group_category_helper.dart';
import '../../../groups/presentation/widgets/viet_qr_modal_sheet.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_settlement_entity.dart';
import '../../domain/entities/group_debt_entity.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';
import '../widgets/actual_debt_card_widget.dart';
import '../widgets/group_debt_card_skeleton.dart';
import '../widgets/group_debt_detail_skeleton.dart';
import '../widgets/group_debt_segmented_tab.dart';
import '../widgets/group_debt_summary_card.dart';
import '../widgets/settle_debt_dialogs.dart';
import '../widgets/simplified_debt_card_widget.dart';

class GroupDebtDetailView extends StatelessWidget {
  final int groupId;
  final String? groupName;

  const GroupDebtDetailView({
    super.key,
    required this.groupId,
    this.groupName,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    final currentUserId = context.read<AuthCubit>().state.currentUser?.id;

    return BlocBuilder<DebtsCubit, DebtsState>(
      builder: (context, state) {
        final cubit = context.read<DebtsCubit>();
        final isDetailLoading = state.isDetailLoading;
        final activeTab = state.activeDetailTab;

        final hasFreshData = (state.simplifiedDebts != null &&
                state.simplifiedDebts!.userBalance.groupId == groupId) ||
            (state.actualDebts != null &&
                state.actualDebts!.userBalance.groupId == groupId);

        if (isDetailLoading && !hasFreshData) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) cubit.selectGroup(null);
            },
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.35,
              child: SafeArea(
                top: false,
                bottom: true,
                child: GroupDebtDetailSkeleton(
                  onBack: () => cubit.selectGroup(null),
                ),
              ),
            ),
          );
        }

        final userBalance = state.simplifiedDebts?.userBalance ??
            state.actualDebts?.userBalance ??
            DebtUserBalanceEntity(
              groupId: groupId,
              groupName: groupName ?? 'Nhóm chi tiêu',
            );

        final simplifiedList =
            state.simplifiedDebts?.simplifiedDebts ?? const [];
        final actualList = state.actualDebts?.actualDebts ?? const [];

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.selectGroup(null);
          },
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.35,
            child: SafeArea(
              top: false,
              bottom: true,
              child: RefreshIndicator(
                color: colors.brandEmerald,
                onRefresh: () => cubit.loadGroupDebts(groupId),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Sub-Header: Back Pill & Group Title Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back button pill
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => cubit.selectGroup(null),
                              child: Container(
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.arrowLeft,
                                      size: 16,
                                      color: colors.textPrimary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr.backAction,
                                      style: AppTextStyle.bold(
                                        fontSize: AppFontSize.secondary,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Group Pill
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.debtReceiveBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colors.debtReceiveBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GroupCategoryHelper.buildIcon(
                                    userBalance.category,
                                    width: 14,
                                    height: 14,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      userBalance.groupName,
                                      style: AppTextStyle.bold(
                                        fontSize: AppFontSize.caption,
                                        color: colors.debtReceiveText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 2. Group Summary Card
                      GroupDebtSummaryCard(
                        userBalance: userBalance,
                      ),
                      const SizedBox(height: 14),

                      // 3. Segmented Tab Switcher (Nợ tối giản / Nợ thực tế)
                      GroupDebtSegmentedTab(
                        activeTab: activeTab,
                        simplifiedCount: simplifiedList.length,
                        actualCount: actualList.length,
                        onTabChanged: (index) => cubit.setDetailTab(index),
                      ),
                      const SizedBox(height: 12),

                      // 4. Info Banner Box (chỉ hiện ở tab Nợ tối giản)
                      if (activeTab == 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.debtReceiveBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.debtReceiveBorder,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                LucideIcons.info,
                                size: 16,
                                color: colors.debtReceiveText,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  tr.simplifiedDebtsBanner,
                                  style: AppTextStyle.medium(
                                    fontSize: AppFontSize.caption,
                                    color: colors.debtReceiveText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 5. Section Header for Tab 0
                      if (activeTab == 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  tr.debtsToHandleCount(simplifiedList.length),
                                  style: AppTextStyle.bold(
                                    fontSize: AppFontSize.caption,
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  tr.simplifiedDebtAlgorithm,
                                  style: AppTextStyle.semiBold(
                                    fontSize: AppFontSize.caption,
                                    color: colors.debtReceiveText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 6. Content Body
                      if (isDetailLoading &&
                          simplifiedList.isEmpty &&
                          actualList.isEmpty)
                        ...List.generate(
                          3,
                          (index) => const GroupDebtCardSkeleton(),
                        )
                      else if (activeTab == 0) ...[
                        if (state.pendingSettlements.isNotEmpty)
                          ...state.pendingSettlements.map(
                            (settlement) => _buildSettlementCard(
                              context,
                              settlement: settlement,
                              currentUserId: currentUserId,
                              cubit: cubit,
                              colors: colors,
                            ),
                          ),
                        if (simplifiedList.isEmpty &&
                            state.pendingSettlements.isEmpty)
                          _buildEmptyDebtView(context, tr, colors)
                        else
                          ...simplifiedList.map(
                            (debt) {
                              final matchingSettlement = state.pendingSettlements
                                  .where((s) =>
                                      s.debtorId == debt.debtorId &&
                                      s.creditorId == debt.creditorId)
                                  .firstOrNull;
                              final isWaiting = matchingSettlement != null ||
                                  debt.action == DebtAction.confirm;

                              return SimplifiedDebtCardWidget(
                                debt: debt,
                                currentUserId: currentUserId,
                                isWaitingForConfirmation: isWaiting,
                                onPay: () => _handlePaySimplifiedDebt(
                                  context,
                                  debt: debt,
                                  groupName: userBalance.groupName,
                                  cubit: cubit,
                                ),
                                onConfirm: (confirmed) async {
                                  final settlementId =
                                      matchingSettlement?.id ?? debt.id;
                                  if (settlementId == null) return;

                                  if (confirmed) {
                                    final ok =
                                        await SettleDebtDialogs.showConfirmSettled(
                                      context,
                                      debtorName: debt.debtorName,
                                      formattedAmount:
                                          CurrencyUtils.formatVnd(debt.amountVnd),
                                      confirmed: true,
                                    );
                                    if (ok == true) {
                                      await cubit.confirmDebtSettlement(
                                        settlementId,
                                        confirmed: true,
                                      );
                                    }
                                  } else {
                                    final reason = await SettleDebtDialogs
                                        .showRejectSettledDialog(
                                      context,
                                      debtorName: debt.debtorName,
                                    );
                                    if (reason != null) {
                                      await cubit.confirmDebtSettlement(
                                        settlementId,
                                        confirmed: false,
                                        reason: reason,
                                      );
                                    }
                                  }
                                },
                                onRemind: () async {
                                  final ok =
                                      await SettleDebtDialogs.showRemindConfirm(
                                    context,
                                    debtorName: debt.debtorName,
                                    formattedAmount:
                                        CurrencyUtils.formatVnd(debt.amountVnd),
                                  );
                                  if (ok == true) {
                                    final expectedAmount = debt.amount > 0
                                        ? debt.amount
                                        : (debt.amountVnd > 0
                                            ? (debt.amountVnd / 1000)
                                            : 0);
                                    await cubit.sendSimplifiedDebtReminder(
                                      groupId,
                                      debtorId: debt.debtorId,
                                      creditorId: debt.creditorId,
                                      expectedAmount: expectedAmount,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                      ] else ...[
                        if (actualList.isEmpty)
                          _buildEmptyDebtView(context, tr, colors)
                        else
                          ...actualList.map(
                            (debt) => ActualDebtCardWidget(
                              debt: debt,
                              onDebtorPay: (debtor) {
                                cubit.markDebtAsPaid(debtor.splitId);
                              },
                              onDebtorConfirm: (debtor, confirmed) {
                                cubit.confirmDebtSettled(
                                  debtor.splitId,
                                  confirmed: confirmed,
                                );
                              },
                              onDebtorRemind: (debtor) {
                                cubit.sendDebtReminder(debtor.splitId);
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyDebtView(
    BuildContext context,
    AppLocalizations tr,
    AppThemeColors colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.debtIconContainerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.debtIconContainerBorder),
              ),
              child: Icon(
                LucideIcons.checkCheck,
                size: 26,
                color: colors.debtIconContainerFg,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              tr.noDebtsInGroupTitle,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              tr.noDebtsInGroupSubtitle,
              style: AppTextStyle.regular(
                fontSize: AppFontSize.caption,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePaySimplifiedDebt(
    BuildContext context, {
    required SimplifiedDebtEntity debt,
    required String groupName,
    required DebtsCubit cubit,
  }) async {
    String? bankName = debt.creditorBankName;
    String? bankAccountNumber = debt.creditorAccountNumber;
    String? bankAccountName =
        debt.creditorBankAccountName ?? debt.creditorName;

    if (bankAccountNumber == null || bankAccountNumber.trim().isEmpty) {
      try {
        final groupsRepo = context.read<GroupsRepository>();
        final member =
            await groupsRepo.getMemberDetails(groupId, debt.creditorId);
        if (member.hasBankInfo) {
          bankName = member.bankName;
          bankAccountNumber = member.bankAccountNumber;
          bankAccountName = member.bankAccountName ?? member.fullName;
        }
      } catch (_) {
        // Fall through to bank info validation below
      }
    }

    if (!context.mounted) return;

    if (bankAccountNumber == null ||
        bankAccountNumber.trim().isEmpty ||
        bankName == null ||
        bankName.trim().isEmpty) {
      await SettleDebtDialogs.showNoBankInfoAlert(
        context,
        creditorName: debt.creditorName,
      );
      return;
    }

    final expectedAmount = debt.amount > 0
        ? debt.amount
        : (debt.amountVnd > 0 ? (debt.amountVnd / 1000) : 0);

    final preview = await cubit.previewSimplifiedDebtPayment(
      groupId,
      creditorId: debt.creditorId,
      expectedAmount: expectedAmount,
    );

    if (!context.mounted || preview == null || preview.planToken.isEmpty) {
      return;
    }

    final transferNote = debt.note != null && debt.note!.trim().isNotEmpty
        ? debt.note!.trim()
        : '${debt.debtorName} tra no $groupName'.trim();

    await VietQrModalSheet.show(
      context,
      bankName: bankName,
      accountNumber: bankAccountNumber,
      accountName: (bankAccountName != null && bankAccountName.trim().isNotEmpty)
          ? bankAccountName
          : debt.creditorName,
      amount: preview.amountVnd > 0 ? preview.amountVnd : debt.amountVnd,
      note: transferNote,
      onPaidConfirmed: () async {
        // shortcut: sinh timestamp-based idempotency key để tránh gửi lặp, nâng cấp uuid package nếu cần
        final idempotencyKey = 'pay_${DateTime.now().microsecondsSinceEpoch}';
        await cubit.paySimplifiedDebt(
          groupId,
          planToken: preview.planToken,
          idempotencyKey: idempotencyKey,
        );
      },
    );
  }

  Widget _buildSettlementCard(
    BuildContext context, {
    required DebtSettlementEntity settlement,
    required int? currentUserId,
    required DebtsCubit cubit,
    required AppThemeColors colors,
  }) {
    final isCreditor =
        currentUserId != null && settlement.creditorId == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCreditor ? colors.debtReceiveBorder : colors.debtWaitingBg,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.bellRing,
                    size: 15,
                    color: colors.debtWaitingText,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCreditor
                        ? 'Yêu cầu tất toán cần xác nhận'
                        : 'Đợt tất toán đang chờ duyệt',
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.caption,
                      color: colors.debtWaitingText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.debtWaitingBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Chờ xác nhận',
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.caption,
                    color: colors.debtWaitingText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.debtAvatarBg,
                backgroundImage: settlement.debtorAvatar != null &&
                        settlement.debtorAvatar!.isNotEmpty
                    ? NetworkImage(settlement.debtorAvatar!)
                    : null,
                child: settlement.debtorAvatar == null ||
                        settlement.debtorAvatar!.isEmpty
                    ? Text(
                        settlement.debtorName.isNotEmpty
                            ? settlement.debtorName[0].toUpperCase()
                            : '?',
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.secondary,
                          color: colors.textPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${settlement.debtorName} ➔ ${settlement.creditorName}',
                      style: AppTextStyle.bold(
                        fontSize: AppFontSize.secondary,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (settlement.note != null &&
                        settlement.note!.isNotEmpty)
                      Text(
                        settlement.note!,
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
              Text(
                CurrencyUtils.formatVnd(settlement.amountVnd),
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.body,
                  color: colors.debtReceiveText,
                ),
              ),
            ],
          ),
          if (isCreditor) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.debtActionConfirmBg,
                      foregroundColor: colors.onPrimaryButton,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final ok = await SettleDebtDialogs.showConfirmSettled(
                        context,
                        debtorName: settlement.debtorName,
                        formattedAmount:
                            CurrencyUtils.formatVnd(settlement.amountVnd),
                        confirmed: true,
                      );
                      if (ok == true) {
                        await cubit.confirmDebtSettlement(
                          settlement.id,
                          confirmed: true,
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: Text(
                      'Đã nhận tiền',
                      style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.debtActionRejectFg,
                      side: BorderSide(color: colors.debtActionRejectBorder),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final reason =
                          await SettleDebtDialogs.showRejectSettledDialog(
                        context,
                        debtorName: settlement.debtorName,
                      );
                      if (reason != null) {
                        await cubit.confirmDebtSettlement(
                          settlement.id,
                          confirmed: false,
                          reason: reason,
                        );
                      }
                    },
                    icon: const Icon(LucideIcons.x, size: 16),
                    label: Text(
                      'Từ chối',
                      style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
