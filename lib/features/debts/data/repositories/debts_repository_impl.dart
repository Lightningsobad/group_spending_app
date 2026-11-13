import '../../domain/entities/debt_overview_entity.dart';
import '../../domain/entities/debt_settlement_entity.dart';
import '../../domain/entities/group_debt_entity.dart';
import '../../domain/repositories/debts_repository.dart';
import '../datasources/debts_remote_data_source.dart';

class DebtsRepositoryImpl implements DebtsRepository {
  final DebtsRemoteDataSource remoteDataSource;

  DebtsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DebtOverviewEntity> getDebtOverview() {
    return remoteDataSource.getDebtOverview();
  }

  @override
  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId) {
    return remoteDataSource.getGroupSimplifiedDebts(groupId);
  }

  @override
  Future<GroupActualDebtsEntity> getGroupActualDebts(
    int groupId, {
    String? status,
  }) {
    return remoteDataSource.getGroupActualDebts(groupId, status: status);
  }

  @override
  Future<void> markDebtAsPaid(int debtId) {
    return remoteDataSource.markDebtAsPaid(debtId);
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) {
    return remoteDataSource.confirmDebtSettled(debtId, confirmed: confirmed);
  }

  @override
  Future<void> sendDebtReminder(int debtId) {
    return remoteDataSource.sendDebtReminder(debtId);
  }

  @override
  Future<void> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
    required num expectedAmount,
  }) {
    return remoteDataSource.sendSimplifiedDebtReminder(
      groupId,
      debtorId: debtorId,
      creditorId: creditorId,
      expectedAmount: expectedAmount,
    );
  }

  @override
  Future<DebtPaymentPreviewEntity> previewSimplifiedDebtPayment(
    int groupId, {
    required int creditorId,
    required num expectedAmount,
  }) {
    return remoteDataSource.previewSimplifiedDebtPayment(
      groupId,
      creditorId: creditorId,
      expectedAmount: expectedAmount,
    );
  }

  @override
  Future<DebtSettlementEntity> paySimplifiedDebt(
    int groupId, {
    required String planToken,
    String? idempotencyKey,
  }) {
    return remoteDataSource.paySimplifiedDebt(
      groupId,
      planToken: planToken,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<DebtSettlementEntity> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
    String? reason,
  }) {
    return remoteDataSource.confirmDebtSettlement(
      settlementId,
      confirmed: confirmed,
      reason: reason,
    );
  }

  @override
  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId) {
    return remoteDataSource.getDebtSettlementDetail(settlementId);
  }

  @override
  Future<DebtSettlementPageEntity> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return remoteDataSource.getGroupDebtSettlements(
      groupId,
      status: status,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<DebtSettlementEntity>> getAllPendingDebtSettlements(
    int groupId,
  ) async {
    int page = 0;
    const maxPages = 50;
    final allSettlements = <DebtSettlementEntity>[];
    final seenIds = <int>{};

    while (page < maxPages) {
      final pageResult = await remoteDataSource.getGroupDebtSettlements(
        groupId,
        status: 'WAITING_FOR_CONFIRMATION',
        page: page,
        size: 20,
      );

      for (final item in pageResult.content) {
        if (seenIds.add(item.id)) {
          allSettlements.add(item);
        }
      }

      if (pageResult.last ||
          pageResult.content.isEmpty ||
          pageResult.pageNumber >= pageResult.totalPages - 1) {
        break;
      }

      page++;
    }

    return allSettlements;
  }
}
