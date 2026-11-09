import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/data/models/group_summary_model.dart';

void main() {
  group('GroupSummaryModel Tests', () {
    test('should parse JSON with category correctly', () {
      final json = {
        'id': 9,
        'name': 'Nhóm đồ án',
        'category': 'Works & Project',
        'totalSpending': 0,
        'totalSpendingVnd': 0,
        'memberCount': 2,
        'status': 'ACTIVE',
      };

      final summary = GroupSummaryModel.fromJson(json);

      expect(summary.id, 9);
      expect(summary.name, 'Nhóm đồ án');
      expect(summary.category, 'Works & Project');
      expect(summary.effectiveCategory, 'Works & Project');
      expect(summary.totalSpending, 0);
      expect(summary.totalSpendingVnd, 0);
      expect(summary.spendingVnd, 0);
      expect(summary.memberCount, 2);
      expect(summary.status, 'ACTIVE');
    });

    test('should fallback effectiveCategory to Other when category is null or empty', () {
      final jsonWithoutCategory = {
        'id': 1,
        'name': 'Nhóm chưa có chủ đề',
        'totalSpendingVnd': 500000,
        'memberCount': 3,
      };

      final summary1 = GroupSummaryModel.fromJson(jsonWithoutCategory);
      expect(summary1.category, isNull);
      expect(summary1.effectiveCategory, 'Other');

      final summary2 = const GroupSummaryModel(
        id: 2,
        name: 'Nhóm category rỗng',
        category: '   ',
      );
      expect(summary2.effectiveCategory, 'Other');
    });

    test('should serialize and calculate spendingVnd correctly', () {
      const summary = GroupSummaryModel(
        id: 7,
        name: 'Hội đồng niên',
        category: 'Friends & Dining',
        totalSpending: 3800,
        memberCount: 2,
      );

      expect(summary.spendingVnd, 3800000);
      expect(summary.effectiveCategory, 'Friends & Dining');

      final json = summary.toJson();
      expect(json['id'], 7);
      expect(json['name'], 'Hội đồng niên');
      expect(json['category'], 'Friends & Dining');
      expect(json['totalSpending'], 3800);
      expect(json['memberCount'], 2);
    });
  });
}
