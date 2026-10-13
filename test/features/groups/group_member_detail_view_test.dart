import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/group_members_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/group_members_state.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_member_detail_skeleton.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_member_detail_view.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/viet_qr_modal_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

import 'groups_cubit_test.dart';

void main() {
  group('GroupMemberDetailView Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupMembersCubit membersCubit;

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      membersCubit = GroupMembersCubit(
        groupId: 1,
        isAdmin: true,
        groupsRepository: groupsRepo,
        dataSyncCoordinator: DataSyncCoordinator(),
      );
    });

    tearDown(() {
      membersCubit.close();
    });

    Widget createWidgetUnderTest({
      required int targetUserId,
      bool isGroupAdmin = true,
      bool isGroupArchived = false,
      int? currentUserId = 1,
      VoidCallback? onBack,
      VoidCallback? onMemberKicked,
    }) {
      return BlocProvider<GroupMembersCubit>.value(
        value: membersCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GroupMemberDetailView(
              groupId: 1,
              targetUserId: targetUserId,
              groupName: 'Chung cư Sunrise Room',
              isGroupAdmin: isGroupAdmin,
              isGroupArchived: isGroupArchived,
              currentUserId: currentUserId,
              onBack: onBack ?? () {},
              onMemberKicked: onMemberKicked,
            ),
          ),
        ),
      );
    }

    testWidgets('renders member detail information, bank info, and back button', (tester) async {
      bool backTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 2,
        onBack: () => backTapped = true,
      ));
      await tester.pumpAndSettle();

      // Top back button
      expect(find.text('Quay lại nhóm'), findsOneWidget);
      await tester.tap(find.text('Quay lại nhóm'));
      expect(backTapped, isTrue);

      // Hero info
      expect(find.text('Thành viên 2'), findsOneWidget);
      expect(find.text('THÀNH VIÊN (MEMBER)'), findsOneWidget);

      // Bank account info
      expect(find.text('Techcombank'), findsOneWidget);
      expect(find.text('19034829104018'), findsOneWidget);
      expect(find.text('Mã VietQR'), findsOneWidget);
    });

    testWidgets('tapping VietQR button opens VietQrModalSheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(targetUserId: 2));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mã VietQR'));
      await tester.pumpAndSettle();

      expect(find.byType(VietQrModalSheet), findsOneWidget);
      expect(find.text('Mã VietQR'), findsWidgets);
    });

    testWidgets('Kick member button visibility: Admin viewing member -> visible', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 2,
        isGroupAdmin: true,
        currentUserId: 1, // viewer is user 1 (Admin), target is user 2 (Member)
      ));
      await tester.pumpAndSettle();

      expect(find.text('XÓA THÀNH VIÊN KHỎI NHÓM'), findsOneWidget);
      expect(find.text('Kích khỏi nhóm'), findsOneWidget);
    });

    testWidgets('Kick member button visibility: Admin viewing self -> HIDDEN', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 1,
        isGroupAdmin: true,
        currentUserId: 1, // viewer is user 1 (Admin), viewing self
      ));
      await tester.pumpAndSettle();

      expect(find.text('XÓA THÀNH VIÊN KHỎI NHÓM'), findsNothing);
      expect(find.text('Kích khỏi nhóm'), findsNothing);
    });

    testWidgets('Kick member button visibility: Regular member viewing member -> HIDDEN', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 2,
        isGroupAdmin: false, // viewer is regular member
        currentUserId: 3,
      ));
      await tester.pumpAndSettle();

      expect(find.text('XÓA THÀNH VIÊN KHỎI NHÓM'), findsNothing);
      expect(find.text('Kích khỏi nhóm'), findsNothing);
    });

    testWidgets('Kick member button visibility: Group is archived -> HIDDEN', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 2,
        isGroupAdmin: true,
        isGroupArchived: true,
        currentUserId: 1,
      ));
      await tester.pumpAndSettle();

      expect(find.text('XÓA THÀNH VIÊN KHỎI NHÓM'), findsNothing);
      expect(find.text('Kích khỏi nhóm'), findsNothing);
    });

    testWidgets('Kick member confirms and invokes callback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      bool kickedCallbackCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        targetUserId: 2,
        isGroupAdmin: true,
        currentUserId: 1,
        onMemberKicked: () => kickedCallbackCalled = true,
      ));
      await tester.pumpAndSettle();

      // Tap kick button
      await tester.tap(find.text('Kích khỏi nhóm'));
      await tester.pumpAndSettle();

      // Dialog confirmation appears
      expect(find.text('Xác nhận xóa thành viên?'), findsOneWidget);

      // Tap confirm button in dialog
      await tester.tap(find.text('Xác nhận xóa'));
      await tester.pumpAndSettle();

      expect(kickedCallbackCalled, isTrue);
    });

    testWidgets('renders shimmer skeleton when loading member detail', (tester) async {
      membersCubit.emit(const GroupMembersState(isLoadingDetail: true));
      await tester.pumpWidget(createWidgetUnderTest(targetUserId: 2));
      expect(find.byType(GroupMemberDetailSkeleton), findsOneWidget);
    });

    testWidgets('back button has at least 48px touch target height', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(targetUserId: 2));
      await tester.pumpAndSettle();

      final backButtonFinder = find.ancestor(
        of: find.text('Quay lại nhóm'),
        matching: find.byType(ConstrainedBox),
      ).first;
      final size = tester.getSize(backButtonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('VietQR button has at least 48px touch target height', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(targetUserId: 2));
      await tester.pumpAndSettle();

      final vietQrButtonFinder = find.widgetWithText(OutlinedButton, 'Mã VietQR');
      final size = tester.getSize(vietQrButtonFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
    });
  });
}
