import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/groups/presentation/utils/invite_code_parser.dart';

void main() {
  group('InviteCodeParser Tests', () {
    test('parses plain alphanumeric invite code', () {
      expect(InviteCodeParser.extract('634636'), '634636');
      expect(InviteCodeParser.extract('DL2026'), 'DL2026');
      expect(InviteCodeParser.extract('  E93KLA  '), 'E93KLA');
    });

    test('parses full API URL with inviteCode query parameter', () {
      const url = 'https://api.groupspending.xyz/api/v1/groups/join?inviteCode=634636';
      expect(InviteCodeParser.extract(url), '634636');
    });

    test('parses custom scheme URL with inviteCode parameter', () {
      const url = 'groupspending://join?inviteCode=ROOM402';
      expect(InviteCodeParser.extract(url), 'ROOM402');
    });

    test('parses URL with code query parameter', () {
      const url = 'https://groupspending.xyz/groups?code=DALAT2024';
      expect(InviteCodeParser.extract(url), 'DALAT2024');
    });

    test('parses URL path with join segment', () {
      const url = 'https://groupspending.xyz/join/634636';
      expect(InviteCodeParser.extract(url), '634636');
    });

    test('parses JSON format', () {
      const jsonStr = '{"inviteCode": "634636"}';
      expect(InviteCodeParser.extract(jsonStr), '634636');
    });

    test('returns null for null or empty input', () {
      expect(InviteCodeParser.extract(null), isNull);
      expect(InviteCodeParser.extract(''), isNull);
      expect(InviteCodeParser.extract('   '), isNull);
    });
  });
}
