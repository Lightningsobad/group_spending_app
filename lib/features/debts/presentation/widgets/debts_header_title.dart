import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class DebtsHeaderTitle extends StatelessWidget {
  const DebtsHeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.debtIconContainerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.debtIconContainerBorder),
          ),
          child: Icon(
            LucideIcons.layers,
            size: 22,
            color: colors.debtIconContainerFg,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          tr.debtsGroupTitle,
          style: AppTextStyle.bold(
            fontSize: AppFontSize.h4,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
