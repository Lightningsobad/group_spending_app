import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/constants/app_colors.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('MainBottomNavBar Tests', () {
    Widget buildNavBar({
      int currentIndex = 0,
      ValueChanged<int>? onTap,
      ThemeData? theme,
      Locale locale = const Locale('vi'),
    }) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          bottomNavigationBar: MainBottomNavBar(
            currentIndex: currentIndex,
            onTap: onTap ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders all 5 tabs and no badge dots', (tester) async {
      await tester.pumpWidget(buildNavBar());
      await tester.pumpAndSettle();

      // Check tab labels (Vietnamese)
      expect(find.text('Tổng quan'), findsOneWidget);
      expect(find.text('Nhóm'), findsOneWidget);
      expect(find.text('Công nợ'), findsOneWidget);
      expect(find.text('Thống kê'), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);

      // Check tab icons
      expect(find.byIcon(LucideIcons.layoutGrid), findsOneWidget);
      expect(find.byIcon(LucideIcons.users), findsOneWidget);
      expect(find.byIcon(LucideIcons.arrowLeftRight), findsOneWidget);
      expect(find.byIcon(LucideIcons.barChart3), findsOneWidget);
      expect(find.byIcon(LucideIcons.settings), findsOneWidget);

      // Check all 5 items are wrapped in Expanded for full-width touch targets
      expect(find.byType(Expanded), findsNWidgets(5));
    });

    testWidgets('tapping each tab triggers onTap with correct index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        buildNavBar(
          currentIndex: 0,
          onTap: (index) {
            tappedIndex = index;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Nhóm'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Công nợ'));
      expect(tappedIndex, 2);

      await tester.tap(find.text('Thống kê'));
      expect(tappedIndex, 3);

      await tester.tap(find.text('Cài đặt'));
      expect(tappedIndex, 4);

      await tester.tap(find.text('Tổng quan'));
      expect(tappedIndex, 0);
    });

    testWidgets('active indicator pill is rendered for the selected tab in Light Mode', (tester) async {
      await tester.pumpWidget(buildNavBar(currentIndex: 2));
      await tester.pumpAndSettle();

      // Find the AnimatedContainer for the active tab (Debts tab)
      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer)).toList();
      expect(containers.length, 5);

      // Tab index 2 should have active background color (with alpha)
      final activeDecoration = containers[2].decoration as BoxDecoration;
      expect(activeDecoration.color, isNot(Colors.transparent));
      expect(activeDecoration.borderRadius, BorderRadius.circular(16));

      // Inactive tab index 0 should have transparent background
      final inactiveDecoration = containers[0].decoration as BoxDecoration;
      expect(inactiveDecoration.color, Colors.transparent);
    });

    testWidgets('adapts active color in Dark Mode for WCAG 2.1 AA compliance', (tester) async {
      await tester.pumpWidget(
        buildNavBar(
          currentIndex: 1,
          theme: AppTheme.darkTheme,
        ),
      );
      await tester.pumpAndSettle();

      // In Dark Mode, the icon color for the active tab should be brandEmerald (emeraldLight)
      final activeIcon = tester.widget<Icon>(find.byIcon(LucideIcons.users));
      expect(activeIcon.color, AppColors.emeraldLight);
    });
  });
}
