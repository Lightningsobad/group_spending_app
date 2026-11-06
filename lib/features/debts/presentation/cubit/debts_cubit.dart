import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/session/session_coordinator.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/domain/repositories/groups_repository.dart';
import '../../domain/entities/debt_enums.dart';
import '../../domain/entities/debt_overview_entity.dart';
import '../../domain/entities/debt_settlement_entity.dart';
import '../../domain/entities/group_debt_entity.dart';
import '../../domain/repositories/debts_repository.dart';
import 'debts_state.dart';

class DebtsCubit extends Cubit<DebtsState> {
  final DebtsRepository _repository;
  final GroupsRepository? groupsRepository;
  final SessionCoordinator? sessionCoordinator;
  final DataSyncCoordinator? dataSyncCoordinator;
  int _activeGroupRequestId = 0;

  DebtsCubit(
    this._repository, {
    this.groupsRepository,
    this.sessionCoordinator,
    this.dataSyncCoordinator,
  }) : super(const DebtsState()) {
    dataSyncCoordinator?.addListener(_onDataSync);
  }

  void _onDataSync() {
    final scope = dataSyncCoordinator?.lastScope;
    if (scope == DataSyncScope.debts || scope == DataSyncScope.all) {
      loadOverview(silent: true);
      if (state.selectedGroupId != null) {
        loadGroupDebts(state.selectedGroupId!, silent: true);
      }
    }
  }

  @override
  Future<void> close() {
    dataSyncCoordinator?.removeListener(_onDataSync);
    return super.close();
  }

  void reset() {
    _activeGroupRequestId++;
    emit(const DebtsState());
  }

  Future<void> loadOverview({bool silent = false}) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    if (!silent) {
      emit(state.copyWith(status: DebtsStatus.loading, clearMessages: true));
    }

    try {
      final futures = <Future<dynamic>>[
        _repository.getDebtOverview(),
      ];
      if (groupsRepository != null) {
        futures.add(groupsRepository!.getMyGroups(filter: 'ALL'));
      }

      final results = await Future.wait(futures);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }

      var overview = results[0] as DebtOverviewEntity;
      List<GroupModel> groups = state.userGroups;
      if (results.length > 1 && results[1] is List<GroupModel>) {
        groups = results[1] as List<GroupModel>;
      }

      if (groups.isNotEmpty) {
        final groupBalancesMap = {
          for (final gb in overview.groupBalances) gb.groupId: gb,
        };
        final updatedGroupBalances = groups.map((g) {
          final existing = groupBalancesMap[g.id];
          final netVnd = existing != null && existing.netBalanceVnd != 0
              ? existing.netBalanceVnd
              : g.userBalance;
          final net = existing != null && existing.netBalance != 0
              ? existing.netBalance
              : (netVnd / 1000);
          final oweVnd = netVnd < 0 ? netVnd.abs() : 0;
          final owe = oweVnd / 1000;
          final owedVnd = netVnd > 0 ? netVnd : 0;
          final owed = owedVnd / 1000;
          final pendingCount = existing != null && existing.pendingDebtCount > 0
              ? existing.pendingDebtCount
              : g.pendingDebtCount;

          return GroupDebtBalanceEntity(
            groupId: g.id,
            groupName: g.name.isNotEmpty
                ? g.name
                : (existing?.groupName ?? ''),
            category: g.category.isNotEmpty
                ? g.category
                : (existing?.category ?? 'Other'),
            youOwe: existing != null && existing.youOwe != 0 ? existing.youOwe : owe,
            youOweVnd: existing != null && existing.youOweVnd != 0 ? existing.youOweVnd : oweVnd,
            youAreOwed: existing != null && existing.youAreOwed != 0 ? existing.youAreOwed : owed,
            youAreOwedVnd: existing != null && existing.youAreOwedVnd != 0 ? existing.youAreOwedVnd : owedVnd,
            netBalance: net,
            netBalanceVnd: netVnd,
            pendingDebtCount: pendingCount,
          );
        }).toList();

        final groupIds = {for (final g in groups) g.id};
        for (final gb in overview.groupBalances) {
          if (!groupIds.contains(gb.groupId)) {
            updatedGroupBalances.add(gb);
          }
        }

        num totalOwedVnd = overview.totalOwedVnd;
        num totalReceivableVnd = overview.totalReceivableVnd;
        if (totalOwedVnd == 0 && totalReceivableVnd == 0) {
          for (final gb in updatedGroupBalances) {
            totalOwedVnd += gb.youOweVnd;
            totalReceivableVnd += gb.youAreOwedVnd;
          }
        }

        overview = DebtOverviewEntity(
          totalOwed: overview.totalOwed != 0 ? overview.totalOwed : (totalOwedVnd / 1000),
          totalOwedVnd: totalOwedVnd,
          totalReceivable: overview.totalReceivable != 0 ? overview.totalReceivable : (totalReceivableVnd / 1000),
          totalReceivableVnd: totalReceivableVnd,
          netBalance: overview.netBalance != 0 ? overview.netBalance : ((totalReceivableVnd - totalOwedVnd) / 1000),
          netBalanceVnd: overview.netBalanceVnd != 0 ? overview.netBalanceVnd : (totalReceivableVnd - totalOwedVnd),
          groupBalances: updatedGroupBalances,
          details: overview.details,
        );
      }

