import 'dart:convert';

class InviteCodeParser {
  InviteCodeParser._();

  /// Trích xuất mã mời (inviteCode) từ chuỗi quét được từ mã QR hoặc văn bản.
  /// Hỗ trợ cả URL, deep link, JSON và chuỗi mã thô.
  static String? extract(String? rawInput) {
    if (rawInput == null) return null;
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    // 1. Kiểm tra URL hoặc Custom URI Scheme (ví dụ: https://... hoặc groupspending://...)
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      // 1.1 Tìm theo query parameter: inviteCode hoặc code
      if (uri.queryParameters.containsKey('inviteCode')) {
        final code = uri.queryParameters['inviteCode']?.trim();
        if (code != null && code.isNotEmpty) return code;
      }
      if (uri.queryParameters.containsKey('code')) {
        final code = uri.queryParameters['code']?.trim();
        if (code != null && code.isNotEmpty) return code;
      }

      // 1.2 Tìm theo path (ví dụ: .../join/634636 hoặc .../invite/634636)
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        if (segments.length >= 2) {
          final prevSegment = segments[segments.length - 2].toLowerCase();
          if (prevSegment == 'join' || prevSegment == 'invite') {
            final lastSegment = segments.last.trim();
            if (lastSegment.isNotEmpty) return lastSegment;
          }
        }
      }
    }

    // 2. Kiểm tra chuỗi định dạng JSON
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map<String, dynamic>) {
          final code = decoded['inviteCode'] ?? decoded['code'];
          if (code != null && code.toString().trim().isNotEmpty) {
            return code.toString().trim();
          }
        }
      } catch (_) {
        // Bỏ qua lỗi parse JSON
      }
    }

    // 3. Chuỗi thô (loại bỏ ký tự không hợp lệ)
    final sanitized = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    if (sanitized.isNotEmpty) {
      return sanitized;
    }

    return trimmed;
  }
}
