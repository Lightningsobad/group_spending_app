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
import 'package:group_spending_app/features/debts/presentation/screens/group_debt_detail_view.dart';
import 'package:group_spending_app/features/groups/data/models/group_member_models.dart';
import 'package:group_spending_app/features/groups/domain/repositories/groups_repository.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/viet_qr_modal_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

import '../../../auth/presentation/cubit/auth_cubit_test.dart';
import '../../../groups/groups_cubit_test.dart';

class _MockDebtsRepo implements DebtsRepository {
  final List<SimplifiedDebtEntity> simplifiedDebts;
  final List<ActualDebtEntity> actualDebts;
  int? markedAsPaidDebtId;

  _MockDebtsRepo({
    required this.simplifiedDebts,
    this.actualDebts = const [],
  });

  @override
  Future<DebtOverviewEntity> getDebtOverview() async => const DebtOverviewEntity();

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) async {
    return GroupSimplifiedDebtsEntity(
      userBalance: const DebtUserBalanceEntity(
        groupId: 10,
        groupName: 'Chung cư Sunrise Room',
        youOweVnd: 150000,
        netBalanceVnd: -150000,
      ),
      simplifiedDebts: simplifiedDebts,
    );
  }

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(int groupId, {String? status}) async {
    return GroupActualDebtsEntity(
      userBalance: const DebtUserBalanceEntity(
        groupId: 10,
        groupName: 'Chung cư Sunrise Room',
        youOweVnd: 150000,
        netBalanceVnd: -150000,
      ),
      actualDebts: actualDebts,
    );
  }

  @override
  Future<void> markDebtAsPaid(int debtId) async {
    markedAsPaidDebtId = debtId;
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {}

  @override
  Future<void> sendDebtReminder(int debtId) async {}
}

class _TestGroupsRepo extends FakeGroupsRepo {
  final GroupMemberDetailModel Function(int groupId, int targetUserId)? memberDetailsProvider;

  _TestGroupsRepo({this.memberDetailsProvider});

  @override
  Future<GroupMemberDetailModel> getMemberDetails(int groupId, int targetUserId) async {
    if (memberDetailsProvider != null) {
      return memberDetailsProvider!(groupId, targetUserId);
    }
    return super.getMemberDetails(groupId, targetUserId);
  }
}

