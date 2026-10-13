import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/join_group_view.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'groups_cubit_test.dart';

void main() {
  group('JoinGroupView Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupsCubit groupsCubit;

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      groupsCubit = GroupsCubit(groupsRepo);
    });

    Widget createWidgetUnderTest({
      VoidCallback? onBack,
      VoidCallback? onSuccess,
      String? initialInviteCode,
    }) {
      return BlocProvider<GroupsCubit>.value(
        value: groupsCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: JoinGroupView(
              onBack: onBack ?? () {},
              onSuccess: onSuccess,
              initialInviteCode: initialInviteCode,
            ),
          ),
        ),
      );
    }

    testWidgets('renders header, title, tabs and action buttons in Vietnamese', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Back button
      expect(find.text('Quay lại'), findsOneWidget);

      // Title & Subtitle
      expect(find.text('Gia nhập bằng mã / QR'), findsOneWidget);
      expect(find.text('Tham gia nhóm chi tiêu nhanh chóng bằng cách quét mã QR hoặc nhập mã mời'), findsOneWidget);

      // Tabs
      expect(find.text('Quét mã QR'), findsOneWidget);
      expect(find.text('Nhập mã mời'), findsOneWidget);

      // Default active tab: Quét mã QR
      expect(find.text('Hướng camera vào mã QR của nhóm để gửi yêu cầu gia nhập'), findsOneWidget);
      expect(find.text('Tải ảnh mã QR'), findsOneWidget);
    });

    testWidgets('tapping back button invokes onBack callback', (tester) async {
      bool backCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(onBack: () => backCalled = true));
      await tester.pump();

      await tester.tap(find.text('Quay lại'));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('switching between tabs displays manual invite code input and back', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Tap on Nhập mã mời tab
      await tester.tap(find.text('Nhập mã mời'));
      await tester.pump();

      expect(find.text('MÃ MỜI NHÓM *'), findsOneWidget);
      expect(find.text('Mã nhóm của bạn'), findsOneWidget);
      expect(find.text('Tham gia nhóm'), findsOneWidget);

      // Switch back to Quét mã QR tab
      await tester.tap(find.text('Quét mã QR'));
      await tester.pump();

      expect(find.text('Tải ảnh mã QR'), findsOneWidget);
    });

    testWidgets('submitting manual invite code calls GroupsCubit.joinGroup and invokes onSuccess', (tester) async {
      bool successCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(onSuccess: () => successCalled = true));
      await tester.pump();

      // Switch to manual input tab
      await tester.tap(find.text('Nhập mã mời'));
      await tester.pump();

      // Enter code
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'VALIDCODE');
      await tester.pump();

      // Tap submit button
      await tester.tap(find.text('Tham gia nhóm'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(successCalled, isTrue);
    });


    testWidgets('initialInviteCode switches automatically to tab 1 and pre-fills text', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(initialInviteCode: 'E93KLA'));
      await tester.pump();

      expect(find.text('E93KLA'), findsOneWidget);
      expect(find.text('Tham gia nhóm'), findsOneWidget);
    });
  });
}
