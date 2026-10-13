import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/groups_cubit.dart';
import '../utils/invite_code_parser.dart';

class JoinGroupView extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onSuccess;
  final String? initialInviteCode;

  const JoinGroupView({
    super.key,
    required this.onBack,
    this.onSuccess,
    this.initialInviteCode,
  });

  @override
  State<JoinGroupView> createState() => _JoinGroupViewState();
}

class _JoinGroupViewState extends State<JoinGroupView> {
  int _selectedTabIndex = 0; // 0: Quét mã QR, 1: Nhập mã mời
  final TextEditingController _codeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  MobileScannerController? _scannerController;

  bool _isSubmitting = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    if (widget.initialInviteCode != null &&
        widget.initialInviteCode!.trim().isNotEmpty) {
      _codeController.text = widget.initialInviteCode!.trim().toUpperCase();
      _selectedTabIndex = 1;
    }
    _initScanner();
  }

  void _initScanner() {
    try {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        returnImage: false,
      );
    } catch (_) {
      // Fallback in headless / unsupported environments
      _scannerController = null;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _handleInviteCode(String rawInput) async {
    final tr = context.l10n;
    final extracted = InviteCodeParser.extract(rawInput);

    if (extracted == null || extracted.isEmpty) {
      setState(() {
        _inlineError = tr.invalidQrCodeError;
      });
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _inlineError = null;
    });

    final success = await context.read<GroupsCubit>().joinGroup(extracted);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      widget.onSuccess?.call();
    } else {
      final cubitError = context.read<GroupsCubit>().state.errorMessage;
      setState(() {
        _inlineError = cubitError ?? tr.loadGroupsFailed;
      });
    }
  }

  Future<void> _onDetectBarcode(BarcodeCapture capture) async {
    if (_isSubmitting) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue != null && rawValue.trim().isNotEmpty) {
      // Tạm dừng scanner để tránh quét lặp liên tục
      try {
        await _scannerController?.stop();
      } catch (_) {}

      await _handleInviteCode(rawValue);

      // Nếu lỗi và vẫn ở màn hình, tiếp tục quét
      if (mounted && _inlineError != null) {
        try {
          await _scannerController?.start();
        } catch (_) {}
      }
    }
  }

  Future<void> _pickAndScanImage() async {
    final tr = context.l10n;
    try {
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile == null) return;

      setState(() {
        _isSubmitting = true;
        _inlineError = null;
      });

      final controller = _scannerController ??
          MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

      final capture = await controller.analyzeImage(xFile.path);
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (capture != null && capture.barcodes.isNotEmpty) {
        final rawVal = capture.barcodes.first.rawValue;
        if (rawVal != null) {
          await _handleInviteCode(rawVal);
          return;
        }
      }

      setState(() {
        _inlineError = tr.noQrFoundInImage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _inlineError = tr.noQrFoundInImage;
      });
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      final code = InviteCodeParser.extract(data.text) ?? data.text!.trim();
      _codeController.text = code.toUpperCase();
      setState(() {
        _inlineError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tr = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Back button row
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: widget.onBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.arrowLeft,
                        size: 18,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tr.backAction,
                        style: AppTextStyle.bold(
                          fontSize: 14,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Title Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.qrCode,
                    size: 20,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tr.joinGroupQrTitle,
                    style: AppTextStyle.bold(
                      fontSize: 20,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tr.joinGroupQrSubtitle,
              style: AppTextStyle.regular(
                fontSize: 13,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Segmented Tab Control
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabItem(
                      index: 0,
                      icon: LucideIcons.qrCode,
                      label: tr.scanQrTab,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTabItem(
                      index: 1,
                      icon: LucideIcons.keyRound,
                      label: tr.enterCodeTab,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Error banner if any
            if (_inlineError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.errorBorder),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertCircle,
                        size: 18, color: AppColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: AppTextStyle.medium(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppColors.error,
                      onPressed: () => setState(() => _inlineError = null),
                    ),
                  ],
                ),
              ),

            // 4. Tab Body
            if (_selectedTabIndex == 0)
              _buildScannerTab(colors, tr)
            else
              _buildManualInputTab(colors, tr),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final colors = context.colors;
    final isSelected = _selectedTabIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _inlineError = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF15803D)
                    : colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isSelected
                      ? AppTextStyle.bold(
                          fontSize: 13,
                          color: colors.textPrimary,
                        )
                      : AppTextStyle.medium(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerTab(dynamic colors, dynamic tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Camera Viewfinder Box
        Container(
          height: 330,
          decoration: BoxDecoration(
            color: const Color(0xFF060B1E),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live Camera Scanner
                if (_scannerController != null)
                  Positioned.fill(
                    child: MobileScanner(
                      controller: _scannerController!,
                      onDetect: _onDetectBarcode,
                      errorBuilder: (context, error) {
                        return _buildQrMockupGraphic();
                      },
                    ),
                  )
                else
                  _buildQrMockupGraphic(),

                // Corner Brackets Overlay
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: const ViewfinderCornerPainter(
                        color: Color(0xFF10B981),
                        cornerLength: 26,
                        strokeWidth: 3.5,
                      ),
                      child: Container(),
                    ),
                  ),
                ),

                // Bottom Hint Text
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tr.scanQrInstruction,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regular(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),

                // Submitting Overlay
                if (_isSubmitting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.65),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Color(0xFF10B981),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'Đang xử lý tham gia nhóm...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Secondary Action: Tải ảnh mã QR
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: colors.cardBackground,
            foregroundColor: colors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: colors.cardBorder),
          ),
          onPressed: _isSubmitting ? null : _pickAndScanImage,
          icon: Icon(
            LucideIcons.upload,
            size: 18,
            color: colors.textPrimary,
          ),
          label: Text(
            tr.uploadQrImageAction,
            style: AppTextStyle.bold(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputTab(dynamic colors, dynamic tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr.inviteCodeLabel.toUpperCase(),
                style: AppTextStyle.bold(
                  fontSize: 11,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: tr.inviteCodeHint,
                  hintStyle: AppTextStyle.regular(
                    fontSize: 14,
                    color: colors.textMuted,
                  ),
                  prefixIcon: const Icon(LucideIcons.keyRound, size: 18),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.clipboardPaste, size: 18),
                    tooltip: 'Dán mã',
                    onPressed: _pasteFromClipboard,
                  ),
                  filled: true,
                  fillColor: colors.surfaceMuted,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.emerald,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _handleInviteCode(val.trim());
                  }
                },
              ),
              const SizedBox(height: 14),
              Text(
                tr.joinGroupSubtitle,
                style: AppTextStyle.regular(
                  fontSize: 12,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          onPressed: _isSubmitting
              ? null
              : () {
                  final text = _codeController.text.trim();
                  if (text.isEmpty) {
                    setState(() {
                      _inlineError = tr.inviteCodeRequired;
                    });
                    return;
                  }
                  _handleInviteCode(text);
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  tr.joinGroupButton,
                  style: AppTextStyle.bold(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  /// Khung minh họa mã QR với logo FairShare (FS) ở giữa (giống mockup thiết kế)
  Widget _buildQrMockupGraphic() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFinderSquare(),
                    _buildGridDots(3),
                    _buildFinderSquare(),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGridDots(2),
                    const SizedBox(width: 32),
                    _buildGridDots(2),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFinderSquare(),
                    _buildGridDots(3),
                    _buildGridDots(2),
                  ],
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF15803D),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Text(
                'FS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinderSquare() {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildGridDots(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (i) => Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF334155),
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }
}

class ViewfinderCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  const ViewfinderCornerPainter({
    required this.color,
    this.cornerLength = 26.0,
    this.strokeWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final l = cornerLength;

    // Góc trên bên trái
    canvas.drawLine(Offset(0, l), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(l, 0), paint);

    // Góc trên bên phải
    canvas.drawLine(Offset(w - l, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, l), paint);

    // Góc dưới bên trái
    canvas.drawLine(Offset(0, h - l), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(l, h), paint);

    // Góc dưới bên phải
    canvas.drawLine(Offset(w - l, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), paint);
  }

  @override
  bool shouldRepaint(covariant ViewfinderCornerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth;
}
