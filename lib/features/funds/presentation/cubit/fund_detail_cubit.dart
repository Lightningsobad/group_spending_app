import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/sync/data_sync_coordinator.dart';
import '../../domain/repositories/funds_repository.dart';
import 'fund_detail_state.dart';

class FundDetailCubit extends Cubit<FundDetailState> {
  final FundsRepository _repository;
  final DataSyncCoordinator? dataSyncCoordinator;

  Timer? _cooldownTimer;

  FundDetailCubit(
    this._repository, {
    this.dataSyncCoordinator,
  }) : super(const FundDetailState());

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }

  void clearMessages() {
    emit(state.copyWith(clearMessages: true));
  }

  Future<void> loadFundDetails(int fundId, {bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(status: FundDetailStatus.loading, clearMessages: true));
    }

    try {
      final fund = await _repository.getFundCollectionDetails(fundId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FundDetailStatus.success,
          fund: fund,
          clearMessages: !silent,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FundDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: FundDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<bool> createFund(
    int groupId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final createdFund = await _repository.createFundCollection(
        groupId,
        name: name,
        description: description,
        targetAmountPerPersonVnd: targetAmountPerPersonVnd,
        dueDate: dueDate,
        memberUserIds: memberUserIds,
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.funds);

      if (isClosed) return true;
      emit(
        state.copyWith(
          isSubmitting: false,
          fund: createdFund,
          status: FundDetailStatus.success,
          successMessage: 'Tạo đợt đóng quỹ thành công',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> updateFund(
    int fundId, {
    required String name,
    String? description,
    required num targetAmountPerPersonVnd,
    String? dueDate,
    List<int>? memberUserIds,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final updatedFund = await _repository.updateFundCollection(
        fundId,
        name: name,
        description: description,
        targetAmountPerPersonVnd: targetAmountPerPersonVnd,
        dueDate: dueDate,
        memberUserIds: memberUserIds,
      );

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.funds);

      if (isClosed) return true;
      emit(
        state.copyWith(
          isSubmitting: false,
          fund: updatedFund,
          status: FundDetailStatus.success,
          successMessage: 'Cập nhật đợt đóng quỹ thành công',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<bool> markMemberPaid(int targetUserId) async {
    if (state.fund == null) return false;
    final fundId = state.fund!.id;

    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final updatedFund = await _repository.markMemberPaid(fundId, targetUserId);

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.funds);

      if (isClosed) return true;
      emit(
        state.copyWith(
          isSubmitting: false,
          fund: updatedFund,
          successMessage: 'Đã xác nhận thành viên đóng quỹ thành công',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> sendReminder() async {
    if (state.fund == null || !state.canSendReminder) return;
    final fundId = state.fund!.id;

    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await _repository.sendFundReminder(fundId);

      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          remindCooldownSeconds: 60,
          successMessage: 'Đã gửi thông báo nhắc đóng quỹ cho các thành viên chưa nộp',
        ),
      );

      _startCooldownTimer();
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final nextSeconds = state.remindCooldownSeconds - 1;
      if (nextSeconds <= 0) {
        timer.cancel();
        emit(state.copyWith(remindCooldownSeconds: 0));
      } else {
        emit(state.copyWith(remindCooldownSeconds: nextSeconds));
      }
    });
  }

  Future<bool> deleteFund() async {
    if (state.fund == null) return false;
    final fundId = state.fund!.id;

    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      await _repository.deleteFundCollection(fundId);

      dataSyncCoordinator?.notifyDataChanged(DataSyncScope.funds);

      if (isClosed) return true;
      emit(
        state.copyWith(
          isSubmitting: false,
          isDeleted: true,
          successMessage: 'Xóa đợt đóng quỹ thành công',
        ),
      );
      return true;
    } on AppException catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (e) {
      if (isClosed) return false;
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> exportCsv() async {
    if (state.fund == null) return;
    final fundId = state.fund!.id;

    emit(state.copyWith(isExporting: true, clearMessages: true));
    try {
      final bytes = await _repository.exportFundCsv(fundId);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/fund_collection_$fundId.csv';
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (isClosed) return;
      emit(state.copyWith(isExporting: false));

      await SharePlus.instance.share(
        ShareParams(
          text: 'Báo cáo đợt đóng quỹ ${state.fund!.name}',
          files: [XFile(filePath, mimeType: 'text/csv')],
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isExporting: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
