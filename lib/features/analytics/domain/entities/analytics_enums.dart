enum StatisticsPeriod {
  thisMonth('THIS_MONTH'),
  lastMonth('LAST_MONTH'),
  currentQuarter('CURRENT_QUARTER'),
  byYear('BY_YEAR');

  final String key;
  const StatisticsPeriod(this.key);

  static StatisticsPeriod fromKey(String? key) {
    return StatisticsPeriod.values.firstWhere(
      (e) => e.key == key,
      orElse: () => StatisticsPeriod.thisMonth,
    );
  }
}

enum ExpenseTimeFilter {
  all('ALL'),
  thisMonth('THIS_MONTH'),
  lastMonth('LAST_MONTH'),
  thisQuarter('THIS_QUARTER'),
  thisYear('THIS_YEAR');

  final String key;
  const ExpenseTimeFilter(this.key);

  static ExpenseTimeFilter fromKey(String? key) {
    return ExpenseTimeFilter.values.firstWhere(
      (e) => e.key == key,
      orElse: () => ExpenseTimeFilter.all,
    );
  }
}
