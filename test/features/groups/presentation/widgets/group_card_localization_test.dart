import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_card_widget.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  const memberActiveGroup = GroupModel(
    id: 1,
    name: 'Phòng 402 Homies',
    category: 'Apartment',
    ownerId: 2,
    role: 'MEMBER',
    status: 'ACTIVE',
    memberCount: 4,
    userBalance: 250000,
  );

  const adminArchivedGroup = GroupModel(
    id: 2,
    name: 'FC Bóng Đá',
    category: 'Sport & Clubs',
    ownerId: 1,
    role: 'ADMIN',
    status: 'ARCHIVED',
    memberCount: 10,
    userBalance: -100000,
  );

  Widget createWidget({required GroupModel group, required Locale locale}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(
        body: GroupCardWidget(group: group),
      ),
    );
  }

  group('GroupCardWidget Localization Tests', () {
    testWidgets('displays Vietnamese labels correctly under vi locale', (tester) async {
      await tester.pumpWidget(
        createWidget(group: memberActiveGroup, locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      expect(find.text('THÀNH VIÊN'), findsOneWidget);
      expect(find.text('Đang hoạt động'), findsOneWidget);
      expect(find.text('Số dư của bạn:'), findsOneWidget);

      await tester.pumpWidget(
        createWidget(group: adminArchivedGroup, locale: const Locale('vi')),
      );
      await tester.pumpAndSettle();

      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Đã lưu trữ'), findsOneWidget);
    });

    testWidgets('displays English labels correctly under en locale', (tester) async {
      await tester.pumpWidget(
        createWidget(group: memberActiveGroup, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('MEMBER'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Your balance:'), findsOneWidget);

      await tester.pumpWidget(
        createWidget(group: adminArchivedGroup, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('ADMIN'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });
  });
}
