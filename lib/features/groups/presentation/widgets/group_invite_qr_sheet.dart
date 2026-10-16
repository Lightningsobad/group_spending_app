import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../data/models/group_model.dart';
import '../cubit/groups_cubit.dart';
import 'group_category_helper.dart';
import 'qr_code_widget.dart';

class GroupInviteQrSheet extends StatefulWidget {
  final GroupModel group;
  final bool isLoading;

  const GroupInviteQrSheet({
    super.key,
    required this.group,
    this.isLoading = false,
  });

  static Future<void> show(BuildContext context, GroupModel group) {
    Widget sheet = GroupInviteQrSheet(group: group);
    try {
      final cubit = context.read<GroupsCubit>();
      sheet = BlocProvider.value(value: cubit, child: sheet);
    } catch (_) {}

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  State<GroupInviteQrSheet> createState() => _GroupInviteQrSheetState();
}

class _GroupInviteQrSheetState extends State<GroupInviteQrSheet> {
  late GroupModel _group = widget.group;
  bool _isLoadingDetail = false;
  int _selectedTabIndex = 0; // 0: Mã QR Code, 1: Sao chép mã mời
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchGroupDetail();
  }

  Future<void> _fetchGroupDetail() async {
    if (_group.id <= 0) return;
    try {
      final cubit = context.read<GroupsCubit?>();
      if (cubit != null) {
        setState(() => _isLoadingDetail = true);
        final latest = await cubit.loadGroupDetails(_group.id);
        if (mounted && latest != null) {
          setState(() {
            _group = latest;
            _isLoadingDetail = false;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingDetail = false);
    }
  }

  void _copyInviteCode(String code) {
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    AppSnackBar.show(
      context,
      message: '${context.l10n.groupInviteCodePrefix} $code',
      type: AppSnackBarType.success,
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
      final file = File('${tempDir.path}/qr_${_group.inviteCode ?? "invite"}.png');
      await file.writeAsBytes(bytes);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: tr.downloadQrSuccess,
          type: AppSnackBarType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: tr.downloadQrFailed,
          type: AppSnackBarType.error,
        );
      }
    }
  }

  Future<void> _shareQrImage() async {
    final tr = context.l10n;
    final code = _group.inviteCode ?? '';
    final text = '${_group.name} - ${tr.groupInviteCodePrefix} $code';

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

  Future<void> _shareInviteCodeText() async {
    final tr = context.l10n;
    final code = _group.inviteCode ?? '';
    final text = '${_group.name} - ${tr.groupInviteCodePrefix} $code';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;
    final isPageLoading = widget.isLoading || _isLoadingDetail;

    final screenHeight = MediaQuery.of(context).size.height;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.35,
      child: Container(
        constraints: screenHeight > 0
            ? BoxConstraints(maxHeight: screenHeight * 0.92)
            : const BoxConstraints(),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
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
                      color: colors.dragHandle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                if (isPageLoading)
                  _buildSkeleton(context, colors)
                else
                  _buildContent(context, colors, tr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context, AppThemeColors colors) {
    return AppShimmer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row Skeleton
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const AppShimmerBox(width: 44, height: 44, borderRadius: 14),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmerBox(width: 150, height: 18, borderRadius: 4),
                    SizedBox(height: 6),
                    AppShimmerBox(width: 110, height: 13, borderRadius: 4),
                  ],
                ),
              ),
              const AppShimmerBox(width: 40, height: 40, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 18),

          // Tabs Skeleton
          const Row(
            children: [
              Expanded(
                child: AppShimmerBox(height: 52, borderRadius: 16),
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppShimmerBox(height: 52, borderRadius: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Center Card Skeleton
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
            ),
            child: const Column(
              children: [
                AppShimmerBox(width: 210, height: 210, borderRadius: 16),
                SizedBox(height: 16),
                AppShimmerBox(width: 140, height: 16, borderRadius: 4),
                SizedBox(height: 6),
                AppShimmerBox(width: 220, height: 12, borderRadius: 4),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AppShimmerBox(height: 48, borderRadius: 12)),
                    SizedBox(width: 10),
                    Expanded(child: AppShimmerBox(height: 48, borderRadius: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Close button skeleton
          const AppShimmerBox(height: 48, borderRadius: 12),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppThemeColors colors,
    AppLocalizations tr,
  ) {
    final code = _group.inviteCode ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              alignment: Alignment.center,
              child: GroupCategoryHelper.buildIcon(
                _group.category,
                width: 24,
                height: 24,
              ),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_group.name} • ${GroupCategoryHelper.getLabel(_group.category)} • ${_group.memberCount} ${tr.membersCountLabel.toLowerCase()}',
                    style: AppTextStyle.medium(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(LucideIcons.x, color: colors.textMuted, size: 22),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Mode Selection Tabs Row (No subtitle per UX request)
        Row(
          children: [
            // Tab 0: Mã QR Code
            Expanded(
              child: GestureDetector(
                key: const ValueKey('tab_qr_code'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 0
                        ? colors.qrTabActiveBg
                        : colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedTabIndex == 0
                          ? colors.qrTabActiveBorder
                          : colors.cardBorder,
                      width: _selectedTabIndex == 0 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? colors.qrTabIconActiveBg
                              : colors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedTabIndex == 0
                              ? null
                              : Border.all(color: colors.cardBorder),
                        ),
                        child: Icon(
                          LucideIcons.qrCode,
                          size: 16,
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr.tabQrCode,
                          style: AppTextStyle.bold(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedTabIndex == 0)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: colors.qrTabActiveBorder,
                            shape: BoxShape.circle,
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
                key: const ValueKey('tab_copy_code'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == 1
                        ? colors.qrTabActiveBg
                        : colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _selectedTabIndex == 1
                          ? colors.qrTabActiveBorder
                          : colors.cardBorder,
                      width: _selectedTabIndex == 1 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? colors.qrTabIconActiveBg
                              : colors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedTabIndex == 1
                              ? null
                              : Border.all(color: colors.cardBorder),
                        ),
                        child: Icon(
                          LucideIcons.copy,
                          size: 16,
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tr.tabCopyCode,
                          style: AppTextStyle.bold(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_selectedTabIndex == 1)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: colors.qrTabActiveBorder,
                            shape: BoxShape.circle,
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

        // Distinct content by tab
        if (_selectedTabIndex == 0)
          _buildQrTabContent(context, colors, tr, code)
        else
          _buildCopyCodeTabContent(context, colors, tr, code),

        const SizedBox(height: 14),

        // Bottom Close Button (Touch target >= 48px)
        OutlinedButton(
          key: const ValueKey('btn_close_sheet'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
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
    );
  }

  Widget _buildQrTabContent(
    BuildContext context,
    AppThemeColors colors,
    AppLocalizations tr,
    String code,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: colors.qrCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.qrCardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.qrQuietZoneBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.qrQuietZoneBorder,
                        width: 1.5,
                      ),
                    ),
                    child: QrCodeWidget(
                      data: code,
                      size: 200,
                      color: colors.qrCodeForeground,
                      backgroundColor: colors.qrQuietZoneBg,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _group.name,
                    style: AppTextStyle.bold(
                      fontSize: 16,
                      color: colors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

          // Action buttons (>= 48px height, non-overflowing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('btn_download_qr'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                      fontSize: 13.5,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('btn_share_qr'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.qrShareButtonBg,
                    foregroundColor: colors.qrShareButtonFg,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _shareQrImage,
                  icon: Icon(LucideIcons.share2, size: 16, color: colors.qrShareButtonFg),
                  label: Text(
                    tr.shareViaOtherAppsAction,
                    style: AppTextStyle.semiBold(
                      fontSize: 13.5,
                      color: colors.qrShareButtonFg,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCopyCodeTabContent(
    BuildContext context,
    AppThemeColors colors,
    AppLocalizations tr,
    String code,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner code display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: colors.inviteBannerBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.inviteBannerBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.ticket,
                      size: 16,
                      color: colors.inviteBannerTitle,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tr.inviteCodeCardTitle,
                      style: AppTextStyle.bold(
                        fontSize: 11,
                        color: colors.inviteBannerTitle,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  code,
                  style: AppTextStyle.bold(
                    fontSize: 24,
                    color: colors.textPrimary,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  tr.copyCodeInstruction,
                  style: AppTextStyle.regular(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary copy button
          ElevatedButton.icon(
            key: const ValueKey('btn_copy_code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.inviteBannerButtonBg,
              foregroundColor: colors.inviteBannerButtonFg,
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () => _copyInviteCode(code),
            icon: Icon(LucideIcons.copy, size: 18, color: colors.inviteBannerButtonFg),
            label: Text(
              tr.copyInviteCodeAction,
              style: AppTextStyle.bold(
                fontSize: 14,
                color: colors.inviteBannerButtonFg,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Secondary share text button
          OutlinedButton.icon(
            key: const ValueKey('btn_share_code'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: colors.cardBorder),
            ),
            onPressed: _shareInviteCodeText,
            icon: Icon(
              LucideIcons.share2,
              size: 18,
              color: colors.textPrimary,
            ),
            label: Text(
              tr.shareCodeAction,
              style: AppTextStyle.semiBold(
                fontSize: 14,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
