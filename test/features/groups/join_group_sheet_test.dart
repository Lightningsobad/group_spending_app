import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/join_group_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import 'groups_cubit_test.dart';

void main() {
  group('JoinGroupSheet Widget Tests', () {
    late FakeGroupsRepo groupsRepo;
    late GroupsCubit groupsCubit;

    setUp(() {
      groupsRepo = FakeGroupsRepo();
      groupsCubit = GroupsCubit(groupsRepo);
    });

    Widget createWidgetUnderTest({
      ThemeData? theme,
      VoidCallback? onSuccess,
    }) {
      return BlocProvider<GroupsCubit>.value(
        value: groupsCubit,
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () => JoinGroupSheet.show(context, onSuccess: onSuccess),
                    child: const Text('Open Sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders title, input and button in Vietnamese with 48px touch targets', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Gia nhập nhóm bằng mã mời'), findsOneWidget);
      expect(find.text('MÃ MỜI NHÓM *'), findsOneWidget);
      expect(find.text('Tham gia nhóm'), findsOneWidget);

      // Verify submit button has minimum height of 48px
      final submitButton = find.widgetWithText(ElevatedButton, 'Tham gia nhóm');
      final submitSize = tester.getSize(submitButton);
      expect(submitSize.height, greaterThanOrEqualTo(48.0));

      // Close button touch target
      final closeButton = find.byType(IconButton);
      final closeSize = tester.getSize(closeButton);
      expect(closeSize.height, greaterThanOrEqualTo(48.0));
      expect(closeSize.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('shows validation error when submitting empty code', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap submit button without entering code
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tham gia nhóm'));
      await tester.pump();

      expect(find.text('Vui lòng nhập mã mời.'), findsOneWidget);
    });

    testWidgets('renders cleanly in dark theme without exceptions', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pump();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('MÃ MỜI NHÓM *'), findsOneWidget);
    });
  });
}
