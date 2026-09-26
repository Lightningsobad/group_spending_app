import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedBaseColor = baseColor ??
        (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0));
    final resolvedHighlightColor = highlightColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC));

    return Shimmer.fromColors(
      baseColor: resolvedBaseColor,
      highlightColor: resolvedHighlightColor,
      child: child,
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final ShapeBorder? shape;

  const AppShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    if (shape != null) {
      return Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: shape!,
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
