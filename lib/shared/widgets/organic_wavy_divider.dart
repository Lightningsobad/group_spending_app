import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class OrganicWavyDivider extends StatelessWidget {
  final double height;
  final Color fillColor;

  const OrganicWavyDivider({
    super.key,
    this.height = 56,
    this.fillColor = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _WavyDividerPainter(fillColor)),
    );
  }
}

class _WavyDividerPainter extends CustomPainter {
  final Color color;

  _WavyDividerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final sx = size.width / 393.0;
    final sy = size.height / 72.0;

    path.moveTo(0 * sx, 32 * sy);
    path.cubicTo(95 * sx, 68 * sy, 185 * sx, 12 * sy, 285 * sx, 38 * sy);
    path.cubicTo(335 * sx, 48 * sy, 368 * sx, 32 * sy, 393 * sx, 20 * sy);
    path.lineTo(393 * sx, 72 * sy);
    path.lineTo(0 * sx, 72 * sy);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavyDividerPainter oldDelegate) =>
      oldDelegate.color != color;
}
