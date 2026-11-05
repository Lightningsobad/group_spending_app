import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

enum ExpenseCategoryType {
  food('FOOD', 'Food', 'Ăn uống', LucideIcons.utensils, Color(0xFFF59E0B)),
  transport('TRANSPORT', 'Transport', 'Di chuyển', LucideIcons.car, Color(0xFF3B82F6)),
  shopping('SHOPPING', 'Shopping', 'Mua sắm', LucideIcons.shoppingBag, Color(0xFFA855F7)),
  housing('HOUSING', 'Housing', 'Nhà ở & Điện nước', LucideIcons.house, Color(0xFF10B981)),
  entertainment('ENTERTAIMENT', 'Entertaiment', 'Giải trí', LucideIcons.clapperboard, Color(0xFFEC4899)),
  groceries('GROCERISE', 'Grocerise', 'Siêu thị', LucideIcons.shoppingCart, Color(0xFFF97316)),
  healthcare('HEALTHCARE', 'Healthcare', 'Y tế & Sức khỏe', LucideIcons.heartPulse, Color(0xFFEF4444)),
  others('OTHERS', 'Others', 'Khác', LucideIcons.ellipsis, Color(0xFF64748B));

  final String key;
  final String apiValue;
  final String labelVi;
  final IconData icon;
  final Color themeColor;

  const ExpenseCategoryType(
    this.key,
    this.apiValue,
    this.labelVi,
    this.icon,
    this.themeColor,
  );

  static ExpenseCategoryType fromString(String? val) {
    if (val == null || val.trim().isEmpty) return ExpenseCategoryType.others;
    final normalized = val.trim().toUpperCase();

    for (final cat in ExpenseCategoryType.values) {
      if (cat.key == normalized ||
          cat.apiValue.toUpperCase() == normalized ||
          cat.labelVi.toUpperCase() == normalized) {
        return cat;
      }
    }
    // Tolerant matching
    if (normalized.contains('FOOD') || normalized.contains('UONG') || normalized.contains('AN')) {
      return ExpenseCategoryType.food;
    }
    if (normalized.contains('TRANS') || normalized.contains('CHUYEN') || normalized.contains('XE')) {
      return ExpenseCategoryType.transport;
    }
    if (normalized.contains('SHOP') || normalized.contains('SAM')) {
      return ExpenseCategoryType.shopping;
    }
    if (normalized.contains('HOUSE') || normalized.contains('NHA') || normalized.contains('HOUSING')) {
      return ExpenseCategoryType.housing;
    }
    if (normalized.contains('ENTER') || normalized.contains('TRI') || normalized.contains('GAME')) {
      return ExpenseCategoryType.entertainment;
    }
    if (normalized.contains('GROC') || normalized.contains('THI') || normalized.contains('MARKET')) {
      return ExpenseCategoryType.groceries;
    }
    if (normalized.contains('HEALTH') || normalized.contains('TE') || normalized.contains('THUOC')) {
      return ExpenseCategoryType.healthcare;
    }

    return ExpenseCategoryType.others;
  }
}

extension ExpenseCategoryTypeL10n on ExpenseCategoryType {
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpenseCategoryType.food:
        return l10n.categoryFood;
      case ExpenseCategoryType.transport:
        return l10n.categoryTransport;
      case ExpenseCategoryType.shopping:
        return l10n.categoryShopping;
      case ExpenseCategoryType.housing:
        return l10n.categoryHousing;
      case ExpenseCategoryType.entertainment:
        return l10n.categoryEntertainment;
      case ExpenseCategoryType.groceries:
        return l10n.categoryGroceries;
      case ExpenseCategoryType.healthcare:
        return l10n.categoryHealthcare;
      case ExpenseCategoryType.others:
        return l10n.categoryOthers;
    }
  }
}

enum SplitOption {
  equalAll('EQUAL_ALL', 'Chia đều cho tất cả thành viên'),
  equalSelected('EQUAL_SELECTED', 'Chia đều cho các thành viên được chọn');

  final String key;
  final String label;
  const SplitOption(this.key, this.label);

