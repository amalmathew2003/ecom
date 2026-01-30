import 'package:ecom/features/user/orders/data/order_item_model.dart';

class OrderModel {
  final String id;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String orderType;
  final String paymentMethod;
  final String? userName;
  final String? userEmail;
  final String? managerName;
  final String? deliveryStatus;
  final String? shippingAddress;
  final String? customerPhone;
  final String? deliveryPersonId;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.orderType,
    required this.paymentMethod,
    this.userName,
    this.userEmail,
    this.managerName,
    this.deliveryStatus,
    this.shippingAddress,
    this.customerPhone,
    this.deliveryPersonId,
    this.orderItems = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final profiles = json['customer'];
    final manager = json['manager'];

    List<OrderItemModel> items = [];
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((e) => OrderItemModel.fromJson(e))
          .toList();
    }

    return OrderModel(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      status: _parseStatus(json['payment_status']),
      createdAt: DateTime.parse(json['created_at']),
      orderType: json['order_type']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? 'COD',
      userName: profiles?['full_name'],
      userEmail: profiles?['email'],
      managerName: manager?['full_name'],
      deliveryStatus: json['delivery_status']?.toString() ?? 'pending',
      shippingAddress: json['shipping_address']?.toString() ?? '',
      customerPhone: json['customer_phone']?.toString() ?? '',
      deliveryPersonId: json['delivery_person']?.toString(),
      orderItems: items,
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
