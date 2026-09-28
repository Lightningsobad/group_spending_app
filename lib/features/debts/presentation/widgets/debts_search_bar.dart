import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class DebtsSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const DebtsSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyle.medium(
        fontSize: 13,
        color: colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: tr.searchDebtGroupPlaceholder,
        hintStyle: AppTextStyle.regular(
          fontSize: 13,
          color: colors.textMuted,
        ),
        prefixIcon: Icon(
          LucideIcons.search,
          size: 18,
          color: colors.textMuted,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: colors.textMuted,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: colors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.emerald,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
