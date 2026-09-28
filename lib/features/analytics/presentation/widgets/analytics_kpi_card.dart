import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class AnalyticsKpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final String? badgeText;
  final Color? badgeBgColor;
  final Color? badgeTextColor;
  final String? subtitle;
  final double? progressBarPercent;
  final String? progressSubtitleLeft;
  final String? progressSubtitleRight;

  const AnalyticsKpiCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.badgeText,
    this.badgeBgColor,
    this.badgeTextColor,
    this.subtitle,
    this.progressBarPercent,
    this.progressSubtitleLeft,
    this.progressSubtitleRight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [colors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and top badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor ?? const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTextStyle.bold(
                      color: badgeTextColor ?? const Color(0xFF15803D),
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            label,
            style: AppTextStyle.regular(
              color: colors.textSecondary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Value
          Text(
            value,
            style: AppTextStyle.extraBold(
              color: colors.textPrimary,
              fontSize: 18,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Optional progress bar
          if (progressBarPercent != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressBarPercent!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: colors.cardBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.emerald,
                ),
              ),
            ),
          ],
          // Subtitle or progress footer
          if (progressSubtitleLeft != null || progressSubtitleRight != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (progressSubtitleLeft != null)
                  Text(
                    progressSubtitleLeft!,
                    style: AppTextStyle.regular(
                      color: colors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                if (progressSubtitleRight != null)
                  Text(
                    progressSubtitleRight!,
                    style: AppTextStyle.regular(
                      color: colors.textMuted,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyle.regular(
                color: colors.textMuted,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
