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
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.arrowLeftRight,
                size: 32,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? tr.noMatchingDebtGroupsTitle
                  : tr.noDebtGroupsTitle,
              style: AppTextStyle.bold(
                fontSize: 16,
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
                fontSize: 13,
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
