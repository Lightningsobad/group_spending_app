enum FundCollectionStatus {
  collecting('COLLECTING'),
  completed('COMPLETED');

  final String value;
  const FundCollectionStatus(this.value);

  static FundCollectionStatus fromString(String? val) {
    if (val == null) return FundCollectionStatus.collecting;
    final upper = val.toUpperCase().trim();
    for (final s in FundCollectionStatus.values) {
      if (s.value == upper) return s;
    }
    return FundCollectionStatus.collecting;
  }
}

enum FundMemberStatus {
  pending('PENDING'),
  paid('PAID');

  final String value;
  const FundMemberStatus(this.value);

  static FundMemberStatus fromString(String? val) {
    if (val == null) return FundMemberStatus.pending;
    final upper = val.toUpperCase().trim();
    for (final s in FundMemberStatus.values) {
      if (s.value == upper) return s;
    }
    return FundMemberStatus.pending;
  }
}

enum FundTimeFilter {
  all('ALL'),
  thisMonth('THIS_MONTH'),
  lastMonth('LAST_MONTH'),
  thisQuarter('THIS_QUARTER');

  final String value;
  const FundTimeFilter(this.value);

  static FundTimeFilter fromString(String? val) {
    if (val == null) return FundTimeFilter.all;
    final upper = val.toUpperCase().trim();
    for (final s in FundTimeFilter.values) {
      if (s.value == upper) return s;
    }
    return FundTimeFilter.all;
  }
}
