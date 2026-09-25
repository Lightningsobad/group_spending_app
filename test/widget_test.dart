import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/storage/token_storage.dart';
import 'package:group_spending_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('FairShareApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await AppPreferences.init();
    final tokenStorage = TokenStorage();

    await tester.pumpWidget(
      FairShareApp(
        appPreferences: prefs,
        tokenStorage: tokenStorage,
      ),
    );

    // Verify FairShare title appears on splash screen
    expect(find.text('FairShare'), findsOneWidget);
    expect(
      find.text('Chia tiền minh bạch & nhắc nợ thông minh'),
      findsOneWidget,
    );
  });
}
