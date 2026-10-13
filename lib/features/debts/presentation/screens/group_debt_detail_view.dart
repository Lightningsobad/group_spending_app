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
import '../../domain/entities/group_debt_entity.dart';
import '../cubit/debts_cubit.dart';
import '../cubit/debts_state.dart';
import '../widgets/actual_debt_card_widget.dart';
import '../widgets/group_debt_card_skeleton.dart';
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

        final userBalance = state.simplifiedDebts?.userBalance ??
            state.actualDebts?.userBalance ??
            DebtUserBalanceEntity(
              groupId: groupId,
              groupName: groupName ?? 'Nhóm chi tiêu',
            );

        final simplifiedList =
            state.simplifiedDebts?.simplifiedDebts ?? const [];
        final actualList = state.actualDebts?.actualDebts ?? const [];

        return RefreshIndicator(
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

                // 4. Info Banner Box (chỉ hiện ở tab Nợ tối giản, tab Nợ thực tế hiển thị trực tiếp danh sách theo thiết kế)
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
                        Text(
                          tr.debtsToHandleCount(simplifiedList.length),
                          style: AppTextStyle.bold(
                            fontSize: AppFontSize.caption,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          tr.simplifiedDebtAlgorithm,
                          style: AppTextStyle.semiBold(
                            fontSize: AppFontSize.caption,
                            color: colors.debtReceiveText,
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
                  if (simplifiedList.isEmpty)
                    _buildEmptyDebtView(context, tr, colors)
                  else
                    ...simplifiedList.map(
                      (debt) => SimplifiedDebtCardWidget(
                        debt: debt,
                        currentUserId: currentUserId,
                        onPay: () => _handlePaySimplifiedDebt(
                          context,
                          debt: debt,
                          groupName: userBalance.groupName,
                          cubit: cubit,
                        ),
                        onConfirm: (confirmed) async {
                          final ok =
                              await SettleDebtDialogs.showConfirmSettled(
                            context,
                            debtorName: debt.debtorName,
                            formattedAmount:
                                CurrencyUtils.formatVnd(debt.amountVnd),
                            confirmed: confirmed,
                          );
                          if (ok == true) {
                            if (debt.id != null) {
                              await cubit.confirmDebtSettled(
                                debt.id!,
                                confirmed: confirmed,
                              );
                            } else {
                              final splits = _findMatchingSplitIds(
                                cubit: cubit,
                                creditorId: debt.creditorId,
                                debtorId: debt.debtorId,
                                action: DebtAction.confirm,
                              );
                              for (final sid in splits) {
                                await cubit.confirmDebtSettled(
                                  sid,
                                  confirmed: confirmed,
                                );
                              }
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
                            if (debt.id != null) {
                              await cubit.sendDebtReminder(debt.id!);
                            } else {
                              final splits = _findMatchingSplitIds(
                                cubit: cubit,
                                creditorId: debt.creditorId,
                                debtorId: debt.debtorId,
                                action: DebtAction.remind,
                              );
                              for (final sid in splits) {
                                await cubit.sendDebtReminder(sid);
                              }
                            }
                          }
                        },
                      ),
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
      amount: debt.amountVnd,
      note: transferNote,
      onPaidConfirmed: () async {
        if (debt.id != null) {
          await cubit.markDebtAsPaid(debt.id!);
        } else {
          final splits = _findMatchingSplitIds(
            cubit: cubit,
            creditorId: debt.creditorId,
            debtorId: debt.debtorId,
            action: DebtAction.pay,
          );
          if (splits.isNotEmpty) {
            for (final sid in splits) {
              await cubit.markDebtAsPaid(sid);
            }
          } else {
            await cubit.loadGroupDebts(groupId, silent: true);
          }
        }
      },
    );
  }

  List<int> _findMatchingSplitIds({
    required DebtsCubit cubit,
    required int creditorId,
    required int debtorId,
    DebtAction? action,
  }) {
    final actualDebts = cubit.state.actualDebts?.actualDebts ?? const [];
    final splitIds = <int>[];
    for (final exp in actualDebts) {
      if (exp.paidByUserId == creditorId) {
        for (final d in exp.debtors) {
          final isDebtor = d.userId == debtorId || d.isMe;
          final matchesAction = action == null ||
              d.action == action ||
              (action == DebtAction.pay && d.status == DebtStatus.pending) ||
              (action == DebtAction.confirm &&
                  d.status == DebtStatus.waitingForConfirmation) ||
              (action == DebtAction.remind && d.status == DebtStatus.pending);
          if (isDebtor && matchesAction) {
            splitIds.add(d.splitId);
          }
        }
      }
    }
    return splitIds;
  }
}
