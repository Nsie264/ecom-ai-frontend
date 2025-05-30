class ProductRequest {
  String name;
  String description;
  double price;
  int categoryId;
  int stockQuantity;
  Map<String, dynamic> attributes;
  bool isActive;

  ProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.stockQuantity,
    required this.attributes,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'attributes': attributes,
      'is_active': isActive,
    };
  }
}
