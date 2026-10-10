import 'package:flutter_test/flutter_test.dart';
import 'package:group_spending_app/features/expenses/data/models/receipt_scan_models.dart';
import 'package:group_spending_app/features/expenses/data/models/expense_enums.dart';

void main() {
  group('ReceiptScanDataModel parsing', () {
    test('parses Highlands Coffee response correctly', () {
      final json = {
        "merchantName": "Highlands Coffee",
        "suggestedTitle": "Ăn uống Highlands Coffee",
        "totalAmount": 155,
        "totalAmountVnd": 154500,
        "rawTotalAmount": "154.500 đ",
        "category": "Food",
        "categoryReasoning": "Hóa đơn dịch vụ đồ uống và cafe tại Highlands Coffee",
        "expenseDate": "2026-10-09",
        "confidence": "HIGH",
        "lineItems": [
          {
            "itemName": "Trà sen vàng (Size L)",
            "quantity": 2,
            "unitPriceVnd": 55000,
            "totalPriceVnd": 110000
          },
          {
            "itemName": "Bánh mì que pate",
            "quantity": 1,
            "unitPriceVnd": 19000,
            "totalPriceVnd": 19000
          }
        ],
        "generatedNotes": "[Highlands Coffee]\nChi tiết các món/mục:\n- 2x Trà sen vàng (Size L): 110.000đ\n- Bánh mì que pate: 19.000đ\n---\nTổng cộng: 154.500đ",
        "receiptUrl": "https://res.cloudinary.com/demo/image/upload/v1728448800/receipts/bill_abc123.jpg"
      };

      final model = ReceiptScanDataModel.fromJson(json);

      expect(model.merchantName, 'Highlands Coffee');
      expect(model.suggestedTitle, 'Ăn uống Highlands Coffee');
      expect(model.totalAmount, 155);
      expect(model.totalAmountVnd, 154500);
      expect(model.rawTotalAmount, '154.500 đ');
      expect(model.category, 'Food');
      expect(model.expenseDate, '2026-10-09');
      expect(model.confidence, 'HIGH');
      expect(model.isLowConfidence, false);
      expect(model.lineItems.length, 2);
      expect(model.lineItems[0].itemName, 'Trà sen vàng (Size L)');
      expect(model.lineItems[0].quantity, 2);
      expect(model.lineItems[0].unitPriceVnd, 55000);
      expect(model.lineItems[0].totalPriceVnd, 110000);
      expect(model.generatedNotes, contains('Highlands Coffee'));
      expect(model.receiptUrl, 'https://res.cloudinary.com/demo/image/upload/v1728448800/receipts/bill_abc123.jpg');

      // Check category parsing
      final categoryType = ExpenseCategoryType.fromString(model.category);
      expect(categoryType, ExpenseCategoryType.food);
    });

    test('parses WinMart+ grocery response correctly', () {
      final json = {
        "merchantName": "WinMart+",
        "suggestedTitle": "Mua thực phẩm WinMart+",
        "totalAmount": 86,
        "totalAmountVnd": 86200,
        "rawTotalAmount": "86.200 đ",
        "category": "Grocerise",
        "categoryReasoning": "Hóa đơn mua thực phẩm và nhu yếu phẩm tại siêu thị WinMart+",
        "expenseDate": "2026-10-09",
        "confidence": "HIGH",
        "lineItems": [
          { "itemName": "Sữa chua Vinamilk 4 hộp", "quantity": 1, "unitPriceVnd": 28000, "totalPriceVnd": 28000 }
        ],
        "generatedNotes": "[WinMart+]\nSữa chua",
        "receiptUrl": "https://res.cloudinary.com/demo/image/upload/bill2.jpg"
      };

      final model = ReceiptScanDataModel.fromJson(json);
      expect(model.merchantName, 'WinMart+');
      expect(model.category, 'Grocerise');
      expect(ExpenseCategoryType.fromString(model.category), ExpenseCategoryType.groceries);
    });

    test('parses low confidence fallback response correctly', () {
      final json = {
        "merchantName": null,
        "suggestedTitle": "Khoản chi mới",
        "totalAmount": null,
        "totalAmountVnd": null,
        "rawTotalAmount": null,
        "category": "Others",
        "categoryReasoning": "Không nhận diện được nội dung tự động do lỗi kết nối hoặc ảnh mờ.",
        "expenseDate": "2026-10-09",
        "confidence": "LOW",
        "lineItems": [],
        "generatedNotes": "",
        "receiptUrl": "https://res.cloudinary.com/demo/image/upload/blurred_bill.jpg"
      };

      final model = ReceiptScanDataModel.fromJson(json);
      expect(model.merchantName, isNull);
      expect(model.totalAmount, isNull);
      expect(model.totalAmountVnd, isNull);
      expect(model.isLowConfidence, true);
      expect(model.receiptUrl, 'https://res.cloudinary.com/demo/image/upload/blurred_bill.jpg');
      expect(ExpenseCategoryType.fromString(model.category), ExpenseCategoryType.others);
    });
  });
}
