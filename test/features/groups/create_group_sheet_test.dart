import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_state.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/create_group_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

import 'groups_cubit_test.dart';

void main() {
  group('CreateGroupSheet Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupsCubit groupsCubit;

    const group1 = GroupModel(id: 1, name: 'Nhóm 1', ownerId: 1);
    const group2 = GroupModel(id: 2, name: 'Nhóm 2', ownerId: 1);

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      groupsRepo.groups = [group1, group2];
      groupsCubit = GroupsCubit(groupsRepo);
    });

    Widget createWidgetUnderTest({
      GroupModel? groupToEdit,
      ValueChanged<GroupModel>? onSuccessWithGroup,
      VoidCallback? onSuccess,
    }) {
      return BlocProvider<GroupsCubit>.value(
        value: groupsCubit,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => CreateGroupSheet.show(
                      context,
                      groupToEdit: groupToEdit,
                      onSuccessWithGroup: onSuccessWithGroup,
                      onSuccess: onSuccess,
                    ),
                    child: const Text('Open Sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('editing group 2 does NOT return group 1 even if cubit.state.selectedGroup is group 1', (tester) async {
      // Setup state where selectedGroup is group 1 and list has group 1 & group 2
      groupsCubit.emit(
        GroupsState(
          status: GroupsStatus.success,
          groups: [group1, group2],
          selectedGroup: group1, // Stale group 1 in selectedGroup
        ),
      );

      GroupModel? returnedGroup;
      await tester.pumpWidget(
        createWidgetUnderTest(
          groupToEdit: group2,
          onSuccessWithGroup: (g) => returnedGroup = g,
        ),
      );
      await tester.pumpAndSettle();

      // Open the sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter new name for group 2
      final nameFinder = find.widgetWithText(TextFormField, 'Nhóm 2');
      expect(nameFinder, findsOneWidget);
      await tester.enterText(nameFinder, 'Nhóm 2 Tên Mới');
      await tester.pump();

      // Tap save
      final saveBtn = find.text('Lưu thay đổi');
      expect(saveBtn, findsOneWidget);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verification: Returned group must be group 2 with updated name, NOT group 1!
      expect(returnedGroup, isNotNull);
      expect(returnedGroup!.id, 2);
      expect(returnedGroup!.name, 'Nhóm 2 Tên Mới');
    });
  });
}
