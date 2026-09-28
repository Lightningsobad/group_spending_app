import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// Widget vẽ mã QR bằng Canvas thông qua thư viện `qr: ^4.0.0`
class QrCodeWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color color;
  final Color backgroundColor;
  final QrErrorCorrectLevel errorCorrectLevel;

  const QrCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.color = const Color(0xFF047857),
    this.backgroundColor = Colors.white,
    this.errorCorrectLevel = QrErrorCorrectLevel.medium,
  });

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return Container(
        width: size,
        height: size,
        color: backgroundColor,
        alignment: Alignment.center,
        child: const Icon(Icons.qr_code, size: 48, color: Colors.grey),
      );
    }

    try {
      final qrCode = QrCode(
        payload: QrPayload.fromString(data),
        errorCorrectLevel: errorCorrectLevel,
      );
      final qrImage = QrImage(qrCode);

      return CustomPaint(
        size: Size(size, size),
        painter: QrCodePainter(
          qrImage: qrImage,
          color: color,
          backgroundColor: backgroundColor,
        ),
      );
    } catch (_) {
      return Container(
        width: size,
        height: size,
        color: backgroundColor,
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, size: 48, color: Colors.grey),
      );
    }
  }
}

class QrCodePainter extends CustomPainter {
  final QrImage qrImage;
  final Color color;
  final Color backgroundColor;

  QrCodePainter({
    required this.qrImage,
    required this.color,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundColor != Colors.transparent) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = backgroundColor,
      );
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final moduleCount = qrImage.moduleCount;
    final moduleSize = size.width / moduleCount;

    for (int r = 0; r < moduleCount; r++) {
      for (int c = 0; c < moduleCount; c++) {
        if (qrImage.isDark(r, c)) {
          // Slight overlap to prevent subpixel white seams
          final rect = Rect.fromLTWH(
            c * moduleSize,
            r * moduleSize,
            moduleSize + 0.1,
            moduleSize + 0.1,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) {
    return oldDelegate.qrImage != qrImage ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
