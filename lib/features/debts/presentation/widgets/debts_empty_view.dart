import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class DebtsEmptyView extends StatelessWidget {
  final bool isSearching;

  const DebtsEmptyView({super.key, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.debtIconContainerBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.debtIconContainerBorder),
              ),
              child: Icon(
                LucideIcons.arrowLeftRight,
                size: 32,
                color: colors.debtIconContainerFg,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? tr.noMatchingDebtGroupsTitle
                  : tr.noDebtGroupsTitle,
              style: AppTextStyle.bold(
                fontSize: AppFontSize.body,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? tr.noMatchingDebtGroupsSubtitle
                  : tr.noDebtGroupsSubtitle,
              style: AppTextStyle.regular(
                fontSize: AppFontSize.secondary,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
