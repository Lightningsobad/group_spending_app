import '../../data/models/debt_overview_model.dart';

abstract class DebtsRepository {
  Future<DebtOverviewModel> getDebtOverview();
}
