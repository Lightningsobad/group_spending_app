import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/debts/data/models/actual_debt_model.dart';
import 'package:group_spending_app/features/debts/data/models/debt_overview_model.dart';
import 'package:group_spending_app/features/debts/data/models/group_debts_models.dart';
import 'package:group_spending_app/features/debts/data/models/simplified_debt_model.dart';
import 'package:group_spending_app/features/debts/domain/entities/debt_enums.dart';

void main() {
  group('Debt Models Test', () {
    test('DebtOverviewModel parses from JSON correctly', () {
      final json = {
        'totalOwed': 250,
        'totalOwedVnd': 250000,
        'totalReceivable': 600,
        'totalReceivableVnd': 600000,
        'netBalance': 350,
        'netBalanceVnd': 350000,
        'groupBalances': [
          {
            'groupId': 10,
            'groupName': 'Chung cư Sunrise Room',
            'youOwe': 100,
            'youOweVnd': 100000,
            'youAreOwed': 450,
            'youAreOwedVnd': 450000,
            'netBalance': 350,
            'netBalanceVnd': 350000,
            'pendingDebtCount': 4,
          },
        ],
        'details': [
          {
            'debtId': 101,
            'groupId': 10,
            'groupName': 'Chung cư Sunrise Room',
            'peerId': 5,
            'peerName': 'Trần Thị B',
            'peerAvatar': 'https://example.com/avatar.jpg',
            'amount': 450,
            'amountVnd': 450000,
            'type': 'OWED_TO_YOU',
            'status': 'PENDING',
            'createdAt': '2026-09-27T10:15:00Z',
          }
        ]
      };

      final model = DebtOverviewModel.fromJson(json);

      expect(model.totalOwedVnd, 250000);
      expect(model.totalReceivableVnd, 600000);
      expect(model.netBalanceVnd, 350000);
      expect(model.groupBalances.length, 1);

      final group = model.groupBalances.first;
      expect(group.groupId, 10);
      expect(group.groupName, 'Chung cư Sunrise Room');
      expect(group.isReceiving, isTrue);
      expect(group.isOwing, isFalse);
      expect(group.pendingDebtCount, 4);

      final detail = model.details.first;
      expect(detail.debtId, 101);
      expect(detail.peerName, 'Trần Thị B');
      expect(detail.type, PeerDebtType.owedToYou);
      expect(detail.status, DebtStatus.pending);
    });

    test('SimplifiedDebtModel parses from JSON correctly', () {
      final json = {
        'id': 101,
        'debtorId': 2,
        'debtorName': 'Nguyễn Văn B',
        'debtorAvatar': 'https://example.com/user2.jpg',
        'creditorId': 1,
        'creditorName': 'Tôi',
        'creditorAvatar': 'https://example.com/user1.jpg',
        'amount': 350,
        'amountVnd': 350000,
        'action': 'REMIND',
        'note': 'Gộp nợ từ các hóa đơn',
      };

      final model = SimplifiedDebtModel.fromJson(json);

      expect(model.id, 101);
      expect(model.debtorId, 2);
      expect(model.creditorId, 1);
      expect(model.amountVnd, 350000);
      expect(model.action, DebtAction.remind);
      expect(model.note, 'Gộp nợ từ các hóa đơn');
    });

    test('ActualDebtModel parses from JSON correctly', () {
      final json = {
        'id': 102,
        'groupId': 10,
        'debtorId': 3,
        'debtorName': 'Hoàng Minh C',
        'creditorId': 1,
        'creditorName': 'Tôi',
        'amount': 200,
        'amountVnd': 200000,
        'status': 'WAITING_FOR_CONFIRMATION',
        'action': 'CONFIRM',
        'createdAt': '2026-09-27T09:30:00Z',
      };

      final model = ActualDebtModel.fromJson(json);

      expect(model.id, 102);
      expect(model.groupId, 10);
      expect(model.debtorId, 3);
      expect(model.status, DebtStatus.waitingForConfirmation);
      expect(model.action, DebtAction.confirm);
      expect(model.amountVnd, 200000);
    });

    test('GroupSimplifiedDebtsModel & GroupActualDebtsModel parse correctly', () {
      final simplifiedJson = {
        'userBalance': {
          'groupId': 10,
          'groupName': 'Chung cư Sunrise Room',
          'youOweVnd': 0,
          'youAreOwedVnd': 350000,
          'netBalanceVnd': 350000,
        },
        'simplifiedDebts': [
          {
            'debtorId': 2,
            'debtorName': 'B',
            'creditorId': 1,
            'creditorName': 'Tôi',
            'amountVnd': 350000,
            'action': 'REMIND',
          }
        ]
      };

      final simplified = GroupSimplifiedDebtsModel.fromJson(simplifiedJson);
      expect(simplified.userBalance.groupId, 10);
      expect(simplified.userBalance.isReceiving, isTrue);
      expect(simplified.simplifiedDebts.length, 1);

      final actualJson = {
        'userBalance': {
          'groupId': 10,
          'groupName': 'Chung cư Sunrise Room',
          'youOweVnd': 50000,
          'youAreOwedVnd': 400000,
          'netBalanceVnd': 350000,
        },
        'actualDebts': [
          {
            'id': 1,
            'groupId': 10,
            'debtorId': 1,
            'debtorName': 'Tôi',
            'creditorId': 2,
            'creditorName': 'B',
            'amountVnd': 50000,
            'status': 'PENDING',
            'action': 'PAY',
          }
        ]
      };

      final actual = GroupActualDebtsModel.fromJson(actualJson);
      expect(actual.userBalance.netBalanceVnd, 350000);
      expect(actual.actualDebts.length, 1);
      expect(actual.actualDebts.first.action, DebtAction.pay);
    });
  });
}
