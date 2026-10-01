import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/core/errors/app_exception.dart';
import 'package:group_spending_app/features/settings/data/models/vietqr_bank_model.dart';
import 'package:group_spending_app/features/settings/data/services/vietqr_bank_service.dart';
import 'package:group_spending_app/features/settings/presentation/widgets/bank_picker_bottom_sheet.dart';
import 'package:group_spending_app/l10n/app_localizations.dart';

class _MockVietQrBankService implements VietQrBankService {
  final List<VietQrBankModel> banks;
  final bool shouldFail;

  _MockVietQrBankService({this.banks = const [], this.shouldFail = false});

  @override
  Future<List<VietQrBankModel>> getBanks() async {
    if (shouldFail) {
      throw const AppException(message: 'Không thể kết nối đến máy chủ VietQR.');
    }
    return banks;
  }
}

void main() {
  const sampleBanks = [
    VietQrBankModel(
      id: 1,
      name: 'Ngân hàng Ngoại thương Việt Nam',
      code: 'VCB',
      bin: '970436',
      shortName: 'Vietcombank',
      logo: '',
    ),
    VietQrBankModel(
      id: 2,
      name: 'Ngân hàng Quân đội',
      code: 'MB',
      bin: '970422',
      shortName: 'MBBank',
      logo: '',
    ),
  ];

  Widget buildWidget(VietQrBankService service) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      home: Scaffold(
        body: BankPickerBottomSheet(bankService: service),
      ),
    );
  }

  group('BankPickerBottomSheet Widget Tests', () {
    testWidgets('renders bank list and allows filtering', (tester) async {
      final service = _MockVietQrBankService(banks: sampleBanks);
      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      expect(find.text('Chọn ngân hàng'), findsOneWidget);
      expect(find.text('Vietcombank'), findsOneWidget);
      expect(find.text('MBBank'), findsOneWidget);

      // Search for MBBank
      await tester.enterText(find.byType(TextField), 'MBBank');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Vietcombank'), findsNothing);
      expect(find.widgetWithText(ListTile, 'MBBank'), findsOneWidget);
    });

    testWidgets('shows error view when service fails with no fallback', (tester) async {
      final service = _MockVietQrBankService(shouldFail: true);
      await tester.pumpWidget(buildWidget(service));
      await tester.pumpAndSettle();

      expect(find.text('Không thể kết nối đến máy chủ VietQR.'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
    });
  });
}
