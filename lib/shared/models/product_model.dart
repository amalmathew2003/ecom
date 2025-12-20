class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> imageUrl; // 🔥 SAME NAME, NOW LIST
  final String categoryId;
  final String subCategoryId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.subCategoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] == null
          ? []
          : List<String>.from(json['image_url']),
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
    );
  }
}
