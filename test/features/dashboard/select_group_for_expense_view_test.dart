import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/select_group_for_expense_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('SelectGroupForExpenseView Tests', () {
    final sampleGroups = [
      const GroupModel(
        id: 1,
        name: 'Chung cư Sunrise Room',
        ownerId: 101,
        role: 'ADMIN',
        status: 'ACTIVE',
        category: 'Apartment',
        userBalance: 2450000,
        memberCount: 4,
      ),
      const GroupModel(
        id: 2,
        name: 'Đội Cầu Lông Ba Đình',
        ownerId: 102,
        role: 'MEMBER',
        status: 'ACTIVE',
        category: 'Sport & Clubs',
        userBalance: -450000,
        memberCount: 8,
      ),
      const GroupModel(
        id: 3,
        name: 'Chuyến đi Đà Lạt',
        ownerId: 103,
        role: 'MEMBER',
        status: 'ARCHIVED',
        category: 'Travel & Trip',
        userBalance: 0,
        memberCount: 5,
      ),
    ];

    Widget buildTestWidget({
      List<GroupModel>? groups,
      VoidCallback? onBack,
      ValueChanged<GroupModel>? onGroupSelected,
      VoidCallback? onCreateGroup,
      Locale locale = const Locale('vi'),
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SelectGroupForExpenseView(
            groups: groups ?? sampleGroups,
            onBack: onBack ?? () {},
            onGroupSelected: onGroupSelected ?? (_) {},
            onCreateGroup: onCreateGroup ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders header, clean text filter chips without counts, and default active groups', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Header title
      expect(find.text('Chọn nhóm muốn thêm khoản chi'), findsOneWidget);

      // Search hint
      expect(find.text('Tìm theo tên nhóm...'), findsOneWidget);

      // Status chips: clean text without number badges
      expect(find.text('Đang hoạt động'), findsOneWidget);
      expect(find.text('Tất cả nhóm'), findsOneWidget);
      expect(find.text('Tôi làm Admin'), findsOneWidget);

      // Category chips: clean text without number badges
      expect(find.text('Tất cả chủ đề'), findsOneWidget);
      expect(find.text('Căn hộ chung'), findsOneWidget);
      expect(find.text('Thể thao'), findsOneWidget);

      // By default ACTIVE is selected: groups 1 & 2 shown, group 3 (ARCHIVED) not shown
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
      expect(find.text('Chuyến đi Đà Lạt'), findsNothing);

      // Balances formatted with sign
      expect(find.text('+2.450.000 đ'), findsOneWidget);
      expect(find.text('-450.000 đ'), findsOneWidget);

      // Admin badge on group 1
      expect(find.text('Admin'), findsOneWidget);

      // Bottom action
      expect(find.text('Chưa có nhóm phù hợp?'), findsOneWidget);
      expect(find.text('Tạo nhóm'), findsOneWidget);
    });

    testWidgets('tapping back button triggers onBack callback', (tester) async {
      var backCalled = false;
      await tester.pumpWidget(buildTestWidget(onBack: () => backCalled = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('filtering by Admin status shows only admin groups', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Tôi làm Admin'
      await tester.tap(find.text('Tôi làm Admin'));
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsNothing);
    });

    testWidgets('filtering by category shows only groups with that category', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Thể thao'
      await tester.tap(find.text('Thể thao'));
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsNothing);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
    });

    testWidgets('searching by keyword filters group list in real-time', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Sunrise');
      await tester.pumpAndSettle();

      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsNothing);
    });

    testWidgets('selecting an active group triggers onGroupSelected callback', (tester) async {
      GroupModel? selected;
      await tester.pumpWidget(buildTestWidget(onGroupSelected: (g) => selected = g));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chung cư Sunrise Room'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.id, 1);
    });

    testWidgets('selecting an archived group shows warning SnackBar and does not select', (tester) async {
      GroupModel? selected;
      await tester.pumpWidget(buildTestWidget(onGroupSelected: (g) => selected = g));
      await tester.pumpAndSettle();

      // Switch to 'Tất cả nhóm' to see archived group
      await tester.tap(find.text('Tất cả nhóm'));
      await tester.pumpAndSettle();

      expect(find.text('Chuyến đi Đà Lạt'), findsOneWidget);

      await tester.tap(find.text('Chuyến đi Đà Lạt'));
      await tester.pump();

      // Warning snackbar
      expect(find.text('Nhóm này đã được lưu trữ, không thể thêm khoản chi.'), findsOneWidget);
      expect(selected, isNull);
    });

    testWidgets('tapping create group button triggers onCreateGroup callback', (tester) async {
      var createCalled = false;
      await tester.pumpWidget(buildTestWidget(onCreateGroup: () => createCalled = true));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Tạo nhóm'));
      await tester.pump();

      expect(createCalled, isTrue);
    });
  });
}
