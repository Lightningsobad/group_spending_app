import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';

class VietQrModalSheet extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String accountName;

  const VietQrModalSheet({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  static Future<void> show(
    BuildContext context, {
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VietQrModalSheet(
        bankName: bankName,
        accountNumber: accountNumber,
        accountName: accountName,
      ),
    );
  }

  String get _vietQrUrl {
    final cleanBank = Uri.encodeComponent(bankName.replaceAll(' ', ''));
    final cleanAcc = Uri.encodeComponent(accountNumber.trim());
    final cleanName = Uri.encodeComponent(accountName.trim());
    return 'https://img.vietqr.io/image/$cleanBank-$cleanAcc-compact2.png?accountName=$cleanName';
  }

  void _copyAccountNumber(BuildContext context) {
    Clipboard.setData(ClipboardData(text: accountNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.copiedAccountNumber),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr.vietQrCodeButton,
                style: AppTextStyle.bold(
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, size: 20, color: colors.textMuted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Image Frame
          Center(
            child: Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                _vietQrUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.qrCode,
                          size: 64, color: AppColors.emerald),
                      const SizedBox(height: 8),
                      Text(
                        accountNumber,
                        style: AppTextStyle.bold(
                            fontSize: 13, color: colors.textPrimary),
                      ),
                    ],
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Bank Info Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bankName,
                      style: AppTextStyle.bold(
                        fontSize: 14,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      accountName,
                      style: AppTextStyle.bold(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      accountNumber,
                      style: AppTextStyle.bold(
                        fontSize: 16,
                        color: AppColors.emeraldForest,
                        letterSpacing: 0.8,
                      ),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        side: const BorderSide(color: AppColors.emerald),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _copyAccountNumber(context),
                      icon: const Icon(LucideIcons.copy,
                          size: 13, color: AppColors.emerald),
                      label: Text(
                        tr.copyAction,
                        style: AppTextStyle.bold(
                            fontSize: 11, color: AppColors.emerald),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
