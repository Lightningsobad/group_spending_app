import '../../domain/entities/fund_entities.dart';

enum FundDetailStatus { initial, loading, success, failure }

class FundDetailState {
  final FundDetailStatus status;
  final FundCollectionEntity? fund;
  final bool isSubmitting;
  final bool isExporting;
  final bool isDeleted;
  final int remindCooldownSeconds; // 0 = cooldown finished
  final String? errorMessage;
  final String? successMessage;

  const FundDetailState({
    this.status = FundDetailStatus.initial,
    this.fund,
    this.isSubmitting = false,
    this.isExporting = false,
    this.isDeleted = false,
    this.remindCooldownSeconds = 0,
    this.errorMessage,
    this.successMessage,
  });

  bool get isLoading => status == FundDetailStatus.loading;
  bool get isSuccess => status == FundDetailStatus.success;
  bool get isFailure => status == FundDetailStatus.failure;
  bool get canSendReminder => remindCooldownSeconds <= 0 && !isSubmitting;

  FundDetailState copyWith({
    FundDetailStatus? status,
    FundCollectionEntity? fund,
    bool? isSubmitting,
    bool? isExporting,
    bool? isDeleted,
    int? remindCooldownSeconds,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return FundDetailState(
      status: status ?? this.status,
      fund: fund ?? this.fund,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isExporting: isExporting ?? this.isExporting,
      isDeleted: isDeleted ?? this.isDeleted,
      remindCooldownSeconds:
          remindCooldownSeconds ?? this.remindCooldownSeconds,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}
