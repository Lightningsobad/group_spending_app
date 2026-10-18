import '../entities/debt_overview_entity.dart';
import '../entities/debt_settlement_entity.dart';
import '../entities/group_debt_entity.dart';

abstract class DebtsRepository {
  Future<DebtOverviewEntity> getDebtOverview();

  Future<GroupSimplifiedDebtsEntity> getGroupSimplifiedDebts(int groupId);

  Future<GroupActualDebtsEntity> getGroupActualDebts(
    int groupId, {
    String? status,
  });

  Future<void> markDebtAsPaid(int debtId);

  Future<void> confirmDebtSettled(int debtId, {required bool confirmed});

  Future<void> sendDebtReminder(int debtId);

  Future<void> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
  });

  Future<DebtSettlementEntity> paySimplifiedDebt(
    int groupId, {
    required int creditorId,
    num? amount,
    String? paymentProofUrl,
    String? note,
  });

  Future<DebtSettlementEntity> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
  });

  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId);

  Future<List<DebtSettlementEntity>> getGroupDebtSettlements(int groupId);
}
