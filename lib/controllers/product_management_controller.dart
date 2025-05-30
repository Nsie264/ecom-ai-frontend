import 'package:ecom_ai_frontend/models/product.dart';
import 'package:ecom_ai_frontend/models/product_request.dart';
import 'package:ecom_ai_frontend/services/product_management_service.dart';
import 'package:get/get.dart';

class ProductManagementController extends GetxController {
  final ProductManagementService _productManagementService =
      ProductManagementService();
  var _allProducts = <Product>[].obs; // Stores all fetched products
  var isLoading = false.obs;
  var searchQuery = ''.obs; // For search functionality
  var activeFilter =
      Rxn<
        bool
      >(); // For filtering by isActive: null (all), true (active), false (inactive)

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  List<Product> get filteredProducts {
    // Start with a fresh copy of all products for filtering
    List<Product> productsToShow = _allProducts.toList();

    if (searchQuery.value.isNotEmpty) {
      productsToShow =
          productsToShow
              .where(
                (product) => product.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();
    }

    if (activeFilter.value != null) {
      productsToShow =
          productsToShow
              .where((product) => product.isActive == activeFilter.value)
              .toList();
    }
    return productsToShow;
  }

  Future<void> fetchProducts({
    int page = 1,
    int pageSize = 100,
    String orderBy = 'name',
    bool descending = false,
  }) async {
    try {
      isLoading.value = true;
      final productList = await _productManagementService.getManagerProducts(
        page: page,
        pageSize: pageSize,
        orderBy: orderBy,
        descending: descending,
      );
      _allProducts.assignAll(productList);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct(ProductRequest productRequest) async {
    try {
      isLoading.value = true;
      final newProduct = await _productManagementService.createProduct(
        productRequest,
      );
      _allProducts.add(newProduct); // Add to the main list
      // Optionally, clear search/filter or navigate
      Get.snackbar('Success', 'Product created successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(
    int productId,
    ProductRequest productRequest,
  ) async {
    try {
      isLoading.value = true;
      final updatedProduct = await _productManagementService.updateProduct(
        productId,
        productRequest,
      );
      final index = _allProducts.indexWhere((p) => p.productId == productId);
      if (index != -1) {
        _allProducts[index] = updatedProduct; // Update in the main list
      }
      Get.snackbar('Success', 'Product updated successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      await _productManagementService.deleteProduct(productId);
      _allProducts.removeWhere(
        (p) => p.productId == productId,
      ); // Remove from the main list
      Get.snackbar('Success', 'Product deleted successfully');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
