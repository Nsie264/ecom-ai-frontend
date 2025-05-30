class Product {
  final int productId;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String categoryName;
  final int? stockQuantity;
  final Map<String, dynamic>? attributes;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ProductImage>? images;
  final List<String>? tags;
  final String? imageUrl; // For list views

  Product({
    required this.productId,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.stockQuantity,
    this.attributes,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.tags,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Add debug print to see the actual structure of the response
    print('DEBUG: Product JSON response: $json');

    return Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      description: json['description'],
      price:
          json['price'] != null
              ? (json['price'] is int)
                  ? (json['price'] as int).toDouble()
                  : (json['price'] as num).toDouble()
              : 0.0,
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? 'Uncategorized',
      stockQuantity: json['stock_quantity'],
      attributes:
          json['attributes'] != null
              ? Map<String, dynamic>.from(json['attributes'])
              : null,
      isActive: json['is_active'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      images:
          json['images'] != null
              ? (json['images'] as List)
                  .map((i) => ProductImage.fromJson(i))
                  .toList()
              : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'product_id': productId,
      'name': name,
      'price': price,
      'category_id': categoryId,
      'category_name': categoryName,
    };

    if (description != null) data['description'] = description;
    if (stockQuantity != null) data['stock_quantity'] = stockQuantity;
    if (attributes != null) data['attributes'] = attributes;
    if (isActive != null) data['is_active'] = isActive;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();
    if (images != null) {
      data['images'] = images!.map((e) => e.toJson()).toList();
    }
    if (tags != null) data['tags'] = tags;
    if (imageUrl != null) data['image_url'] = imageUrl;

    return data;
  }
}

class ProductImage {
  final int imageId;
  final int productId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;

  ProductImage({
    required this.imageId,
    required this.productId,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['image_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      imageUrl: json['image_url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      displayOrder: json['display_order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'product_id': productId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'display_order': displayOrder,
    };
  }
}
