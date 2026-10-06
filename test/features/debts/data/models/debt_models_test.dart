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

    test('ActualDebtModel parses from Section 3.3 JSON correctly', () {
      final json = {
        'expenseId': 1,
        'title': 'Lẩu Haidilao cuối tuần',
        'categoryName': 'Ăn uống',
        'categoryIcon': 'restaurant',
        'totalAmount': 1280,
        'totalAmountVnd': 1280000,
        'expenseDate': '2026-09-10',
        'createdAt': '2026-09-10T19:30:00Z',
        'paidByUserId': 1,
        'paidByUserName': 'Nguyễn Nhật Minh',
        'paidByUserAvatar': 'https://cdn.example.com/avatar/user1.jpg',
        'isPaidByMe': true,
        'debtorCount': 3,
        'debtors': [
          {
            'splitId': 101,
            'userId': 2,
            'name': 'An',
            'avatarUrl': 'https://cdn.example.com/avatar/user2.jpg',
            'isMe': false,
            'amount': 320,
            'amountVnd': 320000,
            'status': 'SETTLED',
            'action': 'NONE',
          },
          {
            'splitId': 102,
            'userId': 3,
            'name': 'Hương',
            'avatarUrl': 'https://cdn.example.com/avatar/user3.jpg',
            'isMe': false,
            'amount': 320,
            'amountVnd': 320000,
            'status': 'PENDING',
            'action': 'REMIND',
          },
          {
            'splitId': 103,
            'userId': 4,
            'name': 'Linh',
            'avatarUrl': 'https://cdn.example.com/avatar/user4.jpg',
            'isMe': false,
            'amount': 320,
            'amountVnd': 320000,
            'status': 'WAITING_FOR_CONFIRMATION',
            'action': 'CONFIRM',
          },
        ],
      };

      final model = ActualDebtModel.fromJson(json);

      expect(model.expenseId, 1);
      expect(model.title, 'Lẩu Haidilao cuối tuần');
      expect(model.categoryName, 'Ăn uống');
      expect(model.totalAmountVnd, 1280000);
      expect(model.isPaidByMe, isTrue);
      expect(model.debtorCount, 3);
      expect(model.debtors.length, 3);

      final debtor1 = model.debtors[0];
      expect(debtor1.splitId, 101);
      expect(debtor1.name, 'An');
      expect(debtor1.amountVnd, 320000);
      expect(debtor1.status, DebtStatus.settled);
      expect(debtor1.action, DebtAction.none);

      final debtor2 = model.debtors[1];
      expect(debtor2.splitId, 102);
      expect(debtor2.name, 'Hương');
      expect(debtor2.status, DebtStatus.pending);
      expect(debtor2.action, DebtAction.remind);

      final debtor3 = model.debtors[2];
      expect(debtor3.splitId, 103);
      expect(debtor3.name, 'Linh');
      expect(debtor3.status, DebtStatus.waitingForConfirmation);
      expect(debtor3.action, DebtAction.confirm);

      final serialized = model.toJson();
      expect(serialized['expenseId'], 1);
      expect(serialized['debtors'], hasLength(3));
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
            'expenseId': 1,
            'title': 'Tiền Internet & Truyền hình FPT',
            'totalAmountVnd': 150000,
            'debtors': [
              {
                'splitId': 104,
                'userId': 1,
                'name': 'Minh',
                'amountVnd': 150000,
                'status': 'PENDING',
                'action': 'PAY',
              }
            ]
          }
        ]
      };

      final actual = GroupActualDebtsModel.fromJson(actualJson);
      expect(actual.userBalance.netBalanceVnd, 350000);
      expect(actual.actualDebts.length, 1);
      expect(actual.actualDebts.first.debtors.first.action, DebtAction.pay);
    });
  });
}
