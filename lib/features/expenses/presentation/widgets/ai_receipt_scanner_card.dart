import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/l10n.dart';

class AiReceiptScannerCard extends StatelessWidget {
  final bool isScanning;
  final File? receiptFile;
  final String? receiptUrl;
  final String? scanConfidence;
  final VoidCallback onCapturePressed;
  final VoidCallback onPickGalleryPressed;
  final VoidCallback? onRemoveReceipt;
  final VoidCallback? onViewReceipt;

  const AiReceiptScannerCard({
    super.key,
    required this.isScanning,
    this.receiptFile,
    this.receiptUrl,
    this.scanConfidence,
    required this.onCapturePressed,
    required this.onPickGalleryPressed,
    this.onRemoveReceipt,
    this.onViewReceipt,
  });

  bool get hasReceipt => receiptFile != null || (receiptUrl != null && receiptUrl!.trim().isNotEmpty);
  bool get isLowConfidence => scanConfidence?.toUpperCase() == 'LOW';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Icon + QUÉT HÓA ĐƠN AI + Tùy chọn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 16,
                      color: colors.brandEmerald,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.aiReceiptScannerCaps,
                        style: AppTextStyle.bold(
                          fontSize: AppFontSize.caption,
                          letterSpacing: 0.5,
                          color: colors.brandEmerald,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.optionalLabel,
                style: AppTextStyle.regular(
                  fontSize: AppFontSize.caption,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content State
          if (isScanning)
            _buildScanningState(colors, l10n)
          else if (hasReceipt)
            _buildReceiptPreview(context, colors, l10n)
          else
            _buildActionButtons(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildScanningState(AppThemeColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.scannerHighlightBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.scannerHighlightBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colors.brandEmerald),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiScanningReceipt,
                  style: AppTextStyle.bold(
                    fontSize: AppFontSize.secondary,
                    color: colors.scannerHighlightText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.aiScanningReceiptDesc,
                  style: AppTextStyle.regular(
                    fontSize: AppFontSize.caption,
                    color: colors.brandEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppThemeColors colors, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            // Nút Chụp ảnh (Camera) - đảm bảo touch target >= 48px
            Expanded(
              child: Material(
                color: colors.scannerHighlightBg,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onCapturePressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.scannerHighlightBorder),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.camera,
                            size: 18,
                            color: colors.scannerHighlightText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.capturePhotoAction,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.secondary,
                              color: colors.scannerHighlightText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nút Tải ảnh lên (Gallery) - đảm bảo touch target >= 48px
            Expanded(
              child: Material(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onPickGalleryPressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.cardBorder),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.upload,
                            size: 18,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.uploadPhotoAction,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.secondary,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Chú thích
        Text(
          l10n.uploadReceiptHelper,
          textAlign: TextAlign.center,
          style: AppTextStyle.regular(
            fontSize: AppFontSize.caption,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(BuildContext context, AppThemeColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Thumbnail (52x52 >= 48x48)
              GestureDetector(
                onTap: onViewReceipt,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Colors.black12,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (receiptFile != null)
                          Image.file(
                            receiptFile!,
                            fit: BoxFit.cover,
                          )
                        else if (receiptUrl != null)
                          Image.network(
                            receiptUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(LucideIcons.image, size: 24),
                            ),
                          ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.15),
                          child: const Center(
                            child: Icon(
                              LucideIcons.zoomIn,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status & Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.checkCircle2,
                          size: 15,
                          color: colors.badgeSuccess,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            l10n.receiptScannedAndAttached,
                            style: AppTextStyle.bold(
                              fontSize: AppFontSize.caption,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLowConfidence
                          ? l10n.blurryReceiptWarning
                          : l10n.receiptAutofilledNotice,
                      style: AppTextStyle.regular(
                        fontSize: AppFontSize.caption,
                        color: isLowConfidence ? colors.badgeWarningText : colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button (IconButton has default 48x48 touch target)
              if (onRemoveReceipt != null)
                IconButton(
                  icon: Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: colors.dangerText,
                  ),
                  tooltip: l10n.removeReceiptTooltip,
                  onPressed: onRemoveReceipt,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 8),

          // Action row với Wrap chống overflow, touch target >= 48px và khoảng cách >= 8px
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (onViewReceipt != null)
                TextButton.icon(
                  onPressed: onViewReceipt,
                  icon: const Icon(LucideIcons.eye, size: 15),
                  label: Text(l10n.viewPhotoAction),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: const Size(60, 48),
                    foregroundColor: colors.brandEmerald,
                    textStyle: AppTextStyle.bold(fontSize: AppFontSize.caption),
                  ),
                ),
              TextButton.icon(
                onPressed: onCapturePressed,
                icon: const Icon(LucideIcons.camera, size: 15),
                label: Text(l10n.retakePhotoAction),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(60, 48),
                  foregroundColor: colors.textSecondary,
                  textStyle: AppTextStyle.bold(fontSize: AppFontSize.caption),
                ),
              ),
              TextButton.icon(
                onPressed: onPickGalleryPressed,
                icon: const Icon(LucideIcons.image, size: 15),
                label: Text(l10n.changePhotoAction),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(60, 48),
                  foregroundColor: colors.textSecondary,
                  textStyle: AppTextStyle.bold(fontSize: AppFontSize.caption),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
