import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_text_style.dart';

enum AppSnackBarType {
  success,
  error,
  warning,
  info,
}

/// Tiện ích hiển thị SnackBar dạng Floating Card đạt chuẩn Design System FairShare.
/// Tuân thủ quy chuẩn UI/UX:
/// - Floating pill bo cong 16px với đổ bóng mềm mại
/// - Huy hiệu biểu tượng Lucide theo ngữ nghĩa (semantic badges)
/// - Phản hồi rung haptic phù hợp mức độ quan trọng
/// - Tự động hủy thông báo cũ trước khi hiện thông báo mới (tránh hàng đợi)
/// - Hỗ trợ đầy đủ Light mode và Dark mode tập trung qua AppThemeColors (không check isDark rải rác)
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    AppSnackBarType type = AppSnackBarType.info,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    // Haptic feedback
    switch (type) {
      case AppSnackBarType.success:
        HapticFeedback.lightImpact();
        break;
      case AppSnackBarType.error:
        HapticFeedback.mediumImpact();
        break;
      case AppSnackBarType.warning:
      case AppSnackBarType.info:
        HapticFeedback.selectionClick();
        break;
    }

    final defaultDuration = type == AppSnackBarType.error
        ? const Duration(seconds: 4)
        : const Duration(seconds: 3);

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: duration ?? defaultDuration,
        dismissDirection: DismissDirection.horizontal,
        content: _AppSnackBarCard(
          type: type,
          title: title,
          message: message,
          onClose: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppSnackBarType.success,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppSnackBarType.error,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppSnackBarType.warning,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? title,
    Duration? duration,
  }) {
    show(
      context,
      message: message,
      title: title,
      type: AppSnackBarType.info,
      duration: duration,
    );
  }
}

class _AppSnackBarCard extends StatelessWidget {
  final AppSnackBarType type;
  final String? title;
  final String message;
  final VoidCallback onClose;

  const _AppSnackBarCard({
    required this.type,
    required this.message,
    required this.onClose,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styleConfig = _getStyleConfig(colors);

    return Container(
      decoration: BoxDecoration(
        color: styleConfig.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styleConfig.borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: styleConfig.badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              styleConfig.icon,
              size: 20,
              color: styleConfig.iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title!.isNotEmpty) ...[
                  Text(
                    title!,
                    style: AppTextStyle.bold(
                      fontSize: AppFontSize.secondary,
                      color: styleConfig.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppTextStyle.medium(
                    fontSize: AppFontSize.secondary,
                    color: styleConfig.textColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              LucideIcons.x,
              size: 16,
              color: colors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }

  _SnackBarThemeConfig _getStyleConfig(AppThemeColors colors) {
    switch (type) {
      case AppSnackBarType.success:
        return _SnackBarThemeConfig(
          surfaceColor: colors.snackBarSuccessBg,
          borderColor: colors.snackBarSuccessBorder,
          badgeColor: colors.snackBarSuccessBadge,
          iconColor: colors.snackBarSuccessIcon,
          textColor: colors.snackBarSuccessText,
          icon: LucideIcons.checkCircle2,
        );
      case AppSnackBarType.error:
        return _SnackBarThemeConfig(
          surfaceColor: colors.snackBarErrorBg,
          borderColor: colors.snackBarErrorBorder,
          badgeColor: colors.snackBarErrorBadge,
          iconColor: colors.snackBarErrorIcon,
          textColor: colors.snackBarErrorText,
          icon: LucideIcons.alertCircle,
        );
      case AppSnackBarType.warning:
        return _SnackBarThemeConfig(
          surfaceColor: colors.snackBarWarningBg,
          borderColor: colors.snackBarWarningBorder,
          badgeColor: colors.snackBarWarningBadge,
          iconColor: colors.snackBarWarningIcon,
          textColor: colors.snackBarWarningText,
          icon: LucideIcons.alertTriangle,
        );
      case AppSnackBarType.info:
        return _SnackBarThemeConfig(
          surfaceColor: colors.snackBarInfoBg,
          borderColor: colors.snackBarInfoBorder,
          badgeColor: colors.snackBarInfoBadge,
          iconColor: colors.snackBarInfoIcon,
          textColor: colors.snackBarInfoText,
          icon: LucideIcons.info,
        );
    }
  }
}

class _SnackBarThemeConfig {
  final Color surfaceColor;
  final Color borderColor;
  final Color badgeColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  const _SnackBarThemeConfig({
    required this.surfaceColor,
    required this.borderColor,
    required this.badgeColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
