import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

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
              Row(
                children: [
                  const Icon(
                    LucideIcons.sparkles,
                    size: 15,
                    color: Color(0xFF14532D),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'QUÉT HÓA ĐƠN AI',
                    style: AppTextStyle.bold(
                      fontSize: 11,
                      color: const Color(0xFF14532D),
                    ),
                  ),
                ],
              ),
              Text(
                'Tùy chọn',
                style: AppTextStyle.regular(
                  fontSize: 11,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content State
          if (isScanning)
            _buildScanningState(colors)
          else if (hasReceipt)
            _buildReceiptPreview(context, colors)
          else
            _buildActionButtons(colors),
        ],
      ),
    );
  }

  Widget _buildScanningState(dynamic colors) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF047857)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI đang phân tích hóa đơn...',
                  style: AppTextStyle.bold(
                    fontSize: 13,
                    color: const Color(0xFF14532D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bóc tách tổng tiền, chi tiết món và danh mục',
                  style: AppTextStyle.regular(
                    fontSize: 11,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic colors) {
    return Column(
      children: [
        Row(
          children: [
            // Nút Chụp ảnh (Camera)
            Expanded(
              child: InkWell(
                onTap: onCapturePressed,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.camera,
                        size: 18,
                        color: Color(0xFF14532D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chụp ảnh',
                        style: AppTextStyle.bold(
                          fontSize: 13,
                          color: const Color(0xFF14532D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nút Tải ảnh lên (Gallery)
            Expanded(
              child: InkWell(
                onTap: onPickGalleryPressed,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.upload,
                        size: 18,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tải ảnh lên',
                        style: AppTextStyle.bold(
                          fontSize: 13,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Chú thích
        Text(
          'Tải hoặc chụp ảnh hóa đơn để ghi lại thông tin nhanh gọn',
          textAlign: TextAlign.center,
          style: AppTextStyle.regular(
            fontSize: 12,
            color: colors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptPreview(BuildContext context, dynamic colors) {
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
              // Thumbnail
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
                        const Icon(
                          LucideIcons.checkCircle2,
                          size: 14,
                          color: AppColors.emerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đã quét & đính kèm hóa đơn',
                          style: AppTextStyle.bold(
                            fontSize: 12,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (isLowConfidence)
                      Text(
                        'Ảnh mờ - Vui lòng kiểm tra lại thông tin',
                        style: AppTextStyle.regular(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      )
                    else
                      Text(
                        'Thông tin đã được tự động điền vào form',
                        style: AppTextStyle.regular(
                          fontSize: 11,
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),

              // Delete button
              if (onRemoveReceipt != null)
                IconButton(
                  icon: const Icon(
                    LucideIcons.trash2,
                    size: 18,
                    color: AppColors.error,
                  ),
                  tooltip: 'Xóa hóa đơn',
                  onPressed: onRemoveReceipt,
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onViewReceipt != null)
                TextButton.icon(
                  onPressed: onViewReceipt,
                  icon: const Icon(LucideIcons.eye, size: 14),
                  label: const Text('Xem ảnh'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFF14532D),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              TextButton.icon(
                onPressed: onCapturePressed,
                icon: const Icon(LucideIcons.camera, size: 14),
                label: const Text('Chụp lại'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: colors.textSecondary,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton.icon(
                onPressed: onPickGalleryPressed,
                icon: const Icon(LucideIcons.image, size: 14),
                label: const Text('Đổi ảnh'),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: colors.textSecondary,
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
