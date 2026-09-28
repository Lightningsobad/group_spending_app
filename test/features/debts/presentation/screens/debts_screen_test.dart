import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_overview_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/domain/repositories/debts_repository.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:group_spending_app/features/debts/presentation/screens/debts_screen.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit_test.dart';

class FakeDebtsRepo implements DebtsRepository {
  @override
  Future<DebtOverviewEntity> getDebtOverview() async {
    return const DebtOverviewEntity(
      totalOwedVnd: 450000,
      totalReceivableVnd: 2450000,
      netBalanceVnd: 2000000,
      groupBalances: [
        GroupDebtBalanceEntity(
          groupId: 10,
          groupName: 'Chung cư Sunrise Room',
          netBalanceVnd: 2450000,
          pendingDebtCount: 4,
        ),
        GroupDebtBalanceEntity(
          groupId: 11,
          groupName: 'Đội Cầu Lông Ba Đình',
          netBalanceVnd: -450000,
          pendingDebtCount: 1,
        ),
      ],
    );
  }

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) async {
    return const GroupSimplifiedDebtsEntity(
      userBalance: DebtUserBalanceEntity(
        groupId: 10,
        groupName: 'Chung cư Sunrise Room',
        netBalanceVnd: 2450000,
      ),
      simplifiedDebts: [
        SimplifiedDebtEntity(
          id: 101,
          debtorId: 2,
          debtorName: 'Hoàng Minh C',
          creditorId: 1,
          creditorName: 'Nguyễn Nhật Minh',
          amountVnd: 150000,
          action: DebtAction.remind,
        ),
      ],
    );
  }

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(int groupId, {String? status}) async {
    return const GroupActualDebtsEntity(
      userBalance: DebtUserBalanceEntity(
        groupId: 10,
        groupName: 'Chung cư Sunrise Room',
        netBalanceVnd: 2450000,
      ),
      actualDebts: [
        ActualDebtEntity(
          id: 201,
          groupId: 10,
          debtorId: 2,
          debtorName: 'Hoàng Minh C',
          creditorId: 1,
          creditorName: 'Nguyễn Nhật Minh',
          amountVnd: 150000,
          status: DebtStatus.pending,
          action: DebtAction.remind,
        ),
      ],
    );
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {}

  @override
  Future<void> markDebtAsPaid(int debtId) async {}

  @override
  Future<void> sendDebtReminder(int debtId) async {}
}

void main() {
  group('DebtsScreen Widget Tests', () {
    late FakeDebtsRepo debtsRepo;
    late FakeAuthRepository authRepo;
    late DebtsCubit debtsCubit;
    late AuthCubit authCubit;

    setUp(() {
      debtsRepo = FakeDebtsRepo();
      authRepo = FakeAuthRepository()..isAuth = true;
      debtsCubit = DebtsCubit(debtsRepo);
      authCubit = AuthCubit(authRepo);
    });

    tearDown(() {
      debtsCubit.close();
      authCubit.close();
    });

    Widget createWidgetUnderTest() {
      return MultiBlocProvider(
        providers: [
          BlocProvider<DebtsCubit>.value(value: debtsCubit),
          BlocProvider<AuthCubit>.value(value: authCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: DebtsScreen(),
          ),
        ),
      );
    }

    testWidgets('renders header, summary cards, search bar, and group list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Công nợ theo nhóm'), findsOneWidget);

      // Summary Cards
      expect(find.text('Bạn đang nợ'), findsOneWidget);
      expect(find.text('Bạn nhận'), findsWidgets);
      expect(find.text('450.000 đ'), findsWidgets);
      expect(find.text('2.450.000 đ'), findsWidgets);

      // Group cards
      expect(find.text('Chung cư Sunrise Room'), findsOneWidget);
      expect(find.text('Đội Cầu Lông Ba Đình'), findsOneWidget);
      expect(find.text('4 khoản nợ cần xử lý'), findsOneWidget);
      expect(find.text('1 khoản nợ cần xử lý'), findsOneWidget);
    });

    testWidgets('tap on group card opens GroupDebtDetailView and Back returns to list', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap on first group
      await tester.tap(find.text('Chung cư Sunrise Room'));
      await tester.pumpAndSettle();

      // Check detail view is active
      expect(find.text('Quay lại'), findsOneWidget);
      expect(find.text('Nợ tối giản'), findsOneWidget);
      expect(find.text('Nợ thực tế'), findsOneWidget);
      expect(find.text('Số dư của bạn trong nhóm:'), findsOneWidget);

      // Tap back button
      await tester.tap(find.text('Quay lại'));
      await tester.pumpAndSettle();

      // Back to main screen
      expect(find.text('Công nợ theo nhóm'), findsOneWidget);
    });
  });
}
