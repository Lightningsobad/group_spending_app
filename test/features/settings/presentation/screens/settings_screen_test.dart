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
import 'package:group_spending_app/features/settings/presentation/widgets/edit_profile_dialog.dart';
import 'package:group_spending_app/features/groups/presentation/widgets/viet_qr_modal_sheet.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/logout_button.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/payment_account_card.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/privacy_policy_view.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/support_info_card.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/user_profile_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
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
      expect(find.text('TÀI KHOẢN NGÂN HÀNG'), findsOneWidget);
      expect(find.text('Chưa có dữ liệu'), findsOneWidget);
      expect(find.text('Techcombank - 19034829104018'), findsNothing);
      expect(find.text('NGUYEN NHAT MINH'), findsNothing);

      // AppearanceLanguageCard details
      expect(find.text('GIAO DIỆN & NGÔN NGỮ'), findsOneWidget);
      expect(find.text('Chế độ giao diện'), findsOneWidget);
      expect(find.text('Ngôn ngữ'), findsOneWidget);
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

    testWidgets('tapping LogoutButton shows confirmation dialog; canceling preserves session', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final logoutBtn = find.text('Đăng xuất tài khoản');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn đăng xuất?'), findsOneWidget);

      // Tap Cancel
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(authCubit.state.status, equals(AuthStatus.initial));
    });

    testWidgets('confirming logout in dialog triggers auth logout', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final logoutBtn = find.text('Đăng xuất tài khoản');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Find the confirm button inside the AlertDialog
      final confirmBtn = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(ElevatedButton, 'Đăng xuất tài khoản'),
      );
      await tester.tap(confirmBtn);
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

    testWidgets('tapping Privacy Policy opens PrivacyPolicyView, and tapping bottom button returns to settings', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap Privacy Policy
      final privacyTile = find.text('Chính sách bảo mật & Quyền riêng tư');
      await tester.ensureVisible(privacyTile);
      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      // Check PrivacyPolicyView is visible
      expect(find.byType(PrivacyPolicyView), findsOneWidget);
      expect(find.text('BẢO MẬT TIÊU CHUẨN'), findsOneWidget);
      expect(find.text('Minh bạch thu chi • Bảo mật dữ liệu người dùng'), findsOneWidget);
      expect(find.text('1. DỮ LIỆU ỨNG DỤNG THU THẬP'), findsOneWidget);
      expect(find.text('2. AN TOÀN MẬT KHẨU & MÃ HÓA ĐẦU CUỐI'), findsOneWidget);
      expect(find.text('3. CAM KẾT KHÔNG CHIA SẺ DỮ LIỆU'), findsOneWidget);
      expect(find.text('4. QUYỀN LÀM CHỦ DỮ LIỆU CỦA BẠN'), findsOneWidget);
      expect(find.text('Quay lại Cài đặt'), findsOneWidget);

      // Tap bottom "Quay lại Cài đặt" button
      final bottomBackBtn = find.text('Quay lại Cài đặt');
      await tester.ensureVisible(bottomBackBtn);
      await tester.tap(bottomBackBtn);
      await tester.pumpAndSettle();

      // Settings screen should be visible again
      expect(find.byType(PrivacyPolicyView), findsNothing);
      expect(find.byType(UserProfileCard), findsOneWidget);
      expect(find.text('Cài đặt'), findsOneWidget);
    });

    testWidgets('tapping top back button in PrivacyPolicyView returns to settings', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final privacyTile = find.text('Chính sách bảo mật & Quyền riêng tư');
      await tester.ensureVisible(privacyTile);
      await tester.tap(privacyTile);
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyView), findsOneWidget);

      // Tap top back button (InkWell with LucideIcons.arrowLeft in PrivacyPolicyView)
      final topBackBtn = find.descendant(
        of: find.byType(PrivacyPolicyView),
        matching: find.byIcon(LucideIcons.arrowLeft),
      ).first;
      await tester.tap(topBackBtn);
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyView), findsNothing);
      expect(find.byType(UserProfileCard), findsOneWidget);
    });

    testWidgets('tapping Sửa thông tin opens EditProfileDialog', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final editProfileBtn = find.text('Sửa thông tin');
      await tester.ensureVisible(editProfileBtn);
      await tester.tap(editProfileBtn);
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileDialog), findsOneWidget);
      expect(find.text('Cập nhật thông tin cá nhân'), findsOneWidget);
    });

    testWidgets('tapping Sửa in PaymentAccountCard opens EditProfileDialog', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final editBankBtn = find.descendant(
        of: find.byType(PaymentAccountCard),
        matching: find.text('Chỉnh sửa'),
      );
      await tester.ensureVisible(editBankBtn);
      await tester.tap(editBankBtn);
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileDialog), findsOneWidget);
    });

    testWidgets('tapping PaymentAccountCard when user has bank info opens VietQrModalSheet', (tester) async {
      authCubit.emit(
        authCubit.state.copyWith(
          currentUser: fakeRepo.sampleUser.copyWith(
            bankName: 'MBBank',
            bankAccountNumber: '9876543210',
            bankAccountName: 'NGUYEN NHAT MINH',
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('MBBank - 9876543210'), findsOneWidget);

      final paymentCard = find.byType(PaymentAccountCard);
      await tester.ensureVisible(paymentCard);
      await tester.tap(paymentCard);
      await tester.pumpAndSettle();

      expect(find.byType(VietQrModalSheet), findsOneWidget);
      expect(find.text('Mã VietQR'), findsOneWidget);
    });

    testWidgets('tapping PaymentAccountCard when user has no bank info opens EditProfileDialog', (tester) async {
      authCubit.emit(
        authCubit.state.copyWith(
          currentUser: fakeRepo.sampleUser.copyWith(
            bankName: null,
            bankAccountNumber: null,
          ),
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Chưa có dữ liệu'), findsOneWidget);

      final paymentCard = find.byType(PaymentAccountCard);
      await tester.ensureVisible(paymentCard);
      await tester.tap(paymentCard);
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileDialog), findsOneWidget);
    });
  });
}
