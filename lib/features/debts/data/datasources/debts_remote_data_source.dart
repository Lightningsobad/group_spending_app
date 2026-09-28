import '../../../../core/network/api_client.dart';
import '../models/debt_overview_model.dart';
import '../models/group_debts_models.dart';

abstract class DebtsRemoteDataSource {
  Future<DebtOverviewModel> getDebtOverview();

  Future<GroupSimplifiedDebtsModel> getGroupSimplifiedDebts(int groupId);

  Future<GroupActualDebtsModel> getGroupActualDebts(
    int groupId, {
    String? status,
  });

  Future<void> markDebtAsPaid(int debtId);

  Future<void> confirmDebtSettled(int debtId, {required bool confirmed});

  Future<void> sendDebtReminder(int debtId);
}

class DebtsRemoteDataSourceImpl implements DebtsRemoteDataSource {
  final ApiClient _apiClient;

  DebtsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DebtOverviewModel> getDebtOverview() async {
    final response =
        await _apiClient.get<Map<String, dynamic>>('/debts/overview');
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtOverviewModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return const DebtOverviewModel();
  }

  @override
  Future<GroupSimplifiedDebtsModel> getGroupSimplifiedDebts(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/debts/simplified',
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupSimplifiedDebtsModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return const GroupSimplifiedDebtsModel(
      userBalance: DebtUserBalanceModel(groupId: 0, groupName: ''),
    );
  }

  @override
  Future<GroupActualDebtsModel> getGroupActualDebts(
    int groupId, {
    String? status,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/debts/actual',
      queryParameters: status != null ? {'status': status} : null,
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return GroupActualDebtsModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return const GroupActualDebtsModel(
      userBalance: DebtUserBalanceModel(groupId: 0, groupName: ''),
    );
  }

  @override
  Future<void> markDebtAsPaid(int debtId) async {
    await _apiClient.post<Map<String, dynamic>>('/debts/$debtId/pay');
  }

  @override
  Future<void> confirmDebtSettled(int debtId, {required bool confirmed}) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/debts/$debtId/confirm',
      queryParameters: {'confirmed': confirmed},
    );
  }

  @override
  Future<void> sendDebtReminder(int debtId) async {
    await _apiClient.post<Map<String, dynamic>>('/debts/$debtId/remind');
  }
}
