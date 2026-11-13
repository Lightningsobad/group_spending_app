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
    required num expectedAmount,
  });

  Future<DebtPaymentPreviewEntity> previewSimplifiedDebtPayment(
    int groupId, {
    required int creditorId,
    required num expectedAmount,
  });

  Future<DebtSettlementEntity> paySimplifiedDebt(
    int groupId, {
    required String planToken,
    String? idempotencyKey,
  });

  Future<DebtSettlementEntity> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
    String? reason,
  });

  Future<DebtSettlementEntity> getDebtSettlementDetail(int settlementId);

  Future<DebtSettlementPageEntity> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  });

  Future<List<DebtSettlementEntity>> getAllPendingDebtSettlements(int groupId);
}
