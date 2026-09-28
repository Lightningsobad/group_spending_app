import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class SettleDebtDialogs {
  SettleDebtDialogs._();

  static Future<bool?> showPayConfirm(
    BuildContext context, {
    required String creditorName,
    required String formattedAmount,
  }) {
    final tr = context.l10n;
    final colors = context.colors;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          tr.confirmPayDebtTitle,
          style: AppTextStyle.bold(
            fontSize: 16,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          tr.confirmPayDebtMessage(creditorName, formattedAmount),
          style: AppTextStyle.regular(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF15803D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmSettled(
    BuildContext context, {
    required String debtorName,
    required String formattedAmount,
    required bool confirmed,
  }) {
    final tr = context.l10n;
    final colors = context.colors;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          confirmed
              ? tr.confirmReceiveDebtTitle
              : tr.rejectReceiveDebtTitle,
          style: AppTextStyle.bold(
            fontSize: 16,
            color: confirmed ? const Color(0xFF15803D) : const Color(0xFFE11D48),
          ),
        ),
        content: Text(
          confirmed
              ? tr.confirmReceiveDebtMessage(debtorName, formattedAmount)
              : tr.rejectReceiveDebtMessage(debtorName),
          style: AppTextStyle.regular(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmed
                  ? const Color(0xFF15803D)
                  : const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showRemindConfirm(
    BuildContext context, {
    required String debtorName,
    required String formattedAmount,
  }) {
    final tr = context.l10n;
    final colors = context.colors;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          tr.confirmRemindDebtTitle,
          style: AppTextStyle.bold(
            fontSize: 16,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          tr.confirmRemindDebtMessage(debtorName, formattedAmount),
          style: AppTextStyle.regular(
            fontSize: 13,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