      emit(
        state.copyWith(
          status: DebtsStatus.success,
          overview: overview,
          userGroups: groups,
          clearMessages: !silent,
        ),
      );
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: DebtsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return;
      }
      emit(
        state.copyWith(
          status: DebtsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectGroup(int? groupId, {String? groupName}) {
    _activeGroupRequestId++;
    if (groupId == null) {
      emit(state.copyWith(
        clearSelectedGroup: true,
        clearGroupDetails: true,
        isDetailLoading: false,
      ));
      return;
    }

    final isDifferentGroup = groupId != state.selectedGroupId;
    emit(
      state.copyWith(
        selectedGroupId: groupId,
        selectedGroupName: groupName,
        isDetailLoading: true,
        clearGroupDetails: isDifferentGroup,
        clearMessages: true,
      ),
    );
    loadGroupDebts(groupId);
  }

  Future<void> loadGroupDebts(int groupId, {bool silent = false}) async {
    if (state.selectedGroupId != null && state.selectedGroupId != groupId) {
      return;
    }
    if (state.selectedGroupId == null) {
      emit(state.copyWith(selectedGroupId: groupId));
    }

    final currentRequestId = ++_activeGroupRequestId;
    final capturedGroupId = groupId;
    final capturedFilter = state.actualDebtStatusFilter;
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;

    if (!silent) {
      emit(state.copyWith(isDetailLoading: true, clearMessages: true));
    }

    try {
      final results = await Future.wait([
        _repository.getGroupSimplifiedDebts(groupId),
        _repository.getGroupActualDebts(
          groupId,
          status: capturedFilter,
        ),
        _repository.getAllPendingDebtSettlements(groupId),
      ]);

      final isValid = !isClosed &&
          (sessionCoordinator == null ||
              sessionCoordinator!.sessionEpoch == requestEpoch) &&
          currentRequestId == _activeGroupRequestId &&
          state.selectedGroupId == capturedGroupId &&
          state.actualDebtStatusFilter == capturedFilter;

      if (!isValid) {
        return;
      }

      var simplified = results[0] as GroupSimplifiedDebtsEntity;
      var actual = results[1] as GroupActualDebtsEntity;
      final settlements = results[2] as List<DebtSettlementEntity>;

      final matchedGroup =
          state.userGroups.where((g) => g.id == groupId).firstOrNull;
      if (matchedGroup != null) {
        final enrichedUserBalance = DebtUserBalanceEntity(
          groupId: simplified.userBalance.groupId,
          groupName: matchedGroup.name.isNotEmpty
              ? matchedGroup.name
              : simplified.userBalance.groupName,
          category: matchedGroup.category,
          youOwe: simplified.userBalance.youOwe,
          youOweVnd: simplified.userBalance.youOweVnd,
          youAreOwed: simplified.userBalance.youAreOwed,
          youAreOwedVnd: simplified.userBalance.youAreOwedVnd,
          netBalance: simplified.userBalance.netBalance,
          netBalanceVnd: simplified.userBalance.netBalanceVnd,
        );

        simplified = GroupSimplifiedDebtsEntity(
          userBalance: enrichedUserBalance,
          simplifiedDebts: simplified.simplifiedDebts,
        );
        actual = GroupActualDebtsEntity(
          userBalance: enrichedUserBalance,
          actualDebts: actual.actualDebts,
        );
      }

      emit(
        state.copyWith(
          isDetailLoading: false,
          simplifiedDebts: simplified,
          actualDebts: actual,
          settlements: settlements,
          clearMessages: !silent,
        ),
      );
    } on AppException catch (e) {
      final isValid = !isClosed &&
          (sessionCoordinator == null ||
              sessionCoordinator!.sessionEpoch == requestEpoch) &&
          currentRequestId == _activeGroupRequestId &&
          state.selectedGroupId == capturedGroupId &&
          state.actualDebtStatusFilter == capturedFilter;

      if (!isValid) {
        return;
      }
      emit(
        state.copyWith(
          isDetailLoading: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      final isValid = !isClosed &&
          (sessionCoordinator == null ||
              sessionCoordinator!.sessionEpoch == requestEpoch) &&
          currentRequestId == _activeGroupRequestId &&
          state.selectedGroupId == capturedGroupId &&
          state.actualDebtStatusFilter == capturedFilter;

      if (!isValid) {
        return;
      }
      emit(
        state.copyWith(
          isDetailLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setDetailTab(int tabIndex) {
    emit(state.copyWith(activeDetailTab: tabIndex));
  }

  void setFilter(DebtOverviewFilter filter) {
    emit(state.copyWith(activeFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> setActualDebtStatusFilter(String? status) async {
    emit(state.copyWith(actualDebtStatusFilter: status));
    if (state.selectedGroupId != null) {
      await loadGroupDebts(state.selectedGroupId!, silent: true);
    }
  }

  Future<bool> markDebtAsPaid(int debtId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.markDebtAsPaid(debtId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi yêu cầu xác nhận trả nợ!',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmDebtSettled(
    int debtId, {
    required bool confirmed,
  }) async {
    if (state.isActionSubmitting) return false;
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.confirmDebtSettled(debtId, confirmed: confirmed);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: confirmed
              ? 'Đã xác nhận nhận tiền thành công!'
              : 'Đã từ chối xác nhận nhận tiền.',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> sendDebtReminder(int debtId) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.sendDebtReminder(debtId);
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi thông báo nhắc nợ thành công!',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> sendSimplifiedDebtReminder(
    int groupId, {
    required int debtorId,
    required int creditorId,
    required num expectedAmount,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.sendSimplifiedDebtReminder(
        groupId,
        debtorId: debtorId,
        creditorId: creditorId,
        expectedAmount: expectedAmount,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi thông báo nhắc nợ thành công!',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<DebtPaymentPreviewEntity?> previewSimplifiedDebtPayment(
    int groupId, {
    required int creditorId,
    required num expectedAmount,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      final preview = await _repository.previewSimplifiedDebtPayment(
        groupId,
        creditorId: creditorId,
        expectedAmount: expectedAmount,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }

      emit(state.copyWith(isActionSubmitting: false));
      return preview;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      if (e.message.contains('SIMPLIFIED_DEBT_CHANGED') ||
          e.message.contains('thay đổi')) {
        await loadGroupDebts(groupId, silent: true);
      }
      return null;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return null;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return null;
    }
  }

  Future<bool> paySimplifiedDebt(
    int groupId, {
    required String planToken,
    String? idempotencyKey,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.paySimplifiedDebt(
        groupId,
        planToken: planToken,
        idempotencyKey: idempotencyKey,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: 'Đã gửi yêu cầu xác nhận trả nợ!',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      if (e.message.contains('SIMPLIFIED_DEBT_CHANGED') ||
          e.message.contains('thay đổi')) {
        await loadGroupDebts(groupId, silent: true);
      }
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> confirmDebtSettlement(
    int settlementId, {
    required bool confirmed,
    String? reason,
  }) async {
    final requestEpoch = sessionCoordinator?.sessionEpoch ?? 0;
    emit(state.copyWith(isActionSubmitting: true, clearMessages: true));

    try {
      await _repository.confirmDebtSettlement(
        settlementId,
        confirmed: confirmed,
        reason: reason,
      );
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }

      emit(
        state.copyWith(
          isActionSubmitting: false,
          successMessage: confirmed
              ? 'Đã xác nhận nhận tiền thành công!'
              : 'Đã từ chối xác nhận nhận tiền.',
        ),
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.debts);
      if (state.selectedGroupId != null) {
        await loadGroupDebts(state.selectedGroupId!, silent: true);
      }
      await loadOverview(silent: true);
      return true;
    } on AppException catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed ||
          (sessionCoordinator != null &&
              sessionCoordinator!.sessionEpoch != requestEpoch)) {
        return false;
      }
      emit(
        state.copyWith(
          isActionSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }
}
