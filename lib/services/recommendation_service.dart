import 'package:dio/dio.dart';
import '../models/product.dart';
import '../utils/http_client.dart';

class RecommendationApiService {
  final HttpClient _httpClient;

  RecommendationApiService(this._httpClient);

  /// Fetches similar products based on a specific product ID
  ///
  /// [productId] - ID of the product to find similar items for
  /// [limit] - Optional parameter to limit the number of recommendations (default: 10)
  Future<List<Product>> getSimilarProducts(
    int productId, {
    int limit = 10,
  }) async {
    try {
      final response = await _httpClient.get(
        '/recommendations/similar/$productId',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        // Handling the new API response format
        if (response.data['success'] == true && response.data['similar_products'] != null) {
          final List<dynamic> similarProductsData = response.data['similar_products'];
          
          // Convert each similar product to a Product object
          return similarProductsData.map((item) {
            // Create a Product object from the similar product data
            return Product(
              productId: item['product_id'],
              name: item['name'],
              price: item['price'],
              description: '', // Not provided in similar products
              stockQuantity: 0, // Not provided in similar products
              categoryId: 1, // Not provided in similar products
              categoryName: "Sản phẩm tương tự", // Not provided in similar products
              imageUrl: item['image_url'],
              // Optional: Store the similarity score as metadata
              // metadata: {'similarity_score': item['similarity_score']},
            );
          }).toList();
        } else {
          // Fallback for old API format
          final List<dynamic> data = response.data['data'] ?? [];
          return data.map((item) => Product.fromJson(item)).toList();
        }
      } else {
        throw Exception(
          'Failed to load similar products: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Network error when loading similar products: ${e.message}',
      );
    } catch (e) {
      print('Error in getSimilarProducts: $e');
      throw Exception('Error loading similar products: $e');
    }
  }

  /// Fetches personalized product recommendations for the current user
  ///
  /// [limit] - Optional parameter to limit the number of recommendations (default: 10)
  Future<List<Product>> getPersonalizedRecommendations({int limit = 10}) async {
    try {
      final response = await _httpClient.get(
        '/recommendations/personalized',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        // Handling the new API response format
        if (response.data['success'] == true &&
            response.data['recommendations'] != null) {
          final List<dynamic> recommendationsData =
              response.data['recommendations'];

          // Convert each recommendation to a Product object
          return recommendationsData.map((item) {
            // Create a Product object from the recommendation data
            return Product(
              productId: item['product_id'],
              name: item['name'],
              price: item['price'],
              description: '', // Not provided in recommendations
              stockQuantity: 0, // Not provided in recommendations
              categoryId: 1, // Not provided in recommendations
              categoryName: "Có thể bạn sẽ thích", // Not provided in recommendations
              imageUrl: item['image_url'],
              // Optional: Store the recommendation score as metadata
              // metadata: {'recommendation_score': item['recommendation_score']},
            );
          }).toList();
        } else {
          // Old implementation fallback, in case the API changes back or for older endpoints
          final List<dynamic> data = response.data['data'] ?? [];
          return data.map((item) => Product.fromJson(item)).toList();
        }
      } else {
        throw Exception(
          'Failed to load personalized recommendations: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Network error when loading recommendations: ${e.message}',
      );
    } catch (e) {
      print('Error in getPersonalizedRecommendations: $e');
      throw Exception('Error loading recommendations: $e');
    }
  }
}
