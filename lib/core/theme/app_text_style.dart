import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  AppTextStyle._();

  /// Hàm tạo TextStyle linh hoạt sử dụng font Nunito cho toàn bộ ứng dụng.
  /// Hỗ trợ truyền tùy chọn tất cả các tham số: fontSize, fontWeight, color, height, letterSpacing, decoration...
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
    TextBaseline? textBaseline,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) {
    return GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      shadows: shadows,
    );
  }

  /// Alias nunito gọi trực tiếp
  static TextStyle nunito({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
    FontStyle? fontStyle,
    TextBaseline? textBaseline,
    List<Shadow>? shadows,
    TextOverflow? overflow,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        decorationColor: decorationColor,
        fontStyle: fontStyle,
        textBaseline: textBaseline,
        shadows: shadows,
        overflow: overflow,
      );

  // Các helper tiện ích theo độ đậm (FontWeight)
  static TextStyle regular({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle medium({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle semiBold({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle bold({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle extraBold({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  static TextStyle black({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      style(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );
}

typedef AppTextStyles = AppTextStyle;
