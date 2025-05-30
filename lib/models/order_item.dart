import '../models/product.dart';

class OrderItem {
  final int orderItemId;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final Product product;
  final double total; // Calculated field: priceAtPurchase * quantity

  OrderItem({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.product,
    required this.total,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle both cases: when product data is included and when it's not
    Product? productData;
    if (json['product'] != null) {
      productData = Product.fromJson(json['product']);
    }

    return OrderItem(
      orderItemId: json['order_item_id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      priceAtPurchase:
          json['price_at_purchase'] is int
              ? (json['price_at_purchase'] as int).toDouble()
              : json['price_at_purchase'],
      product: productData ?? Product.fromJson(json['product_snapshot']),
      total:
          json['total'] != null
              ? (json['total'] is int)
                  ? (json['total'] as int).toDouble()
                  : json['total']
              : json['price_at_purchase'] * json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_item_id': orderItemId,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'product': product.toJson(),
      'total': total,
    };
  }
}
