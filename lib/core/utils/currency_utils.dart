import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static final NumberFormat _viNumberFormat = NumberFormat('#,###', 'vi_VN');

  static String formatVnd(num amount, {bool showSign = false}) {
    final absAmount = amount.abs().round();
    final formatted = _viNumberFormat.format(absAmount);

    if (amount > 0) {
      return showSign ? '+$formatted đ' : '$formatted đ';
    } else if (amount < 0) {
      return '-$formatted đ';
    } else {
      return '0 đ';
    }
  }
}
