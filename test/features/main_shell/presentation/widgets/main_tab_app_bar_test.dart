import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/main_shell/presentation/widgets/main_tab_app_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('MainTabAppBar Widget Tests', () {
    Widget buildWidget({
      required IconData icon,
      required String title,
      ThemeMode themeMode = ThemeMode.light,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: MainTabAppBar(
            icon: icon,
            title: title,
          ),
        ),
      );
    }

    testWidgets('renders icon and title with 44x44 container in light theme', (tester) async {
      await tester.pumpWidget(buildWidget(
        icon: LucideIcons.users,
        title: 'Danh sách nhóm của bạn',
      ));

      expect(find.text('Danh sách nhóm của bạn'), findsOneWidget);
      expect(find.byIcon(LucideIcons.users), findsOneWidget);

      final iconContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(LucideIcons.users),
          matching: find.byType(Container),
        ).first,
      );
      expect(iconContainer.constraints?.maxWidth, 44);
      expect(iconContainer.constraints?.maxHeight, 44);
    });

    testWidgets('renders cleanly in dark theme without exceptions', (tester) async {
      await tester.pumpWidget(buildWidget(
        icon: LucideIcons.settings,
        title: 'Cài đặt',
        themeMode: ThemeMode.dark,
      ));

      expect(find.text('Cài đặt'), findsOneWidget);
      expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    });
  });
}
