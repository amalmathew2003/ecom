class OrderModel {
  final String id;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String orderType;

  OrderModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.orderType,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),

      // ✅ FIX: use `amount`, not `total`
      amount: (json['amount'] as num).toDouble(),

      // ✅ FIX: use `payment_status`
      status: _parseStatus(json['payment_status']),

      createdAt: DateTime.parse(json['created_at']),
      orderType: json['order_type']?.toString() ?? '',
    );
  }

  static String _parseStatus(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return 'SUCCESS';
        case 2:
          return 'FAILED';
        default:
          return 'PENDING';
      }
    }

    if (value is String) {
      return value.toUpperCase();
    }

    return 'PENDING';
  }
}
