import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/analytics/domain/entities/expense_history_entity.dart';
import 'package:group_spending_app/features/analytics/domain/entities/leaderboard_entity.dart';
import 'package:group_spending_app/features/analytics/presentation/widgets/expense_history_detail_sheet.dart';
import 'package:group_spending_app/features/analytics/presentation/widgets/analytics_group_card.dart';
import 'package:group_spending_app/features/analytics/presentation/widgets/leaderboard_section.dart';
import 'package:group_spending_app/features/groups/data/models/group_summary_model.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('Analytics Widgets & UX Enhancements Tests', () {
    const mockExpense = ExpenseHistoryItemEntity(
      id: 101,
      groupId: 42,
      groupName: 'Nhóm Du Lịch Đà Lạt',
      title: 'Buffet nướng BBQ',
      expenseDate: '2026-03-15T18:30:00Z',
      totalAmountVnd: 550000,
      categoryName: 'Food',
      paidByUserName: 'Trần Văn A',
    );

    const mockMembers = [
      LeaderboardMemberEntity(
        rank: 1,
        userId: 1,
        fullName: 'Nguyễn Văn Nhất',
        contributedAmountVnd: 5000000,
        percentage: 50.0,
        expenseCount: 10,
      ),
      LeaderboardMemberEntity(
        rank: 2,
        userId: 2,
        fullName: 'Trần Thị Nhì',
        contributedAmountVnd: 3000000,
        percentage: 30.0,
        expenseCount: 6,
      ),
      LeaderboardMemberEntity(
        rank: 3,
        userId: 3,
        fullName: 'Lê Văn Ba',
        contributedAmountVnd: 2000000,
        percentage: 20.0,
        expenseCount: 4,
      ),
    ];

    Widget buildTestHarness(Widget child, {ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: const Locale('vi'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    testWidgets('ExpenseHistoryDetailSheet displays details and handles actions', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        buildTestHarness(
          Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ExpenseHistoryDetailSheet.show(
                  context,
                  expense: mockExpense,
                  onViewGroupAnalytics: () {
                    actionTapped = true;
                  },
                );
              },
              child: const Text('Mở chi tiết'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Mở chi tiết'));
      await tester.pumpAndSettle();

      // Modal title
      expect(find.text('Chi tiết hóa đơn'), findsOneWidget);
      // Item title & amount
      expect(find.text('Buffet nướng BBQ'), findsOneWidget);
      expect(find.text('550.000 đ'), findsOneWidget);
      // Metadata (category, group, payer)
      expect(find.text('Ăn uống'), findsOneWidget);
      expect(find.text('Nhóm Du Lịch Đà Lạt'), findsOneWidget);
      expect(find.text('Người trả: Trần Văn A'), findsOneWidget);

      // Tap "Xem thống kê nhóm"
      final viewGroupBtn = find.text('Xem thống kê nhóm');
      expect(viewGroupBtn, findsOneWidget);
      await tester.tap(viewGroupBtn);
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets('LeaderboardSection renders top ranks with badges in Light and Dark mode', (tester) async {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(
          buildTestHarness(
            SingleChildScrollView(
              child: LeaderboardSection(
                title: 'Bảng xếp hạng',
                memberCount: 3,
                members: mockMembers,
              ),
            ),
            theme: theme,
          ),
        );
        await tester.pumpAndSettle();

        // Renders rank names
        expect(find.text('Nguyễn Văn Nhất'), findsOneWidget);
        expect(find.text('Trần Thị Nhì'), findsOneWidget);
        expect(find.text('Lê Văn Ba'), findsOneWidget);

        // Vector rank numbers
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);

        // Formatted amounts
        expect(find.text('5.000.000 đ'), findsOneWidget);
        expect(find.text('3.000.000 đ'), findsOneWidget);
        expect(find.text('2.000.000 đ'), findsOneWidget);
      }
    });
    testWidgets('AnalyticsGroupCard renders group summary info and topic icon badge', (tester) async {
      bool tapped = false;
      const summary = GroupSummaryModel(
        id: 10,
        name: 'Nhóm bóng đá thứ 6',
        category: 'Sport & Clubs',
        totalSpendingVnd: 1500000,
        memberCount: 6,
      );

      await tester.pumpWidget(
        buildTestHarness(
          AnalyticsGroupCard(
            group: summary,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhóm bóng đá thứ 6'), findsOneWidget);
      expect(find.text('6 thành viên'), findsOneWidget);
      expect(find.text('Tổng chi tiêu'), findsOneWidget);
      expect(find.text('1.500.000 đ'), findsOneWidget);
      expect(find.byIcon(LucideIcons.trophy), findsOneWidget);

      await tester.tap(find.text('Nhóm bóng đá thứ 6'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AnalyticsGroupCard falls back to default layoutGrid icon when category is missing', (tester) async {
      const summary = GroupSummaryModel(
        id: 11,
        name: 'Nhóm chưa có chủ đề',
        totalSpendingVnd: 500000,
        memberCount: 2,
      );

      await tester.pumpWidget(
        buildTestHarness(
          AnalyticsGroupCard(
            group: summary,
            onTap: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nhóm chưa có chủ đề'), findsOneWidget);
      expect(find.byIcon(LucideIcons.layoutGrid), findsOneWidget);
    });
  });
}
