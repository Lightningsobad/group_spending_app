import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeCubit Tests', () {
    test('initializes with light mode by default', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await AppPreferences.init();
      final cubit = ThemeCubit(prefs);

      expect(cubit.state, equals(ThemeMode.light));
      expect(cubit.isDarkMode, isFalse);
    });

    test('initializes with dark mode when saved in preferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await AppPreferences.init();
      final cubit = ThemeCubit(prefs);

      expect(cubit.state, equals(ThemeMode.dark));
      expect(cubit.isDarkMode, isTrue);
    });

    test('toggleTheme switches between light and dark and persists to preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await AppPreferences.init();
      final cubit = ThemeCubit(prefs);

      await cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.dark));
      expect(prefs.getThemeMode(), equals('dark'));

      await cubit.toggleTheme();
      expect(cubit.state, equals(ThemeMode.light));
      expect(prefs.getThemeMode(), equals('light'));
    });
  });
}
