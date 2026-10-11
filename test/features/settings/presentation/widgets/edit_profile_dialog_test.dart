import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/auth/domain/entities/user_entity.dart';
import 'package:group_spending_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/edit_profile_dialog.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit_test.dart';

void main() {
  const initialUser = UserEntity(
    id: 1,
    email: 'user@example.com',
    fullName: 'Nguyễn Văn A',
    phone: '0987654321',
    role: 'ROLE_USER',
    isEmailVerified: true,
    bankName: 'MBBank',
    bankAccountNumber: '123456789',
    bankAccountName: 'NGUYEN VAN A',
  );

  Widget buildWidget({
    required AuthCubit cubit,
    VoidCallback? onSuccess,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: Scaffold(
        body: BlocProvider<AuthCubit>.value(
          value: cubit,
          child: EditProfileDialog(
            authCubit: cubit,
            onSuccess: onSuccess,
          ),
        ),
      ),
    );
  }

  void setupScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('EditProfileDialog Widget Tests', () {
    late FakeAuthRepository fakeRepo;
    late AuthCubit authCubit;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      authCubit = AuthCubit(fakeRepo);
      authCubit.emit(authCubit.state.copyWith(currentUser: initialUser));
    });

    tearDown(() {
      authCubit.close();
    });

    testWidgets('renders fields with initial user data', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(buildWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      expect(find.text('Cập nhật thông tin cá nhân'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('0987654321'), findsOneWidget);
      expect(find.text('MBBank'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text('NGUYEN VAN A'), findsOneWidget);
      expect(find.text('Lưu thay đổi'), findsOneWidget);
    });

    testWidgets('validates required full name field', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(buildWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      // Clear full name
      final nameField = find.widgetWithText(TextFormField, 'Nguyễn Văn A');
      await tester.enterText(nameField, '');
      await tester.pumpAndSettle();

      // Tap Save
      final saveBtn = find.text('Lưu thay đổi');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Họ và tên không được để trống'), findsOneWidget);
    });

    testWidgets('submits update successfully and calls onSuccess', (tester) async {
      setupScreen(tester);
      bool successCalled = false;
      await tester.pumpWidget(buildWidget(
        cubit: authCubit,
        onSuccess: () => successCalled = true,
      ));
      await tester.pumpAndSettle();

      // Change name to "Nguyễn Văn B"
      final nameField = find.widgetWithText(TextFormField, 'Nguyễn Văn A');
      await tester.enterText(nameField, 'Nguyễn Văn B');
      await tester.pumpAndSettle();

      final saveBtn = find.text('Lưu thay đổi');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(successCalled, isTrue);
      expect(authCubit.state.currentUser?.fullName, 'Nguyễn Văn B');
    });

    testWidgets('displays error banner when repository throws exception', (tester) async {
      setupScreen(tester);
      fakeRepo.exceptionToThrow = const AppException(message: 'Số điện thoại không hợp lệ');

      await tester.pumpWidget(buildWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      final saveBtn = find.text('Lưu thay đổi');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Số điện thoại không hợp lệ'), findsOneWidget);
    });

    testWidgets('tapping clear bank button resets selected bank and account inputs', (tester) async {
      setupScreen(tester);
      await tester.pumpWidget(buildWidget(cubit: authCubit));
      await tester.pumpAndSettle();

      expect(find.text('MBBank'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
      expect(find.text('NGUYEN VAN A'), findsOneWidget);

      final clearBankBtn = find.byTooltip('Xóa liên kết ngân hàng');
      await tester.ensureVisible(clearBankBtn);
      await tester.tap(clearBankBtn);
      await tester.pumpAndSettle();

      expect(find.text('MBBank'), findsNothing);
      expect(find.text('Chọn ngân hàng từ danh sách'), findsOneWidget);
      expect(find.text('123456789'), findsNothing);
      expect(find.text('NGUYEN VAN A'), findsNothing);
    });
  });
}
