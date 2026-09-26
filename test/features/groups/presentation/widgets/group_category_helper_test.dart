import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_category_helper.dart';

void main() {
  group('GroupCategoryHelper', () {
    test('all categories have a valid and existing SVG icon path', () {
      for (final cat in GroupCategoryHelper.categories) {
        final svgPath = GroupCategoryHelper.getSvgPath(cat);
        expect(svgPath, startsWith('assets/group_category_icons/'));
        expect(svgPath, endsWith('.svg'));
        expect(File(svgPath).existsSync(), isTrue, reason: 'File $svgPath should exist');
      }
    });

    test('fallback category defaults to other_icon.svg', () {
      final svgPath = GroupCategoryHelper.getSvgPath('Unknown_Category_XYZ');
      expect(svgPath, 'assets/group_category_icons/other_icon.svg');
      expect(File(svgPath).existsSync(), isTrue);
    });
  });
}
