import 'package:flutter/material.dart';

class WalletLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final double outlineWidth;
  final double borderRadius;

  const WalletLogo({
    super.key,
    this.size = 96,
    this.iconSize = 48,
    this.outlineWidth = 8,
    this.borderRadius = 28,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize = size + (outlineWidth * 2);
    return Image.asset(
      'assets/logo/logo.png',
      width: totalSize,
      height: totalSize,
      fit: BoxFit.contain,
    );
  }
}
