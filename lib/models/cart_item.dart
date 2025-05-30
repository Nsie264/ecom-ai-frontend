import '../models/product.dart';

class CartItem {
  final int cartItemId;
  final int productId;
  final String name; // Product name directly in cart item
  final double price; // Product price directly in cart item
  final int quantity;
  final double subtotal; // Server provides this as 'subtotal'
  final String? imageUrl; // Product image directly in cart item
  final int? stockQuantity; // Stock info directly in cart item
  final bool? isInStock; // Stock status directly in cart item
  final int userId;
  final DateTime addedAt;
  final Product product; // We'll create this from the flat data

  CartItem({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.imageUrl,
    this.stockQuantity,
    this.isInStock,
    required this.userId,
    required this.addedAt,
    required this.product,
  });

  // Getter for compatibility with existing code
  double get total => subtotal;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Add debug print to see the actual structure of the response
    print('DEBUG: CartItem JSON response: $json');

    // Create a product from the flat data
    final product = Product(
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      price:
          json['price'] != null
              ? (json['price'] is int)
                  ? (json['price'] as int).toDouble()
                  : (json['price'] as num).toDouble()
              : 0.0,
      categoryId: 0, // Default as we don't have this info
      categoryName: '', // Default as we don't have this info
      imageUrl: json['image_url'],
    );

    // Safely convert values, providing defaults for missing or null fields
    return CartItem(
      cartItemId: json['cart_item_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? 'Unnamed Product',
      price:
          json['price'] != null
              ? (json['price'] is int)
                  ? (json['price'] as int).toDouble()
                  : (json['price'] as num).toDouble()
              : 0.0,
      quantity: json['quantity'] ?? 1,
      subtotal:
          json['subtotal'] != null
              ? (json['subtotal'] is int)
                  ? (json['subtotal'] as int).toDouble()
                  : (json['subtotal'] as num).toDouble()
              : 0.0,
      imageUrl: json['image_url'],
      stockQuantity: json['stock_quantity'],
      isInStock: json['is_in_stock'],
      userId: json['user_id'] ?? 0,
      addedAt:
          json['added_at'] != null
              ? DateTime.parse(json['added_at'])
              : DateTime.now(),
      product: product,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item_id': cartItemId,
      'product_id': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'is_in_stock': isInStock,
      'user_id': userId,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
