import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.bell,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tr.notificationsTitle,
                    style: AppTextStyle.bold(fontSize: 16, color: colors.textPrimary),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Empty State Placeholder
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.cardBorder,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.bellRing,
                  size: 40,
                  color: AppColors.emeraldForest,
                ),
                const SizedBox(height: 12),
                Text(
                  tr.noNotifications,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium(
                    fontSize: 13,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
