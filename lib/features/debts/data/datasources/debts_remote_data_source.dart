import '../../../../core/network/api_client.dart';
import '../models/debt_overview_model.dart';
import '../models/debt_settlement_model.dart';
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

  Future<void> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
    required num expectedAmount,
  });

  Future<DebtSettlementModel> paySimplifiedDebt(
    int groupId, {
    required int creditorId,
    num? amount,
    String? paymentProofUrl,
    String? note,
  });

  Future<DebtSettlementModel> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
  });

  Future<DebtSettlementModel> getDebtSettlementDetail(int settlementId);

  Future<List<DebtSettlementModel>> getGroupDebtSettlements(int groupId);
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

  @override
  Future<void> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
    required num expectedAmount,
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/debts/simplified/remind',
      data: {
        'debtorId': debtorId,
        'creditorId': creditorId,
        'expectedAmount': expectedAmount,
      },
    );
  }

  @override
  Future<DebtSettlementModel> paySimplifiedDebt(
    int groupId, {
    required int creditorId,
    num? amount,
    String? paymentProofUrl,
    String? note,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/debts/simplified/pay',
      data: {
        'creditorId': creditorId,
        'amount': ?amount,
        if (paymentProofUrl != null && paymentProofUrl.trim().isNotEmpty)
          'paymentProofUrl': paymentProofUrl.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtSettlementModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return DebtSettlementModel(
      id: 0,
      groupId: groupId,
      debtorId: 0,
      debtorName: '',
      creditorId: creditorId,
      creditorName: '',
    );
  }

  @override
  Future<DebtSettlementModel> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/debt-settlements/$settlementId/confirm',
      data: {'confirmed': confirmed},
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtSettlementModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return DebtSettlementModel(
      id: settlementId,
      groupId: 0,
      debtorId: 0,
      debtorName: '',
      creditorId: 0,
      creditorName: '',
    );
  }

  @override
  Future<DebtSettlementModel> getDebtSettlementDetail(int settlementId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/debt-settlements/$settlementId',
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtSettlementModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return DebtSettlementModel(
      id: settlementId,
      groupId: 0,
      debtorId: 0,
      debtorName: '',
      creditorId: 0,
      creditorName: '',
    );
  }

  @override
  Future<List<DebtSettlementModel>> getGroupDebtSettlements(int groupId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/debt-settlements',
    );
    final data = response.data;
    if (data != null && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => DebtSettlementModel.fromJson(item))
          .toList();
    }
    return const [];
  }
}
