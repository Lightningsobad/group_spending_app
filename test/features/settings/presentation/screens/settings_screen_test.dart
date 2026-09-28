import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/l10n/locale_cubit.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:group_spending_app/core/storage/app_preferences.dart';
import 'package:group_spending_app/core/theme/theme_cubit.dart';
import 'package:group_spending_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:group_spending_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/appearance_language_card.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/change_password_dialog.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/logout_button.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/payment_account_card.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/support_info_card.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/user_profile_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/cubit/auth_cubit_test.dart';

void main() {
  group('SettingsScreen Tests', () {
    late AppPreferences prefs;
    late ThemeCubit themeCubit;
    late LocaleCubit localeCubit;
    late FakeAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'user_full_name': 'Nguyễn Nhật Minh',
        'user_email': 'minh.nguyen@example.com',
      });
      prefs = await AppPreferences.init();
      themeCubit = ThemeCubit(prefs);
      localeCubit = LocaleCubit(prefs);
      fakeRepo = FakeAuthRepository();
      authCubit = AuthCubit(fakeRepo);
    });

    Widget createWidgetUnderTest() {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AppPreferences>.value(value: prefs),
          RepositoryProvider<AuthRepository>.value(value: fakeRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<LocaleCubit>.value(value: localeCubit),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp(
                    themeMode: themeMode,
                    locale: locale,
                    localizationsDelegates: AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: const Scaffold(body: SettingsScreen()),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    testWidgets('renders all sub-widgets properly according to design', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Header title
      expect(find.text('Cài đặt'), findsOneWidget);

      // Sub-widgets presence
      expect(find.byType(UserProfileCard), findsOneWidget);
      expect(find.byType(PaymentAccountCard), findsOneWidget);
      expect(find.byType(AppearanceLanguageCard), findsOneWidget);
      expect(find.byType(SupportInfoCard), findsOneWidget);
      expect(find.byType(LogoutButton), findsOneWidget);

      // UserProfileCard details (role badge is temporarily hidden)
      expect(find.text('Nguyễn Nhật Minh'), findsOneWidget);
      expect(find.text('Trưởng nhóm (Admin)'), findsNothing);
      expect(find.text('minh.nguyen@example.com'), findsOneWidget);
      expect(find.text('Sửa thông tin'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);

      // PaymentAccountCard details
      expect(find.text('TÀI KHOẢN NHẬN TIỀN NỢ (VIETQR)'), findsOneWidget);
      expect(find.text('Techcombank - 19034829104018'), findsOneWidget);
      expect(find.text('NGUYEN NHAT MINH'), findsOneWidget);

      // AppearanceLanguageCard details
      expect(find.text('GIAO DIỆN & NGÔN NGỮ'), findsOneWidget);
      expect(find.text('Chế độ giao diện (Theme)'), findsOneWidget);
      expect(find.text('Ngôn ngữ hiển thị'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('VN VI'), findsOneWidget);
      expect(find.text('GB EN'), findsOneWidget);

      // SupportInfoCard details
      expect(find.text('THÔNG TIN & HỖ TRỢ'), findsOneWidget);
      expect(find.text('Giới thiệu về FairShare'), findsOneWidget);
      expect(find.text('Chính sách bảo mật & Quyền riêng tư'), findsOneWidget);

      // Logout button
      expect(find.text('Đăng xuất tài khoản'), findsOneWidget);
    });

    testWidgets('segmented controls change theme and language', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Switch to Dark Mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(themeCubit.isDarkMode, isTrue);

      // Switch to English
      await tester.tap(find.text('GB EN'));
      await tester.pumpAndSettle();
      expect(localeCubit.isEnglish, isTrue);

      // Check text changed to English
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('APPEARANCE & LANGUAGE'), findsOneWidget);
      expect(find.text('Log out account'), findsOneWidget);
    });

    testWidgets('tapping LogoutButton triggers auth logout', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final logoutBtn = find.text('Đăng xuất tài khoản');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(authCubit.state.status, equals(AuthStatus.unauthenticated));
    });

    testWidgets('tapping Đổi mật khẩu opens ChangePasswordDialog', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final changePasswordBtn = find.text('Đổi mật khẩu');
      await tester.ensureVisible(changePasswordBtn);
      await tester.tap(changePasswordBtn);
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordDialog), findsOneWidget);
      expect(find.text('Đổi mật khẩu tài khoản'), findsOneWidget);
    });
  });
}
