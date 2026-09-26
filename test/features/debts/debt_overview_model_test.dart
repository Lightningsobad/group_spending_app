import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/debts/data/models/debt_overview_model.dart';

void main() {
  group('DebtOverviewModel Tests', () {
    test('should parse correctly from api json', () {
      final json = {
        'totalOwed': 450,
        'totalOwedVnd': 450000,
        'totalReceivable': 2450,
        'totalReceivableVnd': 2450000,
        'netBalance': 2000,
        'netBalanceVnd': 2000000,
        'groupBalances': [],
        'details': [],
      };

      final model = DebtOverviewModel.fromJson(json);

      expect(model.totalOwed, 450);
      expect(model.totalOwedVnd, 450000);
      expect(model.totalReceivable, 2450);
      expect(model.totalReceivableVnd, 2450000);
      expect(model.netBalance, 2000);
      expect(model.netBalanceVnd, 2000000);
      expect(model.groupBalances, isEmpty);
      expect(model.details, isEmpty);
    });

    test('should provide default values when json has nulls', () {
      final model = DebtOverviewModel.fromJson({});

      expect(model.totalOwed, 0);
      expect(model.totalOwedVnd, 0);
      expect(model.totalReceivable, 0);
      expect(model.totalReceivableVnd, 0);
      expect(model.netBalance, 0);
      expect(model.netBalanceVnd, 0);
    });

    test('toJson returns accurate map', () {
      const model = DebtOverviewModel(
        totalOwed: 100,
        totalOwedVnd: 100000,
        totalReceivable: 500,
        totalReceivableVnd: 500000,
        netBalance: 400,
        netBalanceVnd: 400000,
      );

      final json = model.toJson();
      expect(json['totalOwed'], 100);
      expect(json['totalOwedVnd'], 100000);
      expect(json['totalReceivable'], 500);
      expect(json['totalReceivableVnd'], 500000);
      expect(json['netBalance'], 400);
      expect(json['netBalanceVnd'], 400000);
    });
  });
}
