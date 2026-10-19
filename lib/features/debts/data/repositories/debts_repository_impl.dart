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
  Future<DebtSettlementEntity> paySimplifiedDebt(
    int groupId, {
    required int creditorId,
    num? amount,
    String? paymentProofUrl,
    String? note,
  }) {
    return remoteDataSource.paySimplifiedDebt(
      groupId,
      creditorId: creditorId,
      amount: amount,
      paymentProofUrl: paymentProofUrl,
      note: note,
    );
  }

  @override
  Future<DebtSettlementEntity> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
  }) {
    return remoteDataSource.confirmDebtSettlement(
      settlementId,
      confirmed: confirmed,
    );
  }

  @override
  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId) {
    return remoteDataSource.getDebtSettlementDetail(settlementId);
  }

  @override
  Future<List<DebtSettlementEntity>> getGroupDebtSettlements(int groupId) {
    return remoteDataSource.getGroupDebtSettlements(groupId);
  }
}
