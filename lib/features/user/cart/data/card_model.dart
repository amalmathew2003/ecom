import 'package:ecom/shared/models/product_model.dart';

class CartItemModel {
  final String id;
  final int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'],
      product: ProductModel.fromJson(json['products']),
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      quantity: quantity ?? this.quantity,
      product: product,
    );
  }

  double get total => product.price * quantity;
}
