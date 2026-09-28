import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/group_model.dart';
import 'qr_code_widget.dart';

class GroupInviteQrSheet extends StatefulWidget {
  final GroupModel group;

  const GroupInviteQrSheet({super.key, required this.group});

  static Future<void> show(BuildContext context, GroupModel group) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GroupInviteQrSheet(group: group),
    );
  }

  @override
  State<GroupInviteQrSheet> createState() => _GroupInviteQrSheetState();
}

class _GroupInviteQrSheetState extends State<GroupInviteQrSheet> {
  int _selectedTabIndex = 0; // 0: Mã QR Code, 1: Sao chép mã mời
  final GlobalKey _qrKey = GlobalKey();

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.l10n.groupInviteCodePrefix} $code'),
        backgroundColor: AppColors.emerald,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _downloadQrImage() async {
    final tr = context.l10n;
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_${widget.group.inviteCode ?? "invite"}.png');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.downloadQrSuccess),
            backgroundColor: AppColors.emerald,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr.downloadQrFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _shareInvite() async {
    final tr = context.l10n;
    final code = widget.group.inviteCode ?? '';
    final text = '${widget.group.name} - ${tr.groupInviteCodePrefix} $code';

    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/qr_$code.png');
          await file.writeAsBytes(byteData.buffer.asUint8List());
          await SharePlus.instance.share(
            ShareParams(
              text: text,
              files: [XFile(file.path)],
            ),
          );
          return;
        }
      }
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final code = widget.group.inviteCode ?? '';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: colors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏢', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr.inviteMembersTitle,
                          style: AppTextStyle.bold(
                            fontSize: 18,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.group.name} • ${widget.group.memberCount} ${tr.membersCountLabel.toLowerCase()}',
                          style: AppTextStyle.medium(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: colors.textMuted, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Mode Selection Tabs Row
              Row(
                children: [
                  // Tab 0: Mã QR Code
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? const Color(0xFFF0FDF4)
                              : colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedTabIndex == 0
                                ? const Color(0xFF15803D)
                                : colors.cardBorder,
                            width: _selectedTabIndex == 0 ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF15803D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    LucideIcons.qrCode,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                if (_selectedTabIndex == 0)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF15803D),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tr.tabQrCode,
                              style: AppTextStyle.bold(
                                fontSize: 14,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr.tabQrCodeSubtitle,
                              style: AppTextStyle.regular(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tab 1: Sao chép mã mời
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedTabIndex = 1);
                        _copyInviteCode(code);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? const Color(0xFFF0FDF4)
                              : colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedTabIndex == 1
                                ? const Color(0xFF15803D)
                                : colors.cardBorder,
                            width: _selectedTabIndex == 1 ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colors.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.cardBorder),
                              ),
                              child: Icon(
                                LucideIcons.copy,
                                size: 16,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              tr.tabCopyCode,
                              style: AppTextStyle.bold(
                                fontSize: 14,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tr.tabCopyCodeSubtitle,
                              style: AppTextStyle.regular(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Center Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    RepaintBoundary(
                      key: _qrKey,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrCodeWidget(
                              data: code,
                              size: 210,
                              color: const Color(0xFF047857),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.group.name,
                              style: AppTextStyle.bold(
                                fontSize: 16,
                                color: colors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr.scanToJoinInstruction,
                              style: AppTextStyle.regular(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons: Tải ảnh mã QR & Chia sẻ qua ứng dụng khác
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: colors.cardBorder),
                            ),
                            onPressed: _downloadQrImage,
                            icon: Icon(
                              LucideIcons.download,
                              size: 16,
                              color: colors.textPrimary,
                            ),
                            label: Text(
                              tr.downloadQrAction,
                              style: AppTextStyle.semiBold(
                                fontSize: 13,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14532D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _shareInvite,
                            icon: const Icon(LucideIcons.share2, size: 16),
                            label: Text(
                              tr.shareViaOtherAppsAction,
                              style: AppTextStyle.semiBold(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Invite Code Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr.inviteCodeCardTitle,
                            style: AppTextStyle.bold(
                              fontSize: 10,
                              color: const Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            code,
                            style: AppTextStyle.bold(
                              fontSize: 18,
                              color: colors.textPrimary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _copyInviteCode(code),
                      icon: const Icon(LucideIcons.copy, size: 15, color: Colors.white),
                      label: Text(
                        tr.copyInviteCodeAction,
                        style: AppTextStyle.bold(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Bottom Close Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colors.cardBorder),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  tr.closeButton,
                  style: AppTextStyle.bold(
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
