import 'package:get/get.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductApiService _productService;

  // Observable state variables
  final RxList<Product> _products = <Product>[].obs;
  final RxList<Product> _allProducts =
      <Product>[].obs; // Store all products for local filtering
  final RxList<Category> _categories = <Category>[].obs;
  final Rx<PaginationInfo> _pagination =
      PaginationInfo(page: 1, pageSize: 10, totalCount: 0, totalPages: 0).obs;
  final Rx<FilterInfo> _filters =
      FilterInfo(orderBy: 'created_at', descending: true).obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _isInitialDataLoaded = false.obs;

  // Getters for the state
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  PaginationInfo get pagination => _pagination.value;
  FilterInfo get filters => _filters.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isInitialDataLoaded => _isInitialDataLoaded.value;

  // Constructor
  ProductController(this._productService);

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchAllProducts(); // Load all products initially
  }

  // Fetch all products once for local filtering
  Future<void> fetchAllProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _productService.searchProducts(
        page: 1,
        pageSize: 100, // Load a larger number of products
        orderBy: 'created_at',
        descending: true,
      );

      _allProducts.value = result.items;
      _products.value = result.items;
      _pagination.value = result.pagination;
      _filters.value = result.filters;
      _isInitialDataLoaded.value = true;

      print(
        'DEBUG: Loaded ${_allProducts.length} products for local filtering',
      );
    } catch (e) {
      print('DEBUG: Error fetching all products: $e');
      _setError('Error fetching products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch product categories
  Future<void> fetchCategories() async {
    try {
      _setLoading(true);
      final fetchedCategories = await _productService.getCategories();
      _categories.value = fetchedCategories;
      print('DEBUG: Fetched ${fetchedCategories.length} categories');
      for (var category in fetchedCategories) {
        print('DEBUG: Category: ${category.id} - ${category.name}');
      }
    } catch (e) {
      _setError('Error fetching categories: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch products with current pagination and filters
  Future<void> fetchProducts({bool resetPage = false}) async {
    // If we need to use local filtering (for search)
    if (_isInitialDataLoaded.value &&
        (filters.searchQuery != null && filters.searchQuery!.isNotEmpty)) {
      _setLoading(true);

      // Apply local filters
      _applyLocalFilters();

      _setLoading(false);
      return;
    }

    // Otherwise, use the API
    try {
      if (resetPage) {
        _pagination.value = PaginationInfo(
          page: 1,
          pageSize: pagination.pageSize,
          totalCount: 0,
          totalPages: 0,
        );
      }

      print('DEBUG: Fetching products with filters:');
      print('DEBUG: Search query: ${filters.searchQuery}');
      print('DEBUG: Category ID: ${filters.categoryId}');
      print('DEBUG: Price range: ${filters.minPrice} - ${filters.maxPrice}');
      print(
        'DEBUG: Order by: ${filters.orderBy}, Descending: ${filters.descending}',
      );
      print(
        'DEBUG: Page: ${pagination.page}, Page size: ${pagination.pageSize}',
      );

      _setLoading(true);
      _clearError();

      final result = await _productService.searchProducts(
        searchQuery: filters.searchQuery,
        categoryId: filters.categoryId,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        page: pagination.page,
        pageSize: pagination.pageSize,
        orderBy: filters.orderBy,
        descending: filters.descending,
      );

      print('DEBUG: Received ${result.items.length} products');
      for (var product in result.items) {
        print(
          'DEBUG: Product: ${product.productId} - ${product.name} - ${product.price}₫ - Category: ${product.categoryName}',
        );
      }

      print(
        'DEBUG: Pagination - Total count: ${result.pagination.totalCount}, Total pages: ${result.pagination.totalPages}',
      );

      if (resetPage || pagination.page == 1) {
        _products.value = result.items;
      } else {
        // Append new products to existing list for pagination
        _products.addAll(result.items);
      }

      _pagination.value = result.pagination;
      _filters.value = result.filters;
    } catch (e) {
      print('DEBUG: Error fetching products: $e');
      _setError('Error fetching products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load more products (pagination)
  Future<void> loadMoreProducts() async {
    // Check if we're already at the last page
    if (pagination.page >= pagination.totalPages) return;

    // Check if we're already loading more
    if (_isLoadingMore.value) return;

    try {
      _isLoadingMore.value = true;
      print(
        'DEBUG: Loading more products - moving to page ${pagination.page + 1}',
      );

      // If we're using local filtering (search), handle pagination locally
      if (_isInitialDataLoaded.value &&
          (filters.searchQuery != null && filters.searchQuery!.isNotEmpty)) {
        // With local filtering, we've already loaded all products
        // So we don't need to do anything here
        await Future.delayed(
          const Duration(milliseconds: 300),
        ); // Simulate a delay for UX
        _isLoadingMore.value = false;
        return;
      }

      // Otherwise, load next page from API
      // Increment page number
      _pagination.value = PaginationInfo(
        page: pagination.page + 1,
        pageSize: pagination.pageSize,
        totalCount: pagination.totalCount,
        totalPages: pagination.totalPages,
      );

      // Fetch next page
      final result = await _productService.searchProducts(
        searchQuery: filters.searchQuery,
        categoryId: filters.categoryId,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        page: pagination.page,
        pageSize: pagination.pageSize,
        orderBy: filters.orderBy,
        descending: filters.descending,
      );

      print('DEBUG: Loaded ${result.items.length} more products');

      // Append new products to existing list
      _products.addAll(result.items);

      // Update pagination info
      _pagination.value = result.pagination;
    } catch (e) {
      print('DEBUG: Error loading more products: $e');
      _setError('Error loading more products: $e');
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // Apply search filter
  void applySearch(String? query) {
    print('DEBUG: Applying search with query: $query');
    _filters.value = FilterInfo(
      searchQuery: query,
      categoryId: filters.categoryId,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      orderBy: filters.orderBy,
      descending: filters.descending,
    );

    // Use local filtering for search
    if (_isInitialDataLoaded.value) {
      _applyLocalFilters();
    } else {
      // If initial data not loaded yet, try with API
      fetchProducts(resetPage: true);
    }
  }

  // Apply category filter
  void applyCategory(int? categoryId) {
    _filters.value = FilterInfo(
      searchQuery: filters.searchQuery,
      categoryId: categoryId,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      orderBy: filters.orderBy,
      descending: filters.descending,
    );

    // Use local filtering if we have the initial data and search query
    if (_isInitialDataLoaded.value &&
        (filters.searchQuery != null && filters.searchQuery!.isNotEmpty)) {
      _applyLocalFilters();
    } else {
      fetchProducts(resetPage: true);
    }
  }

  // Apply price range filter
  void applyPriceRange(double? minPrice, double? maxPrice) {
    _filters.value = FilterInfo(
      searchQuery: filters.searchQuery,
      categoryId: filters.categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      orderBy: filters.orderBy,
      descending: filters.descending,
    );
    fetchProducts(resetPage: true);
  }

  // Apply sorting
  void applySorting(String orderBy, bool descending) {
    _filters.value = FilterInfo(
      searchQuery: filters.searchQuery,
      categoryId: filters.categoryId,
      minPrice: filters.minPrice,
      maxPrice: filters.maxPrice,
      orderBy: orderBy,
      descending: descending,
    );
    fetchProducts(resetPage: true);
  }

  // Clear all filters
  void clearFilters() {
    _filters.value = FilterInfo(orderBy: 'created_at', descending: true);
    fetchProducts(resetPage: true);
  }

  // Helper methods to update state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
    print('ProductController Error: $message');
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Local filtering for search
  void _applyLocalFilters() {
    // Start with all products
    List<Product> filteredProducts = List.from(_allProducts);

    // Apply search filter if there's a search query
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      final String query = filters.searchQuery!.toLowerCase();
      filteredProducts =
          filteredProducts.where((product) {
            return product.name.toLowerCase().contains(query) ||
                (product.description?.toLowerCase().contains(query) ?? false);
          }).toList();

      print(
        'DEBUG: Local search filtered to ${filteredProducts.length} products with query: $query',
      );
    }

    // Apply category filter if selected
    if (filters.categoryId != null) {
      filteredProducts =
          filteredProducts.where((product) {
            return product.categoryId == filters.categoryId;
          }).toList();

      print(
        'DEBUG: Local category filter applied, ${filteredProducts.length} products remaining',
      );
    }

    // Apply price range filters if set
    if (filters.minPrice != null) {
      filteredProducts =
          filteredProducts.where((product) {
            return product.price >= filters.minPrice!;
          }).toList();
    }

    if (filters.maxPrice != null) {
      filteredProducts =
          filteredProducts.where((product) {
            return product.price <= filters.maxPrice!;
          }).toList();
    }

    // Sort products
    filteredProducts.sort((a, b) {
      // Get the field to sort by
      var aValue, bValue;

      switch (filters.orderBy) {
        case 'price':
          aValue = a.price;
          bValue = b.price;
          break;
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'created_at':
        default:
          // Assume newer products have higher IDs
          aValue = a.productId;
          bValue = b.productId;
      }

      // Apply sort direction
      int comparison = filters.descending ? -1 : 1;

      if (aValue is String && bValue is String) {
        return comparison * aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        return comparison * aValue.compareTo(bValue);
      }

      return 0;
    });

    // Update the displayed products
    _products.value = filteredProducts;

    // Update pagination info
    _pagination.value = PaginationInfo(
      page: 1,
      pageSize: filteredProducts.length,
      totalCount: filteredProducts.length,
      totalPages: 1,
    );
  }
}
