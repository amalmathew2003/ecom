class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? product =
        json['products'] as Map<String, dynamic>?;

    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: product?['name']?.toString() ?? 'Unknown Product',
      productImage: (product?['image_url'] as List?)?.first?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price_at_time'] as num? ?? json['price'] as num? ?? 0)
          .toDouble(),
    );
  }
}
