import 'package:dio/dio.dart';
import 'package:ecom_ai_frontend/models/address.dart';
import '../utils/http_client.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class OrderApiService {
  final HttpClient _httpClient;

  OrderApiService(this._httpClient);

  /// Get a list of the current user's orders
  /// Requires authentication
  Future<List<Order>> getOrdersList({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _httpClient.get(
        '/orders/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      return (response.data['items'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to get orders list');
      rethrow;
    }
  }

  /// Get details of a specific order
  /// Requires authentication and ownership of the order
  Future<Order> getOrderDetails(int orderId) async {
    try {
      final response = await _httpClient.get('/orders/$orderId');
      return Order.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to get order details');
      rethrow;
    }
  }

  /// Create a new order from the current cart
  /// Requires authentication and a non-empty cart
  Future<Order> createOrder({required int addressId, String? notes}) async {
    try {
      final data = {'address_id': addressId};

      // if (notes != null && notes.isNotEmpty) {
      //   data['notes'] = notes;
      // }

      final response = await _httpClient.post('/orders/', data: data);

      // Create a minimal Order object from the create order response
      // or fetch full order details if needed
      if (response.data['order_id'] != null) {
        // Option 1: Return minimal order and fetch details later
        return Order(
          orderId: response.data['order_id'],
          orderDate: DateTime.now(),
          totalAmount:
              response.data['total_amount'] is int
                  ? (response.data['total_amount'] as int).toDouble()
                  : response.data['total_amount'],
          status: response.data['status'] ?? 'pending',
          shippingAddress: Address(street: "", city: "", country: ""),
          paymentMethod: response.data['payment_method'] ?? 'Cash on delivery',
          itemCount: response.data['item_count'] ?? 0,
          userId: response.data['user_id'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Option 2: Fetch full order details immediately
        // return getOrderDetails(response.data['order_id']);
      } else {
        throw Exception('Failed to create order: Missing order ID in response');
      }
    } catch (e) {
      _handleError(e, 'Failed to create order');
      rethrow;
    }
  }

  /// Cancel an order that has not been shipped yet
  /// Requires authentication and ownership of the order
  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final data = reason != null ? {'cancel_reason': reason} : null;

      final response = await _httpClient.put(
        '/orders/$orderId/cancel',
        data: data,
      );

      return response.data['success'] ?? false;
    } catch (e) {
      _handleError(e, 'Failed to cancel order');
      rethrow;
    }
  }

  /// Helper method to handle errors
  void _handleError(dynamic error, String defaultMessage) {
    if (error is DioException) {
      print('${error.response?.statusCode}: ${error.response?.data}');
      // You can add more sophisticated error handling here
    } else {
      print('Error: $error');
    }
  }
}
