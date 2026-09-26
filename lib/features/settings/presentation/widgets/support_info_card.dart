import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class SupportInfoCard extends StatelessWidget {
  const SupportInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.cardBorder, width: 1.2),
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.infoSupportSection,
            style: AppTextStyle.bold(
              fontSize: 12,
              color: colors.textSlate800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 14),

          // Onboarding Item
          _SupportTile(
            itemBg: colors.surfaceMuted,
            borderColor: colors.cardBorder,
            icon: LucideIcons.info,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: tr.aboutAppTitle,
            subtitle: tr.aboutAppSubtitle,
            textColor: colors.textPrimary,
            onTap: () {
              context.push('/onboarding');
            },
          ),

          const SizedBox(height: 12),

          // Privacy Policy Item
          _SupportTile(
            itemBg: colors.surfaceMuted,
            borderColor: colors.cardBorder,
            icon: LucideIcons.shieldCheck,
            iconBg: const Color(0xFFE0E7FF),
            iconColor: const Color(0xFF4F46E5),
            title: tr.privacyPolicyTitle,
            subtitle: tr.privacyPolicySubtitle,
            textColor: colors.textPrimary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(tr.underDevelopment)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final Color itemBg;
  final Color borderColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  const _SupportTile({
    required this.itemBg,
    required this.borderColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: itemBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyle.bold(fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyle.medium(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
