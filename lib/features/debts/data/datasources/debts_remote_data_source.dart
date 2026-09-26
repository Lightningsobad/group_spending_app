import '../../../../core/network/api_client.dart';
import '../models/debt_overview_model.dart';

abstract class DebtsRemoteDataSource {
  Future<DebtOverviewModel> getDebtOverview();
}

class DebtsRemoteDataSourceImpl implements DebtsRemoteDataSource {
  final ApiClient _apiClient;

  DebtsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DebtOverviewModel> getDebtOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/debts/overview');
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtOverviewModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return const DebtOverviewModel();
  }
}
