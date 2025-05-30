import 'package:dio/dio.dart';
import '../utils/http_client.dart';
import '../models/cart_item.dart';

class CartApiService {
  final HttpClient _httpClient;

  CartApiService(this._httpClient);

  /// Get the current user's cart
  /// Requires authentication
  Future<List<CartItem>> getCart() async {
    try {
      print('DEBUG: CartApiService.getCart() called');

      // Using the format that worked for addToCart
      final response = await _httpClient.get('/cart/');

      // Add debugging to see the actual structure
      print('DEBUG: Cart response data type: ${response.data.runtimeType}');
      print('DEBUG: Cart response data: ${response.data}');

      // Handle different response structures
      if (response.data is List) {
        // If response is directly a list of cart items
        return (response.data as List)
            .map((json) => CartItem.fromJson(json))
            .toList();
      } else if (response.data is Map) {
        // If response is a map that contains a list of cart items in a field
        // Try common field names for the items list
        if (response.data.containsKey('items')) {
          return (response.data['items'] as List)
              .map((json) => CartItem.fromJson(json))
              .toList();
        } else if (response.data.containsKey('data')) {
          return (response.data['data'] as List)
              .map((json) => CartItem.fromJson(json))
              .toList();
        } else if (response.data.containsKey('cart_items')) {
          return (response.data['cart_items'] as List)
              .map((json) => CartItem.fromJson(json))
              .toList();
        } else {
          // If we can't find the items list, return an empty list
          print('DEBUG: Could not find cart items list in response structure');
          return [];
        }
      } else {
        // Unknown response type
        print('DEBUG: Unexpected response type: ${response.data.runtimeType}');
        return [];
      }
    } catch (e) {
      print('DEBUG: Exception in CartApiService.getCart(): $e');
      _handleError(e, 'Failed to get cart');
      rethrow;
    }
  }

  /// Add an item to the cart
  /// If the item already exists, its quantity will be increased
  /// Requires authentication
  Future<CartItem> addToCart(int productId, int quantity) async {
    try {
      final data = {'product_id': productId, 'quantity': quantity};

      // Make sure this matches your server's API pattern
      final response = await _httpClient.post('/cart/add', data: data);
      return CartItem.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to add item to cart');
      rethrow;
    }
  }

  /// Update the quantity of an item in the cart
  /// Requires authentication
  Future<CartItem> updateCartItem(int cartItemId, int quantity) async {
    try {
      final data = {'quantity': quantity};

      // Add debugging to troubleshoot
      print('DEBUG: Updating cart item $cartItemId to quantity $quantity');

      // Updated to match the API endpoint format from curl example
      final response = await _httpClient.put(
        '/cart/items/$cartItemId',
        data: data,
      );

      // Debug the response
      print('DEBUG: Update cart response: ${response.data}');

      // Check if the operation was successful
      if (response.data is Map && response.data['success'] == false) {
        // If server returns an error message
        final errorMsg =
            response.data['message'] ?? 'Failed to update cart item';
        throw Exception(errorMsg);
      }

      return CartItem.fromJson(response.data);
    } catch (e) {
      print('DEBUG: Error updating cart item: $e');
      _handleError(e, 'Failed to update cart item');
      rethrow;
    }
  }

  /// Remove an item from the cart
  /// Requires authentication
  Future<bool> removeFromCart(int cartItemId) async {
    try {
      // Add debugging to troubleshoot
      print('DEBUG: Removing cart item $cartItemId');

      // Updated to match the API endpoint format from curl example
      final response = await _httpClient.delete('/cart/items/$cartItemId');

      // Debug the response
      print('DEBUG: Remove cart response: ${response.data}');

      return response.data['success'] ?? false;
    } catch (e) {
      print('DEBUG: Error removing cart item: $e');
      _handleError(e, 'Failed to remove item from cart');
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
