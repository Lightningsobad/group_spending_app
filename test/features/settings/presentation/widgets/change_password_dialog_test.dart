import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/core/l10n/locale_cubit.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/theme/app_theme.dart';
import 'package:group_spending_app/core/theme/theme_cubit.dart';
import 'package:group_spending_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/change_password_dialog.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/cubit/auth_cubit_test.dart';

class MockChangePasswordAuthRepository extends FakeAuthRepository {
  String? lastOldPassword;
  String? lastNewPassword;
  int changePasswordCallCount = 0;

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    changePasswordCallCount++;
    lastOldPassword = oldPassword;
    lastNewPassword = newPassword;
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }
}

void main() {
  group('ChangePasswordDialog Widget Tests', () {
    late AppPreferences prefs;
    late ThemeCubit themeCubit;
    late LocaleCubit localeCubit;
    late MockChangePasswordAuthRepository fakeRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await AppPreferences.init();
      themeCubit = ThemeCubit(prefs);
      localeCubit = LocaleCubit(prefs);
      fakeRepo = MockChangePasswordAuthRepository();
    });

    Widget createWidgetUnderTest({VoidCallback? onSuccess}) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
          RepositoryProvider<AuthRepository>.value(value: fakeRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: MaterialApp(
            locale: const Locale('vi'),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => ChangePasswordDialog.show(
                      context,
                      authRepository: fakeRepo,
                      onSuccess: onSuccess,
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders dialog elements matching design mockup', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Open Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Đổi mật khẩu tài khoản'), findsOneWidget);
      expect(find.text('Cập nhật mật khẩu để bảo vệ an toàn cho tài khoản'), findsOneWidget);
      expect(find.byIcon(LucideIcons.keyRound), findsOneWidget);
      expect(find.byIcon(LucideIcons.x), findsOneWidget);

      // Labels and Placeholders
      expect(find.text('Nhập mật khẩu đang dùng'), findsOneWidget);
      expect(find.text('Tối thiểu 6 ký tự'), findsOneWidget);
      expect(find.text('Nhập lại mật khẩu mới'), findsOneWidget);

      // Tip Box
      expect(
        find.text('Gợi ý: Sử dụng mật khẩu kết hợp chữ hoa, chữ thường và chữ số để tăng độ an toàn.'),
        findsOneWidget,
      );

      // Buttons
      expect(find.text('Hủy'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.byIcon(LucideIcons.check), findsOneWidget);
    });

    testWidgets('closing dialog via Hủy or X button dismisses without submit', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Open and click Hủy
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordDialog), findsNothing);
      expect(fakeRepo.changePasswordCallCount, 0);

      // Open and click X
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.x));
      await tester.pumpAndSettle();
      expect(find.byType(ChangePasswordDialog), findsNothing);
      expect(fakeRepo.changePasswordCallCount, 0);
    });

    testWidgets('validates required and minimum length fields', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap submit with all empty
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập mật khẩu hiện tại.'), findsOneWidget);
      expect(fakeRepo.changePasswordCallCount, 0);

      // Fill current password, but enter short new password (< 6 chars)
      await tester.enterText(find.byType(TextFormField).at(0), 'oldpass123');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.enterText(find.byType(TextFormField).at(2), '12345');
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu phải có ít nhất 6 ký tự.'), findsOneWidget);
      expect(fakeRepo.changePasswordCallCount, 0);

      // New password same as current password
      await tester.enterText(find.byType(TextFormField).at(1), 'oldpass123');
      await tester.enterText(find.byType(TextFormField).at(2), 'oldpass123');
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu mới không được trùng với mật khẩu hiện tại.'), findsOneWidget);
      expect(fakeRepo.changePasswordCallCount, 0);

      // Confirm password mismatch
      await tester.enterText(find.byType(TextFormField).at(1), 'newsecret123');
      await tester.enterText(find.byType(TextFormField).at(2), 'differentpass123');
      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp.'), findsOneWidget);
      expect(fakeRepo.changePasswordCallCount, 0);
    });

    testWidgets('successful submission calls repository and shows success SnackBar', (tester) async {
      bool successCallbackCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(onSuccess: () {
        successCallbackCalled = true;
      }));

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Enter valid fields
      await tester.enterText(find.byType(TextFormField).at(0), 'currentPass123');
      await tester.enterText(find.byType(TextFormField).at(1), 'newSecretPass456');
      await tester.enterText(find.byType(TextFormField).at(2), 'newSecretPass456');

      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      expect(fakeRepo.changePasswordCallCount, 1);
      expect(fakeRepo.lastOldPassword, 'currentPass123');
      expect(fakeRepo.lastNewPassword, 'newSecretPass456');
      expect(successCallbackCalled, isTrue);

      // Dialog dismissed
      expect(find.byType(ChangePasswordDialog), findsNothing);

      // Success SnackBar shown
      expect(find.text('Đổi mật khẩu thành công!'), findsOneWidget);
    });

    testWidgets('displays server error banner on AppException (e.g. wrong old password)', (tester) async {
      fakeRepo.exceptionToThrow = const AppException(
        message: 'Mật khẩu cũ không chính xác',
        statusCode: 400,
      );

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'wrongOldPass');
      await tester.enterText(find.byType(TextFormField).at(1), 'newPass123');
      await tester.enterText(find.byType(TextFormField).at(2), 'newPass123');

      await tester.tap(find.text('Đổi mật khẩu'));
      await tester.pumpAndSettle();

      // Dialog is still displayed
      expect(find.byType(ChangePasswordDialog), findsOneWidget);

      // Error message rendered in error banner
      expect(find.text('Mật khẩu cũ không chính xác'), findsOneWidget);
      expect(find.byIcon(LucideIcons.alertCircle), findsOneWidget);
    });
  });
}
