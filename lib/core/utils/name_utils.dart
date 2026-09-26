class NameUtils {
  NameUtils._();

  /// Lấy 2 chữ cái đầu tiên (Initials) cho avatar đại diện từ họ và tên:
  /// - "Nguyễn Nhật Minh" -> "NM" (Chữ đầu của Họ 'N' và chữ đầu của Tên 'M')
  /// - "Lê Văn" -> "LV"
  /// - "Minh" -> "MI" (2 ký tự đầu nếu chỉ có 1 từ)
  /// - "A" -> "A" (1 ký tự nếu tên 1 chữ cái)
  /// - null hoặc rỗng -> "FS" (FairShare fallback)
  static String getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'FS';
    }

    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'FS';
    }

    if (parts.length == 1) {
      final single = parts.first;
      return single.length >= 2
          ? single.substring(0, 2).toUpperCase()
          : single.toUpperCase();
    }

    final firstChar = parts.first.isNotEmpty ? parts.first[0] : '';
    final lastChar = parts.last.isNotEmpty ? parts.last[0] : '';
    final result = '$firstChar$lastChar'.toUpperCase();
    return result.isNotEmpty ? result : 'FS';
  }
}
