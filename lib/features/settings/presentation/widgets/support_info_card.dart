import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class SupportInfoCard extends StatelessWidget {
  final VoidCallback? onOpenPrivacyPolicy;

  const SupportInfoCard({
    super.key,
    this.onOpenPrivacyPolicy,
  });

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
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Onboarding Item
          _SupportTile(
            itemBg: colors.surfaceMuted,
            borderColor: colors.cardBorder,
            icon: LucideIcons.info,
            iconBg: colors.badgeSuccessBg,
            iconColor: colors.badgeSuccess,
            title: tr.aboutAppTitle,
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
            iconBg: colors.badgeIndigoBg,
            iconColor: colors.badgeIndigo,
            title: tr.privacyPolicyTitle,
            textColor: colors.textPrimary,
            onTap: () {
              if (onOpenPrivacyPolicy != null) {
                onOpenPrivacyPolicy!();
              } else {
                context.push('/settings/privacy-policy');
              }
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
  final Color textColor;
  final VoidCallback onTap;

  const _SupportTile({
    required this.itemBg,
    required this.borderColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                child: Text(
                  title,
                  style: AppTextStyle.bold(fontSize: 14, color: textColor),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
