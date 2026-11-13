import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_spending_app/core/theme/app_text_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  test('AppTextStyle returns Nunito font with custom properties', () {
    final textStyle = AppTextStyle.style(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: Colors.blue,
      letterSpacing: 0.5,
    );

    expect(textStyle.fontSize, 18);
    expect(textStyle.fontWeight, FontWeight.w700);
    expect(textStyle.color, Colors.blue);
    expect(textStyle.letterSpacing, 0.5);
    expect(textStyle.fontFamily, contains('Nunito'));
  });

  test('AppTextStyles alias works identical to AppTextStyle', () {
    final textStyle = AppTextStyles.nunito(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    expect(textStyle.fontSize, 14);
    expect(textStyle.fontWeight, FontWeight.w400);
    expect(textStyle.fontFamily, contains('Nunito'));
  });
}
