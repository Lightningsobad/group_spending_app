import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/dashboard/presentation/widgets/select_group_for_expense_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_filter_chip.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'package:group_spending_app/shared/widgets/app_shimmer.dart';
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
      bool isLoading = false,
      ThemeData? theme,
      VoidCallback? onBack,
      ValueChanged<GroupModel>? onGroupSelected,
      VoidCallback? onCreateGroup,
      Locale locale = const Locale('vi'),
    }) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SelectGroupForExpenseView(
            groups: groups ?? sampleGroups,
            isLoading: isLoading,
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

    testWidgets('renders localized search hint in English when locale is en', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Search by group name...'), findsOneWidget);
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

    testWidgets('renders full-page shimmer skeleton when isLoading is true and back button still works', (tester) async {
      var backCalled = false;
      await tester.pumpWidget(buildTestWidget(
        isLoading: true,
        onBack: () => backCalled = true,
      ));
      await tester.pump();

      // AppShimmer is active
      expect(find.byType(AppShimmer), findsOneWidget);

      // Group cards should not be rendered yet
      expect(find.text('Chung cư Sunrise Room'), findsNothing);

      // Back button in skeleton should be functional
      final backBtn = find.byIcon(LucideIcons.arrowLeft);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('verifies touch target size of back button, filter chips, and create group button are at least 48x48px', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // 1. Back button >= 48x48
      final backButtonFinder = find.ancestor(
        of: find.byIcon(LucideIcons.arrowLeft),
        matching: find.byType(InkWell),
      );
      final backSize = tester.getSize(backButtonFinder);
      expect(backSize.width, greaterThanOrEqualTo(48.0));
      expect(backSize.height, greaterThanOrEqualTo(48.0));

      // 2. Filter chip >= 48px height
      final chipFinder = find.byType(GroupFilterChip).first;
      final chipSize = tester.getSize(chipFinder);
      expect(chipSize.height, greaterThanOrEqualTo(48.0));

      // 3. Create group button >= 48px height
      final createBtnFinder = find.widgetWithText(OutlinedButton, 'Tạo nhóm');
      final createBtnSize = tester.getSize(createBtnFinder);
      expect(createBtnSize.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('renders cleanly without overflow on narrow 320px width device with 1.3x textScaler', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.3),
            size: Size(320, 640),
          ),
          child: buildTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Chưa có nhóm phù hợp?'), findsOneWidget);
      expect(find.text('Tạo nhóm'), findsOneWidget);
    });

    testWidgets('renders with dark theme using AppThemeColors semantic tokens', (tester) async {
      await tester.pumpWidget(buildTestWidget(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      // Renders successfully
      expect(find.text('Chọn nhóm muốn thêm khoản chi'), findsOneWidget);
      expect(find.text('+2.450.000 đ'), findsOneWidget);
      expect(find.text('-450.000 đ'), findsOneWidget);
      expect(find.text('Tạo nhóm'), findsOneWidget);
    });

    testWidgets('wraps view in SafeArea with top enabled to prevent system status bar overlap', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(top: 44.0),
          ),
          child: buildTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      final safeAreaFinder = find.descendant(
        of: find.byType(SelectGroupForExpenseView),
        matching: find.byType(SafeArea),
      );
      expect(safeAreaFinder, findsOneWidget);

      final safeArea = tester.widget<SafeArea>(safeAreaFinder);
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);

      // Back button must start below the 44px top padding
      final backButtonTopLeft = tester.getTopLeft(find.byIcon(LucideIcons.arrowLeft));
      expect(backButtonTopLeft.dy, greaterThanOrEqualTo(44.0));
    });
  });
}
