import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/debts/data/datasources/debts_remote_data_source.dart';
import 'package:group_spending_app/features/debts/data/models/actual_debt_model.dart';
import 'package:group_spending_app/features/debts/data/models/debt_overview_model.dart';
import 'package:group_spending_app/features/debts/data/models/debt_settlement_model.dart';
import 'package:group_spending_app/features/debts/data/models/group_debts_models.dart';
import 'package:group_spending_app/features/debts/data/models/simplified_debt_model.dart';
import 'package:group_spending_app/features/debts/data/repositories/debts_repository_impl.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';

class _FakeRemoteDataSource implements DebtsRemoteDataSource {
  final Map<int, DebtSettlementPageModel> pagesByPageNumber = {};
  bool throwOnSecondPage = false;
  final List<int> requestedPages = [];

  @override
  Future<DebtSettlementPageModel> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    requestedPages.add(page);
    if (throwOnSecondPage && page == 1) {
      throw Exception('Network error on page 1');
    }
    return pagesByPageNumber[page] ??
        DebtSettlementPageModel(
          content: const [],
          pageNumber: page,
          totalPages: 1,
          totalElements: 0,
          last: true,
        );
  }

  @override
  Future<DebtOverviewModel> getDebtOverview() => throw UnimplementedError();
  @override
  Future<GroupSimplifiedDebtsModel> getGroupSimplifiedDebts(int groupId) =>
      throw UnimplementedError();
  @override
  Future<GroupActualDebtsModel> getGroupActualDebts(int groupId,
          {String? status}) =>
      throw UnimplementedError();
  @override
  Future<void> markDebtAsPaid(int debtId) => throw UnimplementedError();
  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) =>
      throw UnimplementedError();
  @override
  Future<void> sendDebtReminder(int debtId) => throw UnimplementedError();
  @override
  Future<void> sendSimplifiedDebtReminder(int groupId,
          {required int debtorId,
          required int creditorId,
          required num expectedAmount}) =>
      throw UnimplementedError();
  @override
  Future<DebtPaymentPreviewModel> previewSimplifiedDebtPayment(int groupId,
          {required int creditorId, required num expectedAmount}) =>
      throw UnimplementedError();
  @override
  Future<DebtSettlementModel> paySimplifiedDebt(int groupId,
          {required String planToken, String? idempotencyKey}) =>
      throw UnimplementedError();
  @override
  Future<DebtSettlementModel> confirmDebtSettlement(int settlementId,
          {required bool confirmed, String? reason}) =>
      throw UnimplementedError();
  @override
  Future<DebtSettlementModel> getDebtSettlementDetail(int settlementId) =>
      throw UnimplementedError();
}

void main() {
  group('DebtsRepositoryImpl getAllPendingDebtSettlements', () {
    late _FakeRemoteDataSource fakeRemote;
    late DebtsRepositoryImpl repository;

    setUp(() {
      fakeRemote = _FakeRemoteDataSource();
      repository = DebtsRepositoryImpl(remoteDataSource: fakeRemote);
    });

    test('fetches multiple pages sequentially and deduplicates items', () async {
      fakeRemote.pagesByPageNumber[0] = const DebtSettlementPageModel(
        content: [
          DebtSettlementModel(
            id: 101,
            groupId: 10,
            debtorId: 1,
            creditorId: 2,
            amount: 100,
            status: DebtStatus.waitingForConfirmation,
          ),
          DebtSettlementModel(
            id: 102,
            groupId: 10,
            debtorId: 3,
            creditorId: 2,
            amount: 150,
            status: DebtStatus.waitingForConfirmation,
          ),
        ],
        pageNumber: 0,
        totalPages: 2,
        totalElements: 3,
        last: false,
      );

      // Page 1 contains settlement 102 (duplicate from shift) and 103 (new)
      fakeRemote.pagesByPageNumber[1] = const DebtSettlementPageModel(
        content: [
          DebtSettlementModel(
            id: 102,
            groupId: 10,
            debtorId: 3,
            creditorId: 2,
            amount: 150,
            status: DebtStatus.waitingForConfirmation,
          ),
          DebtSettlementModel(
            id: 103,
            groupId: 10,
            debtorId: 4,
            creditorId: 2,
            amount: 200,
            status: DebtStatus.waitingForConfirmation,
          ),
        ],
        pageNumber: 1,
        totalPages: 2,
        totalElements: 3,
        last: true,
      );

      final result = await repository.getAllPendingDebtSettlements(10);

      expect(fakeRemote.requestedPages, [0, 1]);
      expect(result.length, 3);
      expect(result.map((s) => s.id).toList(), [101, 102, 103]);
    });

    test('rethrows exception if a page fails during sequential loading', () async {
      fakeRemote.throwOnSecondPage = true;
      fakeRemote.pagesByPageNumber[0] = const DebtSettlementPageModel(
        content: [
          DebtSettlementModel(
            id: 101,
            groupId: 10,
            debtorId: 1,
            creditorId: 2,
            amount: 100,
            status: DebtStatus.waitingForConfirmation,
          ),
        ],
        pageNumber: 0,
        totalPages: 2,
        totalElements: 2,
        last: false,
      );

      expect(
        () => repository.getAllPendingDebtSettlements(10),
        throwsA(isA<Exception>()),
      );
    });
  });
}
