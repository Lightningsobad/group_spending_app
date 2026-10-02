import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/group_members_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_members_tab_view.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

import 'groups_cubit_test.dart';

void main() {
  group('GroupMembersTabView Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupMembersCubit membersCubit;

    const testGroup = GroupModel(
      id: 1,
      name: 'Chung cư Sunrise Room',
      category: 'Apartment',
      inviteCode: 'SUN402-VIP',
      status: 'ACTIVE',
      role: 'ADMIN',
      ownerId: 1,
      memberCount: 2,
    );

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
      GroupModel group = testGroup,
      bool isAdmin = true,
      bool isOwner = true,
      int? currentUserId = 1,
      VoidCallback? onInviteMore,
      ValueChanged<int>? onSelectMember,
      VoidCallback? onDeleteGroup,
      VoidCallback? onLeaveGroup,
    }) {
      return BlocProvider<GroupMembersCubit>.value(
        value: membersCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: GroupMembersTabView(
                group: group,
                isAdmin: isAdmin,
                isOwner: isOwner,
                currentUserId: currentUserId,
                onInviteMore: onInviteMore ?? () {},
                onSelectMember: onSelectMember ?? (_) {},
                onDeleteGroup: onDeleteGroup ?? () {},
                onLeaveGroup: onLeaveGroup ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders invite button, member count header, and members list', (tester) async {
      bool inviteMoreTapped = false;
      int? selectedMemberId;

      await tester.pumpWidget(createWidgetUnderTest(
        onInviteMore: () => inviteMoreTapped = true,
        onSelectMember: (id) => selectedMemberId = id,
      ));
      await tester.pumpAndSettle();

      // Top invite button
      expect(find.text('+ Mời thêm'), findsOneWidget);
      await tester.tap(find.text('+ Mời thêm'));
      expect(inviteMoreTapped, isTrue);

      // Sub-header count
      expect(find.text('THÀNH VIÊN (2)'), findsOneWidget);

      // Member 1 (Admin & current user)
      expect(find.text('Nguyễn Nhật Minh'), findsOneWidget);
      expect(find.text('Bạn'), findsOneWidget);
      expect(find.text('TRƯỞNG NHÓM'), findsOneWidget);

      // Member 2
      expect(find.text('Trần Văn An'), findsOneWidget);
      expect(find.text('THÀNH VIÊN'), findsOneWidget);

      // Tap Member 2 to view details
      await tester.tap(find.text('Trần Văn An'));
      expect(selectedMemberId, 2);
    });

    testWidgets('shows delete group card for admin/owner', (tester) async {
      bool deleteTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        isAdmin: true,
        isOwner: true,
        onDeleteGroup: () => deleteTapped = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('XÓA NHÓM'), findsOneWidget);
      expect(find.text('Xóa nhóm'), findsOneWidget);

      await tester.tap(find.text('Xóa nhóm'));
      expect(deleteTapped, isTrue);
    });

    testWidgets('shows leave group card for regular member', (tester) async {
      bool leaveTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        isAdmin: false,
        isOwner: false,
        onLeaveGroup: () => leaveTapped = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('RỜI KHỎI NHÓM'), findsOneWidget);
      expect(find.text('Rời nhóm'), findsOneWidget);

      await tester.tap(find.text('Rời nhóm'));
      expect(leaveTapped, isTrue);
    });
  });
}
