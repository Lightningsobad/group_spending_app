import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/analytics/data/models/expense_history_item_model.dart';
import 'package:group_spending_app/features/analytics/data/models/expense_statistics_details_model.dart';
import 'package:group_spending_app/features/analytics/data/models/leaderboard_member_model.dart';
import 'package:group_spending_app/features/analytics/data/models/personal_overview_model.dart';

void main() {
  group('Analytics Models Tests', () {
    test('PersonalOverviewModel parses JSON with Vnd suffix correctly', () {
      final json = {
        'totalSpending': 15000,
        'totalSpendingVnd': 15000000,
        'activeGroupCount': 3,
        'totalExpenses': 25,
        'myExpenseCount': 12,
      };

      final model = PersonalOverviewModel.fromJson(json);
      expect(model.totalSpendingVnd, 15000000);
      expect(model.activeGroupCount, 3);
      expect(model.totalExpenses, 25);
      expect(model.myExpenseCount, 12);

      final entity = model.toEntity();
      expect(entity.totalSpendingVnd, 15000000);
      expect(entity.activeGroupCount, 3);
    });

    test('PersonalOverviewModel falls back to totalSpending * 1000 if Vnd missing', () {
      final json = {
        'totalSpending': 5000,
        'activeGroupCount': 2,
        'totalExpenses': 10,
        'myExpenseCount': 5,
      };

      final model = PersonalOverviewModel.fromJson(json);
      expect(model.totalSpendingVnd, 5000000);
    });

    test('ExpenseStatisticsDetailsModel parses complex statistics with categories', () {
      final json = {
        'period': 'THIS_MONTH',
        'startDate': '2026-09-01',
        'endDate': '2026-09-30',
        'totalSpending': 4500,
        'totalSpendingVnd': 4500000,
        'totalExpenseCount': 18,
        'averageSpendingPerPerson': 750.0,
        'averageSpendingPerPersonVnd': 750000.0,
        'totalUniqueMembers': 6,
        'debtSettlementRate': 85.5,
        'totalDebtAmount': 2000,
        'settledDebtAmount': 1710,
        'totalDebtCount': 8,
        'settledDebtCount': 7,
        'categoryDistributions': [
          {
            'categoryId': 1,
            'categoryName': 'Ăn uống',
            'icon': 'restaurant',
            'amount': 2250,
            'amountVnd': 2250000,
            'percentage': 50.0,
            'expenseCount': 10,
          },
          {
            'categoryId': 2,
            'categoryName': 'Di chuyển',
            'icon': 'directions_car',
            'amount': 1350,
            'amountVnd': 1350000,
            'percentage': 30.0,
            'expenseCount': 5,
          },
        ],
      };

      final model = ExpenseStatisticsDetailsModel.fromJson(json);
      expect(model.period, 'THIS_MONTH');
      expect(model.totalSpendingVnd, 4500000);
      expect(model.averageSpendingPerPersonVnd, 750000.0);
      expect(model.totalUniqueMembers, 6);
      expect(model.debtSettlementRate, 85.5);
      expect(model.categoryDistributions.length, 2);
      expect(model.categoryDistributions[0].categoryName, 'Ăn uống');
      expect(model.categoryDistributions[0].amountVnd, 2250000);
      expect(model.categoryDistributions[0].percentage, 50.0);

      final entity = model.toEntity();
      expect(entity.categoryDistributions.length, 2);
    });

    test('ExpenseStatisticsDetailsModel handles group statistics with memberCount and groupId', () {
      final json = {
        'groupId': 10,
        'groupName': 'Chuyến đi Đà Lạt',
        'period': 'THIS_MONTH',
        'startDate': '2026-09-01',
        'endDate': '2026-09-30',
        'totalSpendingVnd': 3200000,
        'averageSpendingPerPersonVnd': 800000.0,
        'memberCount': 4,
        'totalExpenseCount': 12,
        'debtSettlementRate': 75.0,
        'categoryDistributions': [],
      };

      final model = ExpenseStatisticsDetailsModel.fromJson(json);
      expect(model.groupId, 10);
      expect(model.groupName, 'Chuyến đi Đà Lạt');
      expect(model.totalUniqueMembers, 4);
      expect(model.totalSpendingVnd, 3200000);
    });

    test('LeaderboardMemberModel parses correctly', () {
      final json = {
        'rank': 1,
        'userId': 5,
        'fullName': 'Trần Văn B',
        'avatarUrl': 'https://res.cloudinary.com/avatar.jpg',
        'email': 'tranvanb@example.com',
        'contributedAmount': 2500,
        'contributedAmountVnd': 2500000,
        'percentage': 50.0,
        'expenseCount': 5,
      };

      final model = LeaderboardMemberModel.fromJson(json);
      expect(model.rank, 1);
      expect(model.fullName, 'Trần Văn B');
      expect(model.contributedAmountVnd, 2500000);
      expect(model.percentage, 50.0);
      expect(model.expenseCount, 5);

      final entity = model.toEntity();
      expect(entity.rank, 1);
      expect(entity.fullName, 'Trần Văn B');
    });

    test('ExpenseHistoryItemModel parses correctly', () {
      final json = {
        'id': 105,
        'groupId': 10,
        'groupName': 'Chuyến đi Đà Lạt 2026',
        'title': 'Ăn trưa bánh ướt lòng gà',
        'expenseDate': '2026-09-20',
        'totalAmount': 450,
        'totalAmountVnd': 450000,
        'categoryName': 'Ăn uống',
        'paidByUserName': 'Nguyễn Văn A',
      };

      final model = ExpenseHistoryItemModel.fromJson(json);
      expect(model.id, 105);
      expect(model.groupId, 10);
      expect(model.groupName, 'Chuyến đi Đà Lạt 2026');
      expect(model.title, 'Ăn trưa bánh ướt lòng gà');
      expect(model.totalAmountVnd, 450000);
      expect(model.categoryName, 'Ăn uống');
      expect(model.paidByUserName, 'Nguyễn Văn A');

      final entity = model.toEntity();
      expect(entity.id, 105);
      expect(entity.totalAmountVnd, 450000);
    });
  });
}
