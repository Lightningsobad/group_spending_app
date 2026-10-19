import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/session/session_coordinator.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/core/sync/data_sync_coordinator.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_overview_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_settlement_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/domain/repositories/debts_repository.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_state.dart';
import 'package:group_spending_app/features/groups/data/models/group_model.dart';
import '../../../groups/groups_cubit_test.dart';

class MockDebtsRepository implements DebtsRepository {
  DebtOverviewEntity overviewResult = const DebtOverviewEntity(
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
      GroupDebtBalanceEntity(
        groupId: 12,
        groupName: 'Đi phượt Đà Lạt',
        netBalanceVnd: 0,
        pendingDebtCount: 0,
      ),
    ],
  );

  GroupSimplifiedDebtsEntity simplifiedResult = const GroupSimplifiedDebtsEntity(
    userBalance: DebtUserBalanceEntity(
      groupId: 10,
      groupName: 'Chung cư Sunrise Room',
      netBalanceVnd: 2450000,
    ),
    simplifiedDebts: [
      SimplifiedDebtEntity(
        id: 101,
        debtorId: 2,
        debtorName: 'Minh',
        creditorId: 1,
        creditorName: 'An',
        amountVnd: 150000,
        action: DebtAction.pay,
      ),
    ],
  );

  GroupActualDebtsEntity actualResult = const GroupActualDebtsEntity(
    userBalance: DebtUserBalanceEntity(
      groupId: 10,
      groupName: 'Chung cư Sunrise Room',
      netBalanceVnd: 2450000,
    ),
    actualDebts: [
      ActualDebtEntity(
        expenseId: 201,
        title: 'Tiền Internet',
        totalAmountVnd: 150000,
        paidByUserId: 1,
        paidByUserName: 'An',
        debtors: [
          ActualDebtorEntity(
            splitId: 104,
            userId: 2,
            name: 'Minh',
            amountVnd: 150000,
            status: DebtStatus.pending,
            action: DebtAction.pay,
          ),
        ],
      ),
    ],
  );

  int markAsPaidCalls = 0;
  int confirmCalls = 0;
  int remindCalls = 0;
  int simplifiedRemindCalls = 0;
  int? lastRemindedDebtorId;
  num? lastRemindedExpectedAmount;
  int paySimplifiedCalls = 0;
  int? lastPayCreditorId;
  num? lastPayAmount;
  int confirmSettlementCalls = 0;
  int? lastConfirmedSettlementId;
  bool? lastConfirmedStatus;
  List<DebtSettlementEntity> settlementsResult = [];

  @override
  Future<DebtOverviewEntity> getDebtOverview() async => overviewResult;

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) async =>
      simplifiedResult;

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(int groupId,
          {String? status}) async =>
      actualResult;

  @override
  Future<void> markDebtAsPaid(int debtId) async {
    markAsPaidCalls++;
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {
    confirmCalls++;
  }

  @override
  Future<void> sendDebtReminder(int debtId) async {
    remindCalls++;
  }

  @override
  Future<void> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
    required num expectedAmount,
  }) async {
    simplifiedRemindCalls++;
    lastRemindedDebtorId = debtorId;
    lastRemindedExpectedAmount = expectedAmount;
  }

  @override
  Future<DebtSettlementEntity> paySimplifiedDebt(
    int groupId, {
    required int creditorId,
    num? amount,
    String? paymentProofUrl,
    String? note,
  }) async {
    paySimplifiedCalls++;
    lastPayCreditorId = creditorId;
    lastPayAmount = amount;
    return DebtSettlementEntity(
      id: 99,
      groupId: groupId,
      debtorId: 2,
      creditorId: creditorId,
      amount: amount ?? 150000,
      note: note,
      status: DebtStatus.waitingForConfirmation,
    );
  }

  @override
  Future<DebtSettlementEntity> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
  }) async {
    confirmSettlementCalls++;
    lastConfirmedSettlementId = settlementId;
    lastConfirmedStatus = confirmed;
    return DebtSettlementEntity(
      id: settlementId,
      groupId: 10,
      debtorId: 2,
      creditorId: 1,
      amount: 150000,
      status: confirmed ? DebtStatus.settled : DebtStatus.rejected,
    );
  }

  @override
  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId) async {
    return DebtSettlementEntity(
      id: settlementId,
      groupId: 10,
      debtorId: 2,
      creditorId: 1,
      amount: 150000,
    );
  }

  @override
  Future<List<DebtSettlementEntity>> getGroupDebtSettlements(int groupId) async {
    return settlementsResult;
  }
}

class FakeTokenStorage implements TokenStorage {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<String?> getAccessToken() async => 'fake-token';

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {}
}