  static SplitOption fromString(String? val) {
    if (val == 'EQUAL_SELECTED') return SplitOption.equalSelected;
    return SplitOption.equalAll;
  }
}

enum ExpenseTimeFilter {
  all('ALL', 'Tất cả'),
  thisMonth('THIS_MONTH', 'Tháng này'),
  lastMonth('LAST_MONTH', 'Tháng trước'),
  thisQuarter('THIS_QUARTER', 'Quý này'),
  thisYear('THIS_YEAR', 'Năm nay');

  final String key;
  final String label;
  const ExpenseTimeFilter(this.key, this.label);
}

enum ExpensePayerFilter {
  all('ALL', 'Tất cả'),
  paidByMe('PAID_BY_ME', 'Của tôi'),
  paidByOthers('PAID_BY_OTHERS', 'Chờ quyết toán');

  final String key;
  final String label;
  const ExpensePayerFilter(this.key, this.label);
}

enum ExpenseCategoryFilter {
  all('ALL', 'Tất cả chủ đề'),
  food('FOOD', 'Ăn uống'),
  transport('TRANSPORT', 'Di chuyển'),
  shopping('SHOPPING', 'Mua sắm'),
  housing('HOUSING', 'Nhà ở & Điện nước'),
  entertainment('ENTERTAIMENT', 'Giải trí'),
  groceries('GROCERISE', 'Siêu thị'),
  healthcare('HEALTHCARE', 'Y tế & Sức khỏe'),
  others('OTHERS', 'Khác');

  final String key;
  final String label;
  const ExpenseCategoryFilter(this.key, this.label);
}

enum ExpenseStatus {
  active('ACTIVE', 'Đang hoạt động'),
  deleted('DELETED', 'Đã xóa'),
  pendingSettlement('PENDING_SETTLEMENT', 'Chờ quyết toán'),
  settled('SETTLED', 'Đã tất toán');

  final String key;
  final String label;
  const ExpenseStatus(this.key, this.label);

  static ExpenseStatus fromString(String? val) {
    for (final s in ExpenseStatus.values) {
      if (s.key == val?.toUpperCase()) return s;
    }
    return ExpenseStatus.active;
  }
}

enum ExpenseSplitStatus {
  paid('PAID', 'Đã trả', Color(0xFF10B981), Color(0xFFDCFCE7)),
  unpaid('UNPAID', 'Chưa trả', Color(0xFFEF4444), Color(0xFFFEE2E2)),
  pendingApproval('PENDING_APPROVAL', 'Chờ duyệt', Color(0xFFD97706), Color(0xFFFEF3C7));

  final String key;
  final String label;
  final Color textColor;
  final Color bgColor;

  const ExpenseSplitStatus(this.key, this.label, this.textColor, this.bgColor);

  Color resolveBgColor(AppThemeColors colors) {
    switch (this) {
      case ExpenseSplitStatus.paid:
        return colors.expenseSplitPaidBg;
      case ExpenseSplitStatus.unpaid:
        return colors.expenseSplitUnpaidBg;
      case ExpenseSplitStatus.pendingApproval:
        return colors.expenseSplitPendingBg;
    }
  }

  Color resolveTextColor(AppThemeColors colors) {
    switch (this) {
      case ExpenseSplitStatus.paid:
        return colors.expenseSplitPaidText;
      case ExpenseSplitStatus.unpaid:
        return colors.expenseSplitUnpaidText;
      case ExpenseSplitStatus.pendingApproval:
        return colors.expenseSplitPendingText;
    }
  }

  static ExpenseSplitStatus fromString(String? val, {bool? isPaid}) {
    if (isPaid == true) return ExpenseSplitStatus.paid;
    if (val == null) return ExpenseSplitStatus.unpaid;
    final normalized = val.trim().toUpperCase();
    if (normalized == 'PAID' || normalized.contains('ĐÃ') || normalized.contains('DA')) {
      return ExpenseSplitStatus.paid;
    }
    if (normalized.contains('PENDING') || normalized.contains('CHỜ') || normalized.contains('DUYET')) {
      return ExpenseSplitStatus.pendingApproval;
    }
    return ExpenseSplitStatus.unpaid;
  }
}
