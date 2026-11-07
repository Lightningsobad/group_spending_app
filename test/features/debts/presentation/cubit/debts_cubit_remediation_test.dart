import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_overview_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_settlement_entity.dart';
import 'package:group_spending_app/features/debts/domain/entities/group_debt_entity.dart';
import 'package:group_spending_app/features/debts/domain/repositories/debts_repository.dart';
import 'package:group_spending_app/features/debts/presentation/cubit/debts_cubit.dart';

class _CompleterDebtsRepository implements DebtsRepository {
  final Map<int, Completer<GroupSimplifiedDebtsEntity>> simplifiedCompleters = {};
  final Map<int, Completer<GroupActualDebtsEntity>> actualCompleters = {};
  final Map<int, Completer<List<DebtSettlementEntity>>> settlementsCompleters = {};
  final List<int> pendingSettlementsCalls = [];

  Completer<GroupSimplifiedDebtsEntity> getSimplifiedCompleter(int groupId) {
    return simplifiedCompleters.putIfAbsent(groupId, () => Completer());
  }

  Completer<GroupActualDebtsEntity> getActualCompleter(int groupId) {
    return actualCompleters.putIfAbsent(groupId, () => Completer());
  }

  Completer<List<DebtSettlementEntity>> getSettlementsCompleter(int groupId) {
    return settlementsCompleters.putIfAbsent(groupId, () => Completer());
  }

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) {
    return getSimplifiedCompleter(groupId).future;
  }

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(int groupId, {String? status}) {
    return getActualCompleter(groupId).future;
  }

  @override
  Future<List<DebtSettlementEntity>> getAllPendingDebtSettlements(int groupId) {
    pendingSettlementsCalls.add(groupId);
    return getSettlementsCompleter(groupId).future;
  }

  @override
  Future<DebtOverviewEntity> getDebtOverview() async => const DebtOverviewEntity();

  @override
  Future<DebtSettlementPageEntity> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    return const DebtSettlementPageEntity(
      content: [],
      pageNumber: 0,
      totalPages: 1,
      totalElements: 0,
      last: true,
    );
  }

  @override
  Future<void> markDebtAsPaid(int debtId) async {}
  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {}
  @override
  Future<void> sendDebtReminder(int debtId) async {}
  @override
  Future<void> sendSimplifiedDebtReminder(int groupId, {required int debtorId, required int creditorId, required num expectedAmount}) async {}
  @override
  Future<DebtPaymentPreviewEntity> previewSimplifiedDebtPayment(int groupId, {required int creditorId, required num expectedAmount}) async => throw UnimplementedError();
  @override
  Future<DebtSettlementEntity> paySimplifiedDebt(int groupId, {required String planToken, String? idempotencyKey}) async => throw UnimplementedError();
  @override
  Future<DebtSettlementEntity> confirmDebtSettlement(int settlementId, {required bool confirmed, String? reason}) async => throw UnimplementedError();
  @override
  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId) async => throw UnimplementedError();
}