void main() {
  late MockDebtsRepository repository;
  late DataSyncCoordinator syncCoordinator;
  late SessionCoordinator sessionCoordinator;
  late DebtsCubit cubit;

  setUp(() {
    repository = MockDebtsRepository();
    syncCoordinator = DataSyncCoordinator();
    sessionCoordinator = SessionCoordinator(tokenStorage: FakeTokenStorage());
    cubit = DebtsCubit(
      repository,
      dataSyncCoordinator: syncCoordinator,
      sessionCoordinator: sessionCoordinator,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DebtsCubit Tests', () {
    test('initial state is correct', () {
      expect(cubit.state.status, DebtsStatus.initial);
      expect(cubit.state.overview, isNull);
      expect(cubit.state.selectedGroupId, isNull);
    });

    test('loadOverview loads successfully and populates state', () async {
      await cubit.loadOverview();

      expect(cubit.state.status, DebtsStatus.success);
      expect(cubit.state.overview, isNotNull);
      expect(cubit.state.totalGroupCount, 3);
      expect(cubit.state.hasDebtGroupCount, 2);
      expect(cubit.state.settledGroupCount, 1);
      expect(cubit.state.filteredGroupBalances.length, 3);
    });

    test('filter works correctly for hasDebt and settled', () async {
      await cubit.loadOverview();

      cubit.setFilter(DebtOverviewFilter.hasDebt);
      expect(cubit.state.filteredGroupBalances.length, 2);

      cubit.setFilter(DebtOverviewFilter.settled);
      expect(cubit.state.filteredGroupBalances.length, 1);
      expect(cubit.state.filteredGroupBalances.first.groupName, 'Đi phượt Đà Lạt');
    });

    test('searchQuery filters groups by name', () async {
      await cubit.loadOverview();

      cubit.setSearchQuery('cầu lông');
      expect(cubit.state.filteredGroupBalances.length, 1);
      expect(
        cubit.state.filteredGroupBalances.first.groupName,
        'Đội Cầu Lông Ba Đình',
      );
    });

    test('selectGroup sets selected group and loads details', () async {
      cubit.selectGroup(10, groupName: 'Chung cư Sunrise Room');

      expect(cubit.state.selectedGroupId, 10);
      expect(cubit.state.selectedGroupName, 'Chung cư Sunrise Room');

      // Wait for async loadGroupDebts to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.simplifiedDebts, isNotNull);
      expect(cubit.state.actualDebts, isNotNull);
      expect(cubit.state.isDetailLoading, isFalse);

      // Back to list
      cubit.selectGroup(null);
      expect(cubit.state.selectedGroupId, isNull);
    });

    test('selectGroup clears previous group debt details when switching to a different group', () async {
      cubit.selectGroup(10, groupName: 'Group 10');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.simplifiedDebts, isNotNull);
      expect(cubit.state.actualDebts, isNotNull);

      // Switch to group 20
      cubit.selectGroup(20, groupName: 'Group 20');
      // Previous details must be immediately cleared to prevent stale cache flickering
      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.simplifiedDebts, isNull);
      expect(cubit.state.actualDebts, isNull);
      expect(cubit.state.isDetailLoading, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.simplifiedDebts, isNotNull);
      expect(cubit.state.actualDebts, isNotNull);
      expect(cubit.state.isDetailLoading, isFalse);
    });

    test('setDetailTab switches between simplified and actual debts', () {
      cubit.setDetailTab(1);
      expect(cubit.state.activeDetailTab, 1);

      cubit.setDetailTab(0);
      expect(cubit.state.activeDetailTab, 0);
    });

    test('markDebtAsPaid calls repository and emits success', () async {
      final success = await cubit.markDebtAsPaid(101);

      expect(success, isTrue);
      expect(repository.markAsPaidCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('confirmDebtSettled calls repository and emits success', () async {
      final success = await cubit.confirmDebtSettled(101, confirmed: true);

      expect(success, isTrue);
      expect(repository.confirmCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('sendDebtReminder calls repository and emits success', () async {
      final success = await cubit.sendDebtReminder(101);

      expect(success, isTrue);
      expect(repository.remindCalls, 1);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('loadOverview with GroupsRepository enriches group category from api', () async {
      final fakeGroupsRepo = FakeGroupsRepo()
        ..groups = [
          const GroupModel(
            id: 10,
            name: 'Chung cư Sunrise Room',
            category: 'Apartment',
            ownerId: 1,
          ),
          const GroupModel(
            id: 11,
            name: 'Đội Cầu Lông Ba Đình',
            category: 'Sport & Clubs',
            ownerId: 1,
          ),
        ];
      final cubitWithGroups =
          DebtsCubit(repository, groupsRepository: fakeGroupsRepo);
      addTearDown(cubitWithGroups.close);

      await cubitWithGroups.loadOverview();

      expect(cubitWithGroups.state.isSuccess, isTrue);
      expect(cubitWithGroups.state.userGroups.length, 2);
      final g10 = cubitWithGroups.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 10);
      expect(g10.category, 'Apartment');
      final g11 = cubitWithGroups.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 11);
      expect(g11.category, 'Sport & Clubs');
    });

    test('loadOverview populates groupBalances from groupsRepository when overview.groupBalances is empty', () async {
      final emptyOverviewRepo = MockDebtsRepository()
        ..overviewResult = const DebtOverviewEntity(
          totalOwedVnd: 398000,
          totalReceivableVnd: 1400000,
          groupBalances: [],
        );
      final fakeGroupsRepo = FakeGroupsRepo()
        ..groups = [
          const GroupModel(
            id: 7,
            name: 'Hội đồng niên',
            category: 'Friends & Dining',
            ownerId: 10,
            userBalance: 1400000,
            pendingDebtCount: 1,
          ),
          const GroupModel(
            id: 4,
            name: 'Nhóm bóng đá công ty',
            category: 'Sport & Clubs',
            ownerId: 5,
            userBalance: -398000,
            pendingDebtCount: 1,
          ),
          const GroupModel(
            id: 5,
            name: 'Phòng trọ 705',
            category: 'Apartment',
            ownerId: 5,
            userBalance: 0,
            pendingDebtCount: 0,
          ),
        ];

      final cubitWithEmptyOverview =
          DebtsCubit(emptyOverviewRepo, groupsRepository: fakeGroupsRepo);
      addTearDown(cubitWithEmptyOverview.close);

      await cubitWithEmptyOverview.loadOverview();

      expect(cubitWithEmptyOverview.state.isSuccess, isTrue);
      expect(cubitWithEmptyOverview.state.overview!.groupBalances.length, 3);

      final g7 = cubitWithEmptyOverview.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 7);
      expect(g7.groupName, 'Hội đồng niên');
      expect(g7.category, 'Friends & Dining');
      expect(g7.netBalanceVnd, 1400000);
      expect(g7.youAreOwedVnd, 1400000);
      expect(g7.pendingDebtCount, 1);

      final g4 = cubitWithEmptyOverview.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 4);
      expect(g4.groupName, 'Nhóm bóng đá công ty');
      expect(g4.netBalanceVnd, -398000);
      expect(g4.youOweVnd, 398000);
      expect(g4.pendingDebtCount, 1);

      final g5 = cubitWithEmptyOverview.state.overview!.groupBalances
          .firstWhere((g) => g.groupId == 5);
      expect(g5.isSettled, isTrue);
      expect(g5.pendingDebtCount, 0);
    });

    test('sendSimplifiedDebtReminder calls repository and emits success', () async {
      final success = await cubit.sendSimplifiedDebtReminder(
        10,
        debtorId: 2,
        creditorId: 1,
        expectedAmount: 350,
      );

      expect(success, isTrue);
      expect(repository.simplifiedRemindCalls, 1);
      expect(repository.lastRemindedDebtorId, 2);
      expect(repository.lastRemindedExpectedAmount, 350);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('paySimplifiedDebt calls repository, triggers sync and reloads debts', () async {
      final success = await cubit.paySimplifiedDebt(
        10,
        creditorId: 2,
        amount: 150000,
        note: 'Đã chuyển MBBank',
      );

      expect(success, isTrue);
      expect(repository.paySimplifiedCalls, 1);
      expect(repository.lastPayCreditorId, 2);
      expect(repository.lastPayAmount, 150000);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('confirmDebtSettlement calls repository, triggers sync and reloads debts', () async {
      final success = await cubit.confirmDebtSettlement(
        99,
        confirmed: true,
      );

      expect(success, isTrue);
      expect(repository.confirmSettlementCalls, 1);
      expect(repository.lastConfirmedSettlementId, 99);
      expect(repository.lastConfirmedStatus, isTrue);
      expect(cubit.state.successMessage, isNotNull);
    });

    test('loadGroupDebts fetches settlements and pendingSettlements filters correctly', () async {
      repository.settlementsResult = [
        const DebtSettlementEntity(
          id: 501,
          groupId: 10,
          debtorId: 2,
          debtorName: 'Minh',
          creditorId: 1,
          creditorName: 'An',
          amount: 150000,
          status: DebtStatus.waitingForConfirmation,
        ),
        const DebtSettlementEntity(
          id: 502,
          groupId: 10,
          debtorId: 3,
          debtorName: 'Hương',
          creditorId: 1,
          creditorName: 'An',
          amount: 320000,
          status: DebtStatus.settled,
        ),
      ];

      await cubit.loadGroupDebts(10);

      expect(cubit.state.settlements.length, 2);
      expect(cubit.state.pendingSettlements.length, 1);
      expect(cubit.state.pendingSettlements.first.id, 501);
    });
  });
}
