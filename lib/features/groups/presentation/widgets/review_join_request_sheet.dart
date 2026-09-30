import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/group_member_models.dart';

class ReviewJoinRequestSheet extends StatefulWidget {
  final GroupJoinRequestModel request;
  final Future<void> Function(bool includePastFunds) onConfirm;

  const ReviewJoinRequestSheet({
    super.key,
    required this.request,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required GroupJoinRequestModel request,
    required Future<void> Function(bool includePastFunds) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReviewJoinRequestSheet(
        request: request,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<ReviewJoinRequestSheet> createState() => _ReviewJoinRequestSheetState();
}

class _ReviewJoinRequestSheetState extends State<ReviewJoinRequestSheet> {
  bool _includePastFunds = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            tr.approveJoinTitle(widget.request.userFullName),
            style: AppTextStyle.bold(
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Checkbox container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _includePastFunds,
                  activeColor: AppColors.emerald,
                  onChanged: (val) {
                    setState(() => _includePastFunds = val ?? false);
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr.includePastFundsCheckbox,
                        style: AppTextStyle.bold(
                          fontSize: 13,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr.includePastFundsHint,
                        style: AppTextStyle.regular(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: colors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    tr.cancel,
                    style: AppTextStyle.bold(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF14532D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);
                          Navigator.of(context).pop();
                          await widget.onConfirm(_includePastFunds);
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          tr.confirmApproveButton,
                          style: AppTextStyle.bold(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
