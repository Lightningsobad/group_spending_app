import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/core/theme/app_theme_colors.dart';

void main() {
  group('AppThemeColors Tests', () {
    test('light and dark palettes have defined colors', () {
      expect(AppThemeColors.light.background, isNotNull);
      expect(AppThemeColors.light.cardBackground, equals(Colors.white));
      expect(AppThemeColors.light.textPrimary, isNotNull);
      expect(AppThemeColors.light.textSecondary, isNotNull);
      expect(AppThemeColors.light.shimmerBase, isNotNull);
      expect(AppThemeColors.light.fundPiggyBg, isNotNull);
      expect(AppThemeColors.light.fundStatusCollectingBg, isNotNull);
      expect(AppThemeColors.light.qrCardBg, equals(Colors.white));
      expect(AppThemeColors.light.qrCardBorder, isNotNull);
      expect(AppThemeColors.light.qrQuietZoneBg, equals(Colors.white));
      expect(AppThemeColors.light.qrQuietZoneBorder, isNotNull);
      expect(AppThemeColors.light.qrTabActiveBg, isNotNull);
      expect(AppThemeColors.light.qrCodeForeground, isNotNull);
      expect(AppThemeColors.light.inviteBannerBg, isNotNull);
      expect(AppThemeColors.light.scannerBackground, isNotNull);
      expect(AppThemeColors.light.scannerCorner, isNotNull);
      expect(AppThemeColors.light.qrMockupCard, equals(Colors.white));
      expect(AppThemeColors.light.qrMockupFinder, isNotNull);
      expect(AppThemeColors.light.qrMockupDot, isNotNull);

      expect(AppThemeColors.dark.background, isNotNull);
      expect(AppThemeColors.dark.cardBackground, isNot(equals(Colors.white)));
      expect(AppThemeColors.dark.textPrimary, isNotNull);
      expect(AppThemeColors.dark.textSecondary, isNotNull);
      expect(AppThemeColors.dark.shimmerBase, isNotNull);
      expect(AppThemeColors.dark.fundPiggyBg, isNotNull);
      expect(AppThemeColors.dark.fundStatusCollectingBg, isNotNull);
      expect(AppThemeColors.dark.qrCardBg, isNot(equals(Colors.white)));
      expect(AppThemeColors.dark.qrCardBorder, isNotNull);
      expect(AppThemeColors.dark.qrQuietZoneBg, equals(Colors.white));
      expect(AppThemeColors.dark.qrQuietZoneBorder, isNotNull);
      expect(AppThemeColors.dark.qrTabActiveBg, isNotNull);
      expect(AppThemeColors.dark.qrCodeForeground, isNotNull);
      expect(AppThemeColors.dark.inviteBannerBg, isNotNull);
      expect(AppThemeColors.dark.scannerBackground, isNotNull);
      expect(AppThemeColors.dark.scannerCorner, isNotNull);
      expect(AppThemeColors.dark.qrMockupCard, isNot(equals(Colors.white)));
      expect(AppThemeColors.dark.qrMockupFinder, isNotNull);
      expect(AppThemeColors.dark.qrMockupDot, isNotNull);
    });

    testWidgets('context.colors resolves light and dark palettes accurately', (tester) async {
      late AppThemeColors resolvedColors;

      // Test Light Theme
      await tester.pumpWidget(
        MaterialApp(
          key: const ValueKey('light_app'),
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              resolvedColors = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolvedColors.cardBackground, equals(Colors.white));
      expect(resolvedColors.background, equals(AppThemeColors.light.background));

      // Test Dark Theme
      await tester.pumpWidget(
        MaterialApp(
          key: const ValueKey('dark_app'),
          theme: AppTheme.darkTheme,
          home: Builder(
            builder: (context) {
              resolvedColors = context.colors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        resolvedColors.cardBackground,
        equals(AppThemeColors.dark.cardBackground),
      );
      expect(resolvedColors.background, equals(AppThemeColors.dark.background));
    });
  });
}
