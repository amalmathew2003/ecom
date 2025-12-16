class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      category: json['category'],
    );
  }
}
