import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/expense_note_editor_sheet.dart';
import 'package:group_spending_app/features/expenses/presentation/widgets/expense_note_input_field.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  Widget buildTestableWidget({
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ExpenseNoteInputField(
            controller: controller,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('ExpenseNoteInputField Tests', () {
    testWidgets('renders default UI elements: label, optional tag, expand button, and text field', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(buildTestableWidget(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('GHI CHÚ'), findsOneWidget);
      expect(find.text('Tùy chọn'), findsOneWidget);
      expect(find.text('Mở rộng'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.minLines, 2);
      expect(textField.maxLines, 5);
      expect(find.textContaining('Xem toàn bộ'), findsNothing);
    });

    testWidgets('shows view all hint when text has more than 5 lines', (tester) async {
      final controller = TextEditingController(text: 'Dòng 1\nDòng 2\nDòng 3\nDòng 4\nDòng 5\nDòng 6');

      await tester.pumpWidget(buildTestableWidget(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Xem toàn bộ (6 dòng)...'), findsOneWidget);
    });

    testWidgets('tapping Mở rộng opens ExpenseNoteEditorSheet and updates text on Done', (tester) async {
      final controller = TextEditingController(text: 'Nội dung ban đầu');
      String? changedValue;

      await tester.pumpWidget(
        buildTestableWidget(
          controller: controller,
          onChanged: (val) => changedValue = val,
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Mở rộng"
      await tester.tap(find.text('Mở rộng'));
      await tester.pumpAndSettle();

      // BottomSheet should be visible
      expect(find.byType(ExpenseNoteEditorSheet), findsOneWidget);
      expect(find.text('Ghi chú chi tiêu'), findsOneWidget);

      // Edit text in sheet
      final sheetTextField = find.descendant(
        of: find.byType(ExpenseNoteEditorSheet),
        matching: find.byType(TextField),
      );
      expect(sheetTextField, findsOneWidget);
      await tester.enterText(sheetTextField, 'Nội dung đã được chỉnh sửa');
      await tester.pumpAndSettle();

      // Tap "Xong"
      await tester.tap(find.text('Xong'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(ExpenseNoteEditorSheet), findsNothing);
      expect(controller.text, 'Nội dung đã được chỉnh sửa');
      expect(changedValue, 'Nội dung đã được chỉnh sửa');
    });

    testWidgets('ExpenseNoteEditorSheet clear button empties text field', (tester) async {
      final controller = TextEditingController(text: 'Hóa đơn quán cà phê\n3 ly latte');

      await tester.pumpWidget(buildTestableWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mở rộng'));
      await tester.pumpAndSettle();

      // Find trash icon in sheet header
      final trashIcon = find.descendant(
        of: find.byType(ExpenseNoteEditorSheet),
        matching: find.byIcon(LucideIcons.trash2),
      );
      expect(trashIcon, findsOneWidget);

      await tester.tap(trashIcon);
      await tester.pumpAndSettle();

      // Check text is empty
      final sheetTextField = find.descendant(
        of: find.byType(ExpenseNoteEditorSheet),
        matching: find.byType(TextField),
      );
      final widget = tester.widget<TextField>(sheetTextField);
      expect(widget.controller?.text, '');
    });

    testWidgets('renders cleanly in dark theme without layout errors', (tester) async {
      final controller = TextEditingController(text: 'Ghi chú chế độ ban đêm\nThêm dòng 2');

      await tester.pumpWidget(
        buildTestableWidget(
          controller: controller,
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('GHI CHÚ'), findsOneWidget);
      expect(find.text('Mở rộng'), findsOneWidget);
    });
  });
}
