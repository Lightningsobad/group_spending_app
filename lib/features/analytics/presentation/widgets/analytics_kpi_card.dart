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
              if (badgeText != null) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor ?? colors.badgeSuccessBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: AppTextStyle.bold(
                        color: badgeTextColor ?? colors.badgeSuccessText,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTextStyle.extraBold(
                color: colors.textPrimary,
                fontSize: 20,
              ),
              maxLines: 1,
            ),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.analyticsAccent,
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
                  Expanded(
                    child: Text(
                      progressSubtitleLeft!,
                      style: AppTextStyle.medium(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (progressSubtitleRight != null) ...[
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      progressSubtitleRight!,
                      style: AppTextStyle.medium(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ],
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTextStyle.medium(
                color: colors.textSecondary,
                fontSize: 12,
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
