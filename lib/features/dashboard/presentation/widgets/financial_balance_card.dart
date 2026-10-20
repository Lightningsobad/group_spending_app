import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../l10n/l10n.dart';

class FinancialBalanceCard extends StatefulWidget {
  final num totalOwedVnd;
  final num totalReceivableVnd;

  const FinancialBalanceCard({
    super.key,
    required this.totalOwedVnd,
    required this.totalReceivableVnd,
  });

  @override
  State<FinancialBalanceCard> createState() => _FinancialBalanceCardState();
}

class _FinancialBalanceCardState extends State<FinancialBalanceCard> {
  bool _isBalanceHidden = false;

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;
    final owedText = _isBalanceHidden
        ? '••••••••'
        : CurrencyUtils.formatVnd(widget.totalOwedVnd);
    final receivableText = _isBalanceHidden
        ? '••••••••'
        : CurrencyUtils.formatVnd(widget.totalReceivableVnd);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colors.financialCardBgStart,
            colors.financialCardBgMiddle,
            colors.financialCardBgEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colors.financialCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          colors.financialCardShadow,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Eye Toggle (48x48 touch target)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.financialCardIconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      LucideIcons.wallet,
                      size: 18,
                      color: colors.financialCardIcon,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr.financialOverviewTitle,
                    style: AppTextStyle.bold(
                      fontSize: 12,
                      color: colors.financialCardTitle,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isBalanceHidden ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 18,
                  color: colors.financialCardEyeToggle,
                ),
                tooltip: _isBalanceHidden ? 'Hiện số dư' : 'Ẩn số dư',
                onPressed: () {
                  setState(() {
                    _isBalanceHidden = !_isBalanceHidden;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two balance boxes
          Row(
            children: [
              // Left: Bạn đang nợ
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.financialCardBoxBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.financialCardBoxBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.trendingDown,
                            size: 14,
                            color: colors.financialCardOweIcon,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tr.youOwe,
                              style: AppTextStyle.medium(
                                fontSize: 12,
                                color: colors.financialCardOweLabel,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          owedText,
                          style: AppTextStyle.bold(
                            fontSize: 18,
                            color: colors.financialCardOweAmount,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.paySoonSubtitle,
                        style: AppTextStyle.regular(
                          fontSize: 12,
                          color: colors.financialCardOweSubtitle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Right: Bạn nhận
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.financialCardBoxBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.financialCardBoxBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.trendingUp,
                            size: 14,
                            color: colors.financialCardReceiveIcon,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tr.youAreOwed,
                              style: AppTextStyle.medium(
                                fontSize: 12,
                                color: colors.financialCardReceiveLabel,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          receivableText,
                          style: AppTextStyle.bold(
                            fontSize: 18,
                            color: colors.financialCardReceiveAmount,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.friendsOweYouSubtitle,
                        style: AppTextStyle.regular(
                          fontSize: 12,
                          color: colors.financialCardReceiveSubtitle,
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
    );
  }
}
