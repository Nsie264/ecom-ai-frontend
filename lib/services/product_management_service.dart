import 'package:ecom_ai_frontend/models/product.dart';
import 'package:ecom_ai_frontend/models/product_request.dart';
import 'package:ecom_ai_frontend/utils/http_client.dart';
import 'package:ecom_ai_frontend/config/api_config.dart';

class ProductManagementService {
  final HttpClient _httpClient = HttpClient(ApiConfig.baseUrl);

  Future<Product> createProduct(ProductRequest productRequest) async {
    final response = await _httpClient.post(
      '/products/',
      data: productRequest.toJson(), // Changed to named argument
    );
    // Assuming the actual product data is in response.data
    if (response.data != null) {
      return Product.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to create product: No data in response');
    }
  }

  Future<Product> updateProduct(
    int productId,
    ProductRequest productRequest,
  ) async {
    final response = await _httpClient.put(
      '/products/$productId',
      data: productRequest.toJson(), // Changed to named argument
    );
    // Assuming the actual product data is in response.data
    if (response.data != null) {
      return Product.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update product: No data in response');
    }
  }

  Future<void> deleteProduct(int productId) async {
    await _httpClient.delete(
      '/products/$productId',
    ); // Assuming path is relative to baseUrl
  }

  // Renamed to getManagerProducts and updated endpoint
  Future<List<Product>> getManagerProducts({
    int page = 1,
    int pageSize = 10,
    String orderBy = 'name',
    bool descending = false,
  }) async {
    final response = await _httpClient.get(
      '/products/mananger', // Updated endpoint
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'order_by': orderBy,
        'descending': descending,
      },
    );

    if (response.data != null && response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('items') && responseData['items'] is List) {
        final itemsList = responseData['items'] as List;
        return itemsList
            .map(
              (productJson) =>
                  Product.fromJson(productJson as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch manager products: \'items\' key not found or not a list.',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch manager products or invalid data format',
      );
    }
  }
}