void main() {
  group('GroupDebtDetailView QR Payment Tests', () {
    late FakeAuthRepository authRepo;
    late AuthCubit authCubit;

    setUp(() {
      authRepo = FakeAuthRepository()..isAuth = true;
      authCubit = AuthCubit(authRepo);
    });

    tearDown(() {
      authCubit.close();
    });

    Widget createWidgetUnderTest({
      required DebtsCubit debtsCubit,
      required GroupsRepository groupsRepo,
    }) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<GroupsRepository>.value(value: groupsRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<DebtsCubit>.value(value: debtsCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: GroupDebtDetailView(
                groupId: 10,
                groupName: 'Chung cư Sunrise Room',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('tapping Pay Now when creditor has bank info opens VietQrModalSheet and marks as paid on confirm', (tester) async {
      final debtsRepo = _MockDebtsRepo(
        simplifiedDebts: const [
          SimplifiedDebtEntity(
            id: 101,
            debtorId: 1,
            debtorName: 'Nguyễn Văn Debtor',
            creditorId: 2,
            creditorName: 'Trần Văn Creditor',
            creditorBankName: 'MBBank',
            creditorAccountNumber: '0987654321',
            creditorBankAccountName: 'TRAN VAN CREDITOR',
            amountVnd: 150000,
            action: DebtAction.pay,
            note: 'Tien phong thang 10',
          ),
        ],
      );

      final debtsCubit = DebtsCubit(debtsRepo);
      await debtsCubit.loadGroupDebts(10);

      final groupsRepo = _TestGroupsRepo();

      await tester.pumpWidget(
        createWidgetUnderTest(
          debtsCubit: debtsCubit,
          groupsRepo: groupsRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Check pay button is visible
      final payButton = find.text('Thanh toán ngay (100%)');
      expect(payButton, findsOneWidget);

      // Tap Pay Now
      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // VietQrModalSheet should be shown
      expect(find.byType(VietQrModalSheet), findsOneWidget);
      expect(find.text('MBBank'), findsOneWidget);
      expect(find.text('0987654321'), findsWidgets);
      expect(find.text('TRAN VAN CREDITOR'), findsOneWidget);
      expect(find.descendant(of: find.byType(VietQrModalSheet), matching: find.text('150.000 đ')), findsOneWidget);
      expect(find.descendant(of: find.byType(VietQrModalSheet), matching: find.text('Tien phong thang 10')), findsOneWidget);

      // Confirm payment
      final confirmBtn = find.text('Tôi đã chuyển khoản');
      expect(confirmBtn, findsOneWidget);
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Modal is dismissed and debt marked as paid
      expect(find.byType(VietQrModalSheet), findsNothing);
      expect(debtsRepo.markedAsPaidDebtId, 101);

      debtsCubit.close();
    });

    testWidgets('tapping Pay Now when creditor has NO bank info shows No Bank Info Alert', (tester) async {
      final debtsRepo = _MockDebtsRepo(
        simplifiedDebts: const [
          SimplifiedDebtEntity(
            id: 102,
            debtorId: 1,
            debtorName: 'Nguyễn Văn Debtor',
            creditorId: 3,
            creditorName: 'Lê Không Có Tài Khoản',
            amountVnd: 200000,
            action: DebtAction.pay,
          ),
        ],
      );

      final debtsCubit = DebtsCubit(debtsRepo);
      await debtsCubit.loadGroupDebts(10);

      // Groups repo returns member without bank info
      final groupsRepo = _TestGroupsRepo(
        memberDetailsProvider: (groupId, targetUserId) => GroupMemberDetailModel(
          userId: targetUserId,
          fullName: 'Lê Không Có Tài Khoản',
          groupId: groupId,
          groupName: 'Chung cư Sunrise Room',
          role: 'MEMBER',
          email: 'no_bank@example.com',
          bankName: null,
          bankAccountNumber: null,
        ),
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          debtsCubit: debtsCubit,
          groupsRepo: groupsRepo,
        ),
      );
      await tester.pumpAndSettle();

      final payButton = find.text('Thanh toán ngay (100%)');
      expect(payButton, findsOneWidget);

      await tester.tap(payButton);
      await tester.pumpAndSettle();

      // Alert dialog should be shown
      expect(find.text('Chưa có thông tin thanh toán'), findsOneWidget);
      expect(
        find.textContaining('Lê Không Có Tài Khoản chưa cập nhật thông tin số tài khoản và ngân hàng'),
        findsOneWidget,
      );

      // Tapping Close dismisses the dialog
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();

      expect(find.text('Chưa có thông tin thanh toán'), findsNothing);

      debtsCubit.close();
    });

    testWidgets('Pay Now button is ENABLED and clickable when debt.id is null (common in simplified debts)', (tester) async {
      final debtsRepo = _MockDebtsRepo(
        simplifiedDebts: const [
          SimplifiedDebtEntity(
            id: null,
            debtorId: 1,
            debtorName: 'Nguyễn Văn Debtor',
            creditorId: 2,
            creditorName: 'Trần Văn Creditor',
            creditorBankName: 'Techcombank',
            creditorAccountNumber: '1903333333',
            creditorBankAccountName: 'TRAN VAN CREDITOR',
            amountVnd: 250000,
            action: DebtAction.pay,
            note: 'Tien an uong',
          ),
        ],
      );

      final debtsCubit = DebtsCubit(debtsRepo);
      await debtsCubit.loadGroupDebts(10);

      final groupsRepo = _TestGroupsRepo();

      await tester.pumpWidget(
        createWidgetUnderTest(
          debtsCubit: debtsCubit,
          groupsRepo: groupsRepo,
        ),
      );
      await tester.pumpAndSettle();

      final payButton = find.text('Thanh toán ngay (100%)');
      expect(payButton, findsOneWidget);

      final elevatedButton = tester.widget<ElevatedButton>(
        find.ancestor(of: payButton, matching: find.byType(ElevatedButton)),
      );
      expect(elevatedButton.enabled, isTrue);

      await tester.tap(payButton);
      await tester.pumpAndSettle();

      expect(find.byType(VietQrModalSheet), findsOneWidget);
      expect(find.text('Techcombank'), findsOneWidget);
      expect(find.text('1903333333'), findsWidgets);

      debtsCubit.close();
    });

    testWidgets('tapping Confirm in VietQrModalSheet marks splitId as paid when debt.id is null', (tester) async {
      final debtsRepo = _MockDebtsRepo(
        simplifiedDebts: const [
          SimplifiedDebtEntity(
            id: null,
            debtorId: 1,
            debtorName: 'Nguyễn Văn Debtor',
            creditorId: 2,
            creditorName: 'Trần Văn Creditor',
            creditorBankName: 'Techcombank',
            creditorAccountNumber: '1903333333',
            creditorBankAccountName: 'TRAN VAN CREDITOR',
            amountVnd: 250000,
            action: DebtAction.pay,
          ),
        ],
        actualDebts: const [
          ActualDebtEntity(
            expenseId: 5,
            title: 'Ăn tối',
            paidByUserId: 2,
            paidByUserName: 'Trần Văn Creditor',
            debtors: [
              ActualDebtorEntity(
                splitId: 999,
                userId: 1,
                name: 'Nguyễn Văn Debtor',
                action: DebtAction.pay,
                status: DebtStatus.pending,
              ),
            ],
          ),
        ],
      );

      final debtsCubit = DebtsCubit(debtsRepo);
      await debtsCubit.loadGroupDebts(10);

      final groupsRepo = _TestGroupsRepo();

      await tester.pumpWidget(
        createWidgetUnderTest(
          debtsCubit: debtsCubit,
          groupsRepo: groupsRepo,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thanh toán ngay (100%)'));
      await tester.pumpAndSettle();

      final confirmBtn = find.text('Tôi đã chuyển khoản');
      await tester.ensureVisible(confirmBtn);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(debtsRepo.markedAsPaidDebtId, 999);

      debtsCubit.close();
    });
  });
}
