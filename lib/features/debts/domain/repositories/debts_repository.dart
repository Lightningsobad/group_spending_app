import '../entities/debt_overview_entity.dart';
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
}
