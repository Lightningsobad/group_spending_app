import 'package:dio/dio.dart';
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

  Future<DebtPaymentPreviewModel> previewSimplifiedDebtPayment(
    int groupId, {
    required int creditorId,
    required num expectedAmount,
  });

  Future<DebtSettlementModel> paySimplifiedDebt(
    int groupId, {
    required String planToken,
    String? idempotencyKey,
  });

  Future<DebtSettlementModel> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
    String? reason,
  });

  Future<DebtSettlementModel> getDebtSettlementDetail(int settlementId);

  Future<DebtSettlementPageModel> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  });
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
  Future<DebtPaymentPreviewModel> previewSimplifiedDebtPayment(
    int groupId, {
    required int creditorId,
    required num expectedAmount,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/debts/simplified/payment-preview',
      data: {
        'creditorId': creditorId,
        'expectedAmount': expectedAmount,
      },
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtPaymentPreviewModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return DebtPaymentPreviewModel(
      planToken: '',
      groupId: groupId,
      debtorId: 0,
      creditorId: creditorId,
    );
  }

  @override
  Future<DebtSettlementModel> paySimplifiedDebt(
    int groupId, {
    required String planToken,
    String? idempotencyKey,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/groups/$groupId/debts/simplified/pay',
      options: Options(
        headers: {
          if (idempotencyKey != null && idempotencyKey.isNotEmpty)
            'Idempotency-Key': idempotencyKey,
        },
      ),
      data: {
        'planToken': planToken,
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
      creditorId: 0,
    );
  }

  @override
  Future<DebtSettlementModel> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
    String? reason,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/debt-settlements/$settlementId/confirm',
      data: {
        'confirmed': confirmed,
        'reason': reason,
      },
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtSettlementModel.fromJson(data['data'] as Map<String, dynamic>);
    }
    return DebtSettlementModel(
      id: settlementId,
      groupId: 0,
      debtorId: 0,
      creditorId: 0,
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
      creditorId: 0,
    );
  }

  @override
  Future<DebtSettlementPageModel> getGroupDebtSettlements(
    int groupId, {
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/groups/$groupId/debt-settlements',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (page > 0) 'page': page,
        if (size != 20) 'size': size,
      },
    );
    final data = response.data;
    if (data != null && data['data'] is Map<String, dynamic>) {
      return DebtSettlementPageModel.fromJson(
        data['data'] as Map<String, dynamic>,
      );
    }
    return const DebtSettlementPageModel(
      content: [],
      pageNumber: 0,
      totalPages: 1,
      totalElements: 0,
      last: true,
    );
  }
}
