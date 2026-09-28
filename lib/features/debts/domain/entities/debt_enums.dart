enum DebtStatus {
  pending,
  waitingForConfirmation,
  settled;

  static DebtStatus fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'WAITING_FOR_CONFIRMATION':
        return DebtStatus.waitingForConfirmation;
      case 'SETTLED':
        return DebtStatus.settled;
      case 'PENDING':
      default:
        return DebtStatus.pending;
    }
  }

  String toServerString() {
    switch (this) {
      case DebtStatus.waitingForConfirmation:
        return 'WAITING_FOR_CONFIRMATION';
      case DebtStatus.settled:
        return 'SETTLED';
      case DebtStatus.pending:
        return 'PENDING';
    }
  }
}

enum DebtAction {
  pay,
  confirm,
  remind,
  none;

  static DebtAction fromString(String? val) {
    switch (val?.toUpperCase()) {
      case 'PAY':
        return DebtAction.pay;
      case 'CONFIRM':
        return DebtAction.confirm;
      case 'REMIND':
        return DebtAction.remind;
      default:
        return DebtAction.none;
    }
  }
}

enum PeerDebtType {
  youOwe,
  owedToYou;

  static PeerDebtType fromString(String? val) {
    if (val?.toUpperCase() == 'YOU_OWE') return PeerDebtType.youOwe;
    return PeerDebtType.owedToYou;
  }
}

enum DebtOverviewFilter {
  all,
  hasDebt,
  settled,
}
