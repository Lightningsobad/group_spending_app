import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/l10n/locale_cubit.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleCubit Tests', () {
    test('initializes with Vietnamese by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await AppPreferences.init();
      final cubit = LocaleCubit(prefs);

      expect(cubit.state, equals(const Locale('vi')));
      expect(cubit.isVietnamese, isTrue);
    });

    test('initializes with English when saved in preferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await AppPreferences.init();
      final cubit = LocaleCubit(prefs);

      expect(cubit.state, equals(const Locale('en')));
      expect(cubit.isEnglish, isTrue);
    });

    test('toggleLocale switches between vi and en and persists to preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await AppPreferences.init();
      final cubit = LocaleCubit(prefs);

      await cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('en')));
      expect(prefs.getAppLocale(), equals('en'));

      await cubit.toggleLocale();
      expect(cubit.state, equals(const Locale('vi')));
      expect(prefs.getAppLocale(), equals('vi'));
    });
  });
}
