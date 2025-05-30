import 'order_item.dart';
import 'address.dart';

class Order {
  final int orderId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final Address shippingAddress;
  final String paymentMethod;
  final int itemCount;
  final List<OrderItem>? items;
  // Optional fields that might not be in the list response
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.itemCount,
    this.items,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items if present
    List<OrderItem>? orderItems;
    if (json['items'] != null && json['items'] is List) {
      orderItems =
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList();
    }

    // Parse shipping address
    Address address;
    if (json['shipping_address'] != null) {
      address = Address.fromJson(json['shipping_address']);
    } else {
      // Fallback for missing address
      address = Address(
        addressId: 0,
        street: '',
        city: '',
        state: '',
        postalCode: '',
        country: '',
        phone: '',
      );
    }

    return Order(
      orderId: json['order_id'],
      orderDate: DateTime.parse(json['order_date']),
      totalAmount:
          json['total_amount'] is int
              ? (json['total_amount'] as int).toDouble()
              : json['total_amount'],
      status: json['status'],
      shippingAddress: address,
      paymentMethod: json['payment_method'],
      itemCount: json['item_count'] ?? (orderItems?.length ?? 0),
      items: orderItems,
      userId: json['user_id'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'order_id': orderId,
      'order_date': orderDate.toIso8601String(),
      'total_amount': totalAmount,
      'status': status,
      'shipping_address': shippingAddress.toJson(),
      'payment_method': paymentMethod,
      'item_count': itemCount,
    };

    if (items != null) {
      data['items'] = items!.map((item) => item.toJson()).toList();
    }

    // if (userId != null) data['user_id'] = userId;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updated_at'] = updatedAt!.toIso8601String();

    return data;
  }
}
