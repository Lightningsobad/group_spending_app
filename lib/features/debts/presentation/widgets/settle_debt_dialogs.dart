import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class SettleDebtDialogs {
  SettleDebtDialogs._();

  static Future<void> showNoBankInfoAlert(
    BuildContext context, {
    required String creditorName,
  }) {
    final tr = context.l10n;
    final colors = context.colors;

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.badgeWarningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.triangleAlert,
                size: 20,
                color: colors.badgeWarningText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tr.noCreditorBankInfoTitle,
                style: AppTextStyle.bold(
                  fontSize: AppFontSize.body,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          tr.noCreditorBankInfoMessage(creditorName),
          style: AppTextStyle.regular(
            fontSize: AppFontSize.secondary,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.debtActionPayBg,
              foregroundColor: colors.onPrimaryButton,
              minimumSize: const Size(64, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              tr.close,
              style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
            ),
          ),
        ],
      ),
    );
  }

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
            fontSize: AppFontSize.body,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          tr.confirmPayDebtMessage(creditorName, formattedAmount),
          style: AppTextStyle.regular(
            fontSize: AppFontSize.secondary,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.debtActionPayBg,
              foregroundColor: colors.onPrimaryButton,
              minimumSize: const Size(64, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
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
            fontSize: AppFontSize.body,
            color: confirmed ? colors.debtReceiveText : colors.debtOweText,
          ),
        ),
        content: Text(
          confirmed
              ? tr.confirmReceiveDebtMessage(debtorName, formattedAmount)
              : tr.rejectReceiveDebtMessage(debtorName),
          style: AppTextStyle.regular(
            fontSize: AppFontSize.secondary,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmed
                  ? colors.debtActionConfirmBg
                  : colors.debtOweText,
              foregroundColor: colors.onPrimaryButton,
              minimumSize: const Size(64, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> showRejectSettledDialog(
    BuildContext context, {
    required String debtorName,
  }) {
    final tr = context.l10n;
    final colors = context.colors;
    final controller = TextEditingController(
      text: tr.defaultRejectReceiveReason,
    );

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          tr.rejectReceiveDebtTitle,
          style: AppTextStyle.bold(
            fontSize: AppFontSize.body,
            color: colors.debtOweText,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr.rejectReceiveDebtMessage(debtorName),
              style: AppTextStyle.regular(
                fontSize: AppFontSize.secondary,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: tr.rejectReceiveReasonLabel,
                hintText: tr.rejectReceiveReasonHint,
                filled: true,
                fillColor: colors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.cardBorder),
                ),
              ),
              style: AppTextStyle.regular(
                fontSize: AppFontSize.secondary,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
            ),
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.debtOweText,
              foregroundColor: colors.onPrimaryButton,
              minimumSize: const Size(64, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final reason = controller.text.trim();
              Navigator.of(ctx).pop(
                reason.isNotEmpty
                    ? reason
                    : tr.defaultRejectReceiveReason,
              );
            },
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
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
            fontSize: AppFontSize.body,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          tr.confirmRemindDebtMessage(debtorName, formattedAmount),
          style: AppTextStyle.regular(
            fontSize: AppFontSize.secondary,
            color: colors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(64, 44),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              tr.cancel,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.secondary,
                color: colors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.debtActionRemindIcon,
              foregroundColor: colors.onPrimaryButton,
              minimumSize: const Size(64, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              tr.confirm,
              style: AppTextStyle.bold(fontSize: AppFontSize.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
