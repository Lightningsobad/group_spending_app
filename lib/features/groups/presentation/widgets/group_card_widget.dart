import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../data/models/group_model.dart';
import 'group_category_helper.dart';

class GroupCardWidget extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  final VoidCallback? onToggleMute;

  const GroupCardWidget({
    super.key,
    required this.group,
    this.onTap,
    this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isArchived = group.isArchived;

    final balance = group.userBalance;
    final Color balanceColor;
    if (balance > 0) {
      balanceColor = const Color(0xFF10B981);
    } else if (balance < 0) {
      balanceColor = const Color(0xFFEF4444);
    } else {
      balanceColor = colors.textMuted;
    }

    final balanceText = CurrencyUtils.formatVnd(balance, showSign: true);

    return Opacity(
      opacity: isArchived ? 0.85 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
          boxShadow: [colors.cardShadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Top Row: Category Icon, Name & Badges, Bell & Chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Category SVG Icon Box
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colors.cardBorder),
                        ),
                        alignment: Alignment.center,
                        child: GroupCategoryHelper.buildIcon(
                          group.category,
                          width: 28,
                          height: 28,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name and Badges
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: AppTextStyle.bold(
                                fontSize: 15,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Role Badge
                                if (group.isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.roleAdminBg,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          LucideIcons.shieldCheck,
                                          size: 11,
                                          color: AppColors.roleAdminText,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'ADMIN',
                                          style: AppTextStyle.bold(
                                            fontSize: 9,
                                            color: AppColors.roleAdminText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'THÀNH VIÊN',
                                      style: AppTextStyle.bold(
                                        fontSize: 9,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ),

                                // Status Badge
                                if (group.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Đang hoạt động',
                                      style: AppTextStyle.bold(
                                        fontSize: 9,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceMuted,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.archive,
                                          size: 10,
                                          color: colors.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Đã lưu trữ (Chỉ đọc)',
                                          style: AppTextStyle.bold(
                                            fontSize: 9,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bell & Arrow Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isArchived
                                  ? LucideIcons.bellOff
                                  : LucideIcons.bell,
                              size: 18,
                              color: isArchived
                                  ? colors.textMuted
                                  : AppColors.emerald,
                            ),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                            onPressed: onToggleMute,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.divider.withValues(alpha: 0.6),
                    ),
                  ),

                  // Bottom Row: Balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Số dư của bạn:',
                        style: AppTextStyle.regular(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        balanceText,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: balanceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