void main() {
  group('DebtsCubit Remediation Tests (DEBT-01 & DEBT-02)', () {
    late _CompleterDebtsRepository repo;
    late DebtsCubit cubit;

    setUp(() {
      repo = _CompleterDebtsRepository();
      cubit = DebtsCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('01-A: Group A slow, Group B fast; late A response does not overwrite B state', () async {
      // 1. Select group 10 (A) -> starts loading
      cubit.selectGroup(10);
      expect(cubit.state.selectedGroupId, 10);
      expect(cubit.state.isDetailLoading, isTrue);

      // 2. User quickly switches to group 20 (B)
      cubit.selectGroup(20);
      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.isDetailLoading, isTrue);

      // 3. Complete group 20 (B) first
      repo.getSimplifiedCompleter(20).complete(
            const GroupSimplifiedDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 20, groupName: 'Group B'),
              simplifiedDebts: [],
            ),
          );
      repo.getActualCompleter(20).complete(
            const GroupActualDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 20, groupName: 'Group B'),
              actualDebts: [],
            ),
          );
      repo.getSettlementsCompleter(20).complete([]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.isDetailLoading, isFalse);
      expect(cubit.state.simplifiedDebts?.userBalance.groupId, 20);

      // 4. Now group 10 (A) completes LATE
      repo.getSimplifiedCompleter(10).complete(
            const GroupSimplifiedDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
              simplifiedDebts: [],
            ),
          );
      repo.getActualCompleter(10).complete(
            const GroupActualDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
              actualDebts: [],
            ),
          );
      repo.getSettlementsCompleter(10).complete([]);

      await Future.delayed(const Duration(milliseconds: 10));

      // Must STILL be Group 20 data! Group 10 data was rejected.
      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.simplifiedDebts?.userBalance.groupId, 20);
      expect(cubit.state.actualDebts?.userBalance.groupId, 20);
    });

    test('01-B: Late error on Group A does not show on Group B or alter loading', () async {
      cubit.selectGroup(10);
      cubit.selectGroup(20);

      // Complete B successfully
      repo.getSimplifiedCompleter(20).complete(
            const GroupSimplifiedDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 20, groupName: 'Group B'),
            ),
          );
      repo.getActualCompleter(20).complete(
            const GroupActualDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 20, groupName: 'Group B'),
            ),
          );
      repo.getSettlementsCompleter(20).complete([]);

      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.isDetailLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);

      // Late error on A
      repo.getSimplifiedCompleter(10).completeError(const AppException(message: 'Error from group A'));
      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.selectedGroupId, 20);
      expect(cubit.state.isDetailLoading, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('01-D: Deselecting group (selectGroup(null)) invalidates in-flight response', () async {
      cubit.selectGroup(10);
      expect(cubit.state.isDetailLoading, isTrue);

      // User navigates back
      cubit.selectGroup(null);
      expect(cubit.state.selectedGroupId, isNull);
      expect(cubit.state.simplifiedDebts, isNull);

      // In-flight group 10 finishes
      repo.getSimplifiedCompleter(10).complete(
            const GroupSimplifiedDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
            ),
          );
      repo.getActualCompleter(10).complete(
            const GroupActualDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
            ),
          );
      repo.getSettlementsCompleter(10).complete([]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.selectedGroupId, isNull);
      expect(cubit.state.simplifiedDebts, isNull);
      expect(cubit.state.actualDebts, isNull);
    });

    test('01-E: A -> deselect -> A while first A request is pending; only second A is accepted', () async {
      // 1. Select A (req 1)
      cubit.selectGroup(10);
      final firstSimplified = repo.getSimplifiedCompleter(10);
      final firstActual = repo.getActualCompleter(10);
      final firstSettlements = repo.getSettlementsCompleter(10);

      // 2. Deselect
      cubit.selectGroup(null);

      // 3. Select A again (req 2)
      repo.simplifiedCompleters.remove(10);
      repo.actualCompleters.remove(10);
      repo.settlementsCompleters.remove(10);
      cubit.selectGroup(10);
      final secondSimplified = repo.getSimplifiedCompleter(10);
      final secondActual = repo.getActualCompleter(10);
      final secondSettlements = repo.getSettlementsCompleter(10);

      // 4. Complete first request late with old data
      firstSimplified.complete(
        const GroupSimplifiedDebtsEntity(
          userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'OLD A'),
        ),
      );
      firstActual.complete(
        const GroupActualDebtsEntity(
          userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'OLD A'),
        ),
      );
      firstSettlements.complete([]);

      await Future.delayed(const Duration(milliseconds: 10));

      // Still loading second request; old data NOT applied
      expect(cubit.state.isDetailLoading, isTrue);
      expect(cubit.state.simplifiedDebts, isNull);

      // 5. Complete second request with new data
      secondSimplified.complete(
        const GroupSimplifiedDebtsEntity(
          userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'NEW A'),
        ),
      );
      secondActual.complete(
        const GroupActualDebtsEntity(
          userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'NEW A'),
        ),
      );
      secondSettlements.complete([]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.isDetailLoading, isFalse);
      expect(cubit.state.simplifiedDebts?.userBalance.groupName, 'NEW A');
    });

    test('02-A: loadGroupDebts calls getAllPendingDebtSettlements instead of getGroupDebtSettlements', () async {
      cubit.selectGroup(10);
      repo.getSimplifiedCompleter(10).complete(
            const GroupSimplifiedDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
            ),
          );
      repo.getActualCompleter(10).complete(
            const GroupActualDebtsEntity(
              userBalance: DebtUserBalanceEntity(groupId: 10, groupName: 'Group A'),
            ),
          );
      repo.getSettlementsCompleter(10).complete([
        const DebtSettlementEntity(
          id: 501,
          groupId: 10,
          debtorId: 1,
          creditorId: 2,
          amount: 150000,
          status: DebtStatus.waitingForConfirmation,
        ),
      ]);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(repo.pendingSettlementsCalls, contains(10));
      expect(cubit.state.pendingSettlements.length, 1);
      expect(cubit.state.pendingSettlements.first.id, 501);
    });
  });
}
