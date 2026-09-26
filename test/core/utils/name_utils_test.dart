import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/utils/name_utils.dart';

void main() {
  group('NameUtils.getInitials Tests', () {
    test('extracts first letters from first and last words for Vietnamese full names', () {
      expect(NameUtils.getInitials('Nguyễn Nhật Minh'), equals('NM'));
      expect(NameUtils.getInitials('Lê Văn'), equals('LV'));
      expect(NameUtils.getInitials('Trần Thị Mai Phương'), equals('TP'));
    });

    test('extracts first two letters when name has only one word', () {
      expect(NameUtils.getInitials('Minh'), equals('MI'));
      expect(NameUtils.getInitials('An'), equals('AN'));
      expect(NameUtils.getInitials('A'), equals('A'));
    });

    test('returns FS for null or empty strings', () {
      expect(NameUtils.getInitials(null), equals('FS'));
      expect(NameUtils.getInitials(''), equals('FS'));
      expect(NameUtils.getInitials('   '), equals('FS'));
    });

    test('handles leading, trailing, and multiple spaces properly', () {
      expect(NameUtils.getInitials('   Nguyễn    Nhật   Minh   '), equals('NM'));
    });
  });
}
