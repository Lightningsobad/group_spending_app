import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/theme/app_theme_colors.dart';
import 'package:group_spending_app/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/privacy_policy_view.dart';
import 'package:group_spending_app/l10n/l10n.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  group('PrivacyPolicyView Tests', () {
    Widget buildTestWidget({
      Locale locale = const Locale('vi'),
      ThemeMode themeMode = ThemeMode.light,
      VoidCallback? onBack,
    }) {
      return MaterialApp(
        locale: locale,
        themeMode: themeMode,
        theme: ThemeData.light().copyWith(
          extensions: const [AppThemeColors.light],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: const [AppThemeColors.dark],
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PrivacyPolicyView(
            onBack: onBack ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders all 4 sections, hero banner and CTA in Vietnamese', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Top title and subtitle
      expect(find.text('Chính sách bảo mật & Quyền riêng tư'), findsOneWidget);
      expect(find.text('Cam kết bảo vệ dữ liệu cá nhân & an toàn tài chính'), findsOneWidget);

      // Hero banner
      expect(find.text('BẢO MẬT TIÊU CHUẨN'), findsOneWidget);
      expect(find.text('Cập nhật: Tháng 09/2026'), findsOneWidget);
      expect(find.text('Minh bạch thu chi • Bảo mật dữ liệu người dùng'), findsOneWidget);

      // Section 1
      expect(find.text('1. DỮ LIỆU ỨNG DỤNG THU THẬP'), findsOneWidget);
      expect(
        find.text('Chúng tôi chỉ thu thập các trường thông tin tối thiểu cần thiết để vận hành các tính năng chia tiền nhóm:'),
        findsOneWidget,
      );

      // Section 2
      expect(find.text('2. AN TOÀN MẬT KHẨU & MÃ HÓA ĐẦU CUỐI'), findsOneWidget);
      expect(
        find.textContaining('Mật khẩu tài khoản của người dùng được băm một chiều'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Bạn có thể tự chủ động thay đổi mật khẩu'),
        findsOneWidget,
      );

      // Section 3
      expect(find.text('3. CAM KẾT KHÔNG CHIA SẺ DỮ LIỆU'), findsOneWidget);
      expect(
        find.textContaining('FairShare cam kết không bán, chia sẻ hoặc thương mại hóa'),
        findsOneWidget,
      );

      // Section 4
      expect(find.text('4. QUYỀN LÀM CHỦ DỮ LIỆU CỦA BẠN'), findsOneWidget);
      expect(find.text('Xem và chỉnh sửa họ tên, thông tin tài khoản ngân hàng bất kỳ lúc nào.'), findsOneWidget);
      expect(find.text('Chuyển quyền Quản trị viên (Admin) cho thành viên khác trong nhóm.'), findsOneWidget);
      expect(find.text('Yêu cầu xóa nhóm hoặc đóng băng lịch sử chi tiêu bằng cách đưa vào Lưu trữ.'), findsOneWidget);
      expect(find.text('Đăng xuất an toàn khỏi thiết bị bất cứ khi nào bạn muốn.'), findsOneWidget);

      // Bottom back CTA
      expect(find.text('Quay lại Cài đặt'), findsOneWidget);
    });

    testWidgets('renders all content properly in English', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy & Data Safety'), findsOneWidget);
      expect(find.text('Commitment to personal data protection & financial safety'), findsOneWidget);
      expect(find.text('STANDARD SECURITY'), findsOneWidget);
      expect(find.text('Updated: September 2026'), findsOneWidget);
      expect(find.text('Expense Transparency • User Data Protection'), findsOneWidget);
      expect(find.text('1. DATA COLLECTED BY APP'), findsOneWidget);
      expect(find.text('2. PASSWORD SAFETY & END-TO-END ENCRYPTION'), findsOneWidget);
      expect(find.text('3. NO DATA SHARING COMMITMENT'), findsOneWidget);
      expect(find.text('4. YOUR DATA OWNERSHIP RIGHTS'), findsOneWidget);
      expect(find.text('Back to Settings'), findsOneWidget);
    });

    testWidgets('renders properly in Dark mode without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('Chính sách bảo mật & Quyền riêng tư'), findsOneWidget);
      expect(find.text('Quay lại Cài đặt'), findsOneWidget);
    });

    testWidgets('triggers onBack when top back button is tapped', (tester) async {
      bool backCalled = false;
      await tester.pumpWidget(buildTestWidget(onBack: () => backCalled = true));
      await tester.pumpAndSettle();

      final topBackBtn = find.byIcon(LucideIcons.arrowLeft).first;
      await tester.tap(topBackBtn);
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('triggers onBack when bottom button is tapped', (tester) async {
      bool backCalled = false;
      await tester.pumpWidget(buildTestWidget(onBack: () => backCalled = true));
      await tester.pumpAndSettle();

      final bottomBtn = find.text('Quay lại Cài đặt');
      await tester.ensureVisible(bottomBtn);
      await tester.tap(bottomBtn);
      await tester.pumpAndSettle();

      expect(backCalled, isTrue);
    });

    testWidgets('PrivacyPolicyScreen renders PrivacyPolicyView wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.light().copyWith(
            extensions: const [AppThemeColors.light],
          ),
          home: const PrivacyPolicyScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyView), findsOneWidget);
    });
  });
}
