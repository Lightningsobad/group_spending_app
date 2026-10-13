import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/constants/app_colors.dart';

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

    final colors = context.colors;
    final resolvedBaseColor = baseColor ?? colors.shimmerBase;
    final resolvedHighlightColor = highlightColor ?? colors.shimmerHighlight;

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
