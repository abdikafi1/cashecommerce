class Transaction {
  final String id;
  final String userId;
  final List<TransactionProduct> products;
  final double totalAmount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List;
    List<TransactionProduct> products = productList
        .map((productJson) => TransactionProduct.fromJson(productJson))
        .toList();

    return Transaction(
      id: json['_id'],
      userId: json['userId'],
      products: products,
      totalAmount: json['totalAmount'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }
}

class TransactionProduct {
  final String productId;
  final int quantity;

  TransactionProduct({
    required this.productId,
    required this.quantity,
  });

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    return TransactionProduct(
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }
}
