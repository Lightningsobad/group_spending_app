import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/screens/groups_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../auth/presentation/cubit/auth_cubit_test.dart';
import '../dashboard/dashboard_cubit_test.dart';
import 'groups_cubit_test.dart';

void main() {
  group('GroupsScreen Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late FakeDebtsRepository debtsRepo;
    late GroupsCubit groupsCubit;
    late DashboardCubit dashboardCubit;
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      debtsRepo = FakeDebtsRepository();
      groupsCubit = GroupsCubit(groupsRepo);
      dashboardCubit = DashboardCubit(
        debtsRepository: debtsRepo,
        groupsRepository: groupsRepo,
      );
      authRepo = FakeAuthRepository();
      authCubit = AuthCubit(authRepo);
    });

    Widget createWidgetUnderTest({Locale locale = const Locale('vi')}) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<GroupsCubit>.value(value: groupsCubit),
          BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: GroupsScreen(),
          ),
        ),
      );
    }

    testWidgets('renders title, search bar, buttons, filter chips and group cards in Vietnamese', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('vi')));
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Danh sách nhóm của bạn'), findsOneWidget);

      // Search field hint
      expect(find.text('Tìm kiếm theo tên nhóm, thể loại...'), findsOneWidget);

      // Action buttons
      expect(find.text('Tạo nhóm'), findsOneWidget);
      expect(find.text('Mã / QR'), findsOneWidget);

      // Filter chips
      expect(find.text('Tất cả (3)'), findsOneWidget);
      expect(find.text('Đang hoạt động (2)'), findsOneWidget);
      expect(find.text('Đã lưu trữ (1)'), findsOneWidget);
      expect(find.text('Tôi quản lý (2)'), findsOneWidget);

      // Groups list
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
      expect(find.text('Đi phượt Đà Lạt 2024'), findsOneWidget);
    });

    testWidgets('renders groups screen labels in English when locale is en', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(locale: const Locale('en')));
      await tester.pumpAndSettle();

      // Title in English
      expect(find.text('Your group list'), findsOneWidget);

      // Search field hint in English
      expect(find.text('Search by group name, category...'), findsOneWidget);

      // Action buttons in English
      expect(find.text('Create group'), findsOneWidget);
      expect(find.text('Code / QR'), findsOneWidget);

      // Filter chips in English
      expect(find.text('All (3)'), findsOneWidget);
      expect(find.text('Active (2)'), findsOneWidget);
      expect(find.text('Archived (1)'), findsOneWidget);
      expect(find.text('Managed by me (2)'), findsOneWidget);
    });

    testWidgets('filtering by Đã lưu trữ shows only archived groups', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Đã lưu trữ (1)'));
      await tester.pumpAndSettle();

      expect(find.text('Đi phượt Đà Lạt 2024'), findsOneWidget);
      expect(find.text('Chung cư Sunrise Room'), findsNothing);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsNothing);
    });

    testWidgets('searching by name filters displayed list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Cầu Lông');
      await tester.pumpAndSettle();

      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
      expect(find.text('Chung cư Sunrise Room'), findsNothing);
    });

    testWidgets('tapping Mã / QR opens JoinGroupView and tapping Quay lại returns to list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mã / QR'));
      await tester.pumpAndSettle();

      // JoinGroupView is displayed
      expect(find.text('Gia nhập bằng mã / QR'), findsOneWidget);
      expect(find.text('Quét mã QR'), findsOneWidget);
      expect(find.text('Nhập mã mời'), findsOneWidget);

      // Tap Quay lại to return
      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();

      // Groups list is visible again
      expect(find.text('Danh sách nhóm của bạn'), findsOneWidget);
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
    });

    testWidgets('tapping a group card opens GroupDetailView and tapping back returns to list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chung cư Sunrise Room'));
      await tester.pumpAndSettle();

      // GroupDetailView is displayed
      expect(find.text('THÔNG TIN NHÓM'), findsOneWidget);
      expect(find.text('TỔNG QUAN TÀI CHÍNH NHÓM'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(LucideIcons.arrowLeft));
      await tester.pumpAndSettle();

      // Groups list is visible again
      expect(find.text('Danh sách nhóm của bạn'), findsOneWidget);
    });
  });
}
