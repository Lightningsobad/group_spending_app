import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/core/theme/app_theme_colors.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/group_category_helper.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

void main() {
  group('GroupCategoryHelper Unit Tests', () {
    test('all categories have a valid Lucide icon', () {
      for (final cat in GroupCategoryHelper.categories) {
        final icon = GroupCategoryHelper.getIcon(cat);
        expect(icon, isA<IconData>());
      }

      expect(GroupCategoryHelper.getIcon('Apartment'), equals(LucideIcons.home));
      expect(GroupCategoryHelper.getIcon('Sport & Clubs'), equals(LucideIcons.trophy));
      expect(GroupCategoryHelper.getIcon('Travel & Trip'), equals(LucideIcons.plane));
      expect(GroupCategoryHelper.getIcon('Friends & Dining'), equals(LucideIcons.utensils));
      expect(GroupCategoryHelper.getIcon('Works & Project'), equals(LucideIcons.briefcase));
      expect(GroupCategoryHelper.getIcon('Other'), equals(LucideIcons.layoutGrid));
    });

    test('unknown category falls back to layoutGrid (Other)', () {
      final icon = GroupCategoryHelper.getIcon('Unknown_Random_Category');
      expect(icon, equals(LucideIcons.layoutGrid));
    });

    test('labels and shortLabels are defined for all categories', () {
      for (final cat in GroupCategoryHelper.categories) {
        expect(GroupCategoryHelper.getLabel(cat).isNotEmpty, isTrue);
        expect(GroupCategoryHelper.getShortLabel(cat).isNotEmpty, isTrue);
      }
      expect(GroupCategoryHelper.getLabel('Unknown'), equals('Khác'));
      expect(GroupCategoryHelper.getShortLabel('Unknown'), equals('Khác'));
    });
  });

  group('GroupCategoryHelper Widget Tests', () {
    testWidgets('buildIcon renders Icon widget with correct IconData and custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: GroupCategoryHelper.buildIcon(
              'Apartment',
              width: 32,
              height: 32,
              color: Colors.red,
            ),
          ),
        ),
      );

      final iconFinder = find.byType(Icon);
      expect(iconFinder, findsOneWidget);

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.icon, equals(LucideIcons.home));
      expect(iconWidget.size, equals(32));
      expect(iconWidget.color, equals(Colors.red));
    });

    testWidgets('buildCategoryBadge resolves colors dynamically from AppThemeColors in Light and Dark mode', (tester) async {
      // 1. Test Light Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => GroupCategoryHelper.buildCategoryBadge(
                context,
                'Sport & Clubs',
                size: 48,
              ),
            ),
          ),
        ),
      );

      final lightBadgeContainer = tester.widget<Container>(find.byType(Container).first);
      final lightBoxDecoration = lightBadgeContainer.decoration as BoxDecoration;
      expect(lightBoxDecoration.color, equals(AppThemeColors.light.topicSportBg));

      final lightIconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(lightIconWidget.icon, equals(LucideIcons.trophy));
      expect(lightIconWidget.color, equals(AppThemeColors.light.topicSport));

      // 2. Test Dark Mode
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => GroupCategoryHelper.buildCategoryBadge(
                context,
                'Sport & Clubs',
                size: 48,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final darkBadgeContainer = tester.widget<Container>(find.byType(Container).first);
      final darkBoxDecoration = darkBadgeContainer.decoration as BoxDecoration;
      expect(darkBoxDecoration.color, equals(AppThemeColors.dark.topicSportBg));

      final darkIconWidget = tester.widget<Icon>(find.byType(Icon));
      expect(darkIconWidget.icon, equals(LucideIcons.trophy));
      expect(darkIconWidget.color, equals(AppThemeColors.dark.topicSport));
    });

    testWidgets('getLabel and getShortLabel return localized strings for vi and en locales', (tester) async {
      late BuildContext viContext;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('vi'),
          home: Builder(
            builder: (ctx) {
              viContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(GroupCategoryHelper.getLabel('Apartment', viContext), equals('Căn hộ & Phòng trọ'));
      expect(GroupCategoryHelper.getShortLabel('Apartment', viContext), equals('Căn hộ chung'));
      expect(GroupCategoryHelper.getLabel('Sport & Clubs', viContext), equals('Thể thao & CLB'));

      late BuildContext enContext;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (ctx) {
              enContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(GroupCategoryHelper.getLabel('Apartment', enContext), equals('Apartment & Housing'));
      expect(GroupCategoryHelper.getShortLabel('Apartment', enContext), equals('Apartment'));
      expect(GroupCategoryHelper.getLabel('Sport & Clubs', enContext), equals('Sports & Clubs'));
    });
  });
}
