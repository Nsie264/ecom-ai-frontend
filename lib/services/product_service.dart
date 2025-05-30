import 'package:dio/dio.dart';
import '../utils/http_client.dart';
import '../models/product.dart';
import '../models/category.dart';

class ProductApiService {
  final HttpClient _httpClient;

  ProductApiService(this._httpClient);

  /// Searches for products with optional filters
  ///
  /// Parameters:
  /// - searchQuery: Optional text search term
  /// - categoryId: Optional category filter
  /// - minPrice: Optional minimum price filter
  /// - maxPrice: Optional maximum price filter
  /// - page: Page number (starts at 1)
  /// - pageSize: Number of results per page
  /// - orderBy: Field to sort by (default: created_at)
  /// - descending: Sort order (default: true/descending)
  Future<ProductSearchResult> searchProducts({
    String? searchQuery,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int pageSize = 10,
    String orderBy = 'created_at',
    bool descending = true,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        'order_by': orderBy,
        'descending': descending.toString(),
      };

      // Add optional filters if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      final response = await _httpClient.get(
        '/products/',
        queryParameters: queryParams,
      );

      return ProductSearchResult.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to search products');
      rethrow;
    }
  }

  /// Get detailed information about a specific product
  Future<Product> getProductDetails(int productId) async {
    try {
      final response = await _httpClient.get('/products/$productId');
      return Product.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to get product details');
      rethrow;
    }
  }

  // Fetch a specific product by ID
  Future<Product> getProductById(int productId) async {
    try {
      final response = await _httpClient.get('/products/$productId');

      if (response.statusCode == 200) {
        // Print the response data structure for debugging
        print('DEBUG: Product API response: ${response.data}');

        // Check if the response data is directly a Map or has a data field
        if (response.data is Map<String, dynamic>) {
          // If the data is directly in response.data (no nested 'data' field)
          if (response.data.containsKey('data')) {
            // Handle case where data is in a nested 'data' field
            return Product.fromJson(response.data['data']);
          } else {
            // Handle case where data is directly in the response
            return Product.fromJson(response.data);
          }
        } else {
          throw Exception(
            'Invalid response format: ${response.data.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error when loading product: ${e.message}');
    } catch (e) {
      throw Exception('Error loading product: $e');
    }
  }

  /// Get all product categories in tree structure
  Future<List<Category>> getCategories() async {
    try {
      final response = await _httpClient.get('/products/categories/tree');

      return (response.data as List)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to get categories');
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

/// Class to handle the search results with pagination information
class ProductSearchResult {
  final List<Product> items;
  final PaginationInfo pagination;
  final FilterInfo filters;

  ProductSearchResult({
    required this.items,
    required this.pagination,
    required this.filters,
  });

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      items:
          (json['items'] as List)
              .map((item) => Product.fromJson(item))
              .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
      filters: FilterInfo.fromJson(json['filters']),
    );
  }
}

/// Pagination information for search results
class PaginationInfo {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'],
      pageSize: json['page_size'],
      totalCount: json['total_count'],
      totalPages: json['total_pages'],
    );
  }
}

/// Filter information for the current search
class FilterInfo {
  final String? searchQuery;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String orderBy;
  final bool descending;

  FilterInfo({
    this.searchQuery,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    required this.orderBy,
    required this.descending,
  });

  factory FilterInfo.fromJson(Map<String, dynamic> json) {
    return FilterInfo(
      searchQuery: json['search_query'],
      categoryId: json['category_id'],
      minPrice: json['min_price'],
      maxPrice: json['max_price'],
      orderBy: json['order_by'],
      descending: json['descending'],
    );
  }
}
