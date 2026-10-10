class ReceiptLineItemModel {
  final String itemName;
  final num quantity;
  final num? unitPriceVnd;
  final num? totalPriceVnd;

  const ReceiptLineItemModel({
    required this.itemName,
    required this.quantity,
    this.unitPriceVnd,
    this.totalPriceVnd,
  });

  factory ReceiptLineItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptLineItemModel(
      itemName: (json['itemName'] as String?) ?? '',
      quantity: (json['quantity'] as num?) ?? 1,
      unitPriceVnd: json['unitPriceVnd'] as num?,
      totalPriceVnd: json['totalPriceVnd'] as num?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      if (unitPriceVnd != null) 'unitPriceVnd': unitPriceVnd,
      if (totalPriceVnd != null) 'totalPriceVnd': totalPriceVnd,
    };
  }
}

class ReceiptScanDataModel {
  final String? merchantName;
  final String? suggestedTitle;
  final num? totalAmount;
  final num? totalAmountVnd;
  final String? rawTotalAmount;
  final String? category;
  final String? categoryReasoning;
  final String? expenseDate;
  final String? confidence;
  final List<ReceiptLineItemModel> lineItems;
  final String? generatedNotes;
  final String? receiptUrl;

  const ReceiptScanDataModel({
    this.merchantName,
    this.suggestedTitle,
    this.totalAmount,
    this.totalAmountVnd,
    this.rawTotalAmount,
    this.category,
    this.categoryReasoning,
    this.expenseDate,
    this.confidence,
    this.lineItems = const [],
    this.generatedNotes,
    this.receiptUrl,
  });

  bool get isLowConfidence => confidence?.toUpperCase() == 'LOW';

  factory ReceiptScanDataModel.fromJson(Map<String, dynamic> json) {
    final rawLineItems = json['lineItems'];
    final items = <ReceiptLineItemModel>[];
    if (rawLineItems is List) {
      for (final item in rawLineItems) {
        if (item is Map<String, dynamic>) {
          items.add(ReceiptLineItemModel.fromJson(item));
        }
      }
    }

    return ReceiptScanDataModel(
      merchantName: json['merchantName'] as String?,
      suggestedTitle: json['suggestedTitle'] as String?,
      totalAmount: json['totalAmount'] as num?,
      totalAmountVnd: json['totalAmountVnd'] as num?,
      rawTotalAmount: json['rawTotalAmount'] as String?,
      category: json['category'] as String?,
      categoryReasoning: json['categoryReasoning'] as String?,
      expenseDate: json['expenseDate'] as String?,
      confidence: json['confidence'] as String?,
      lineItems: items,
      generatedNotes: json['generatedNotes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (merchantName != null) 'merchantName': merchantName,
      if (suggestedTitle != null) 'suggestedTitle': suggestedTitle,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (totalAmountVnd != null) 'totalAmountVnd': totalAmountVnd,
      if (rawTotalAmount != null) 'rawTotalAmount': rawTotalAmount,
      if (category != null) 'category': category,
      if (categoryReasoning != null) 'categoryReasoning': categoryReasoning,
      if (expenseDate != null) 'expenseDate': expenseDate,
      if (confidence != null) 'confidence': confidence,
      'lineItems': lineItems.map((e) => e.toJson()).toList(),
      if (generatedNotes != null) 'generatedNotes': generatedNotes,
      if (receiptUrl != null) 'receiptUrl': receiptUrl,
    };
  }
}
