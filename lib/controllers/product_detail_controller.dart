import 'package:get/get.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/recommendation_service.dart';
import '../controllers/cart_controller.dart';

class ProductDetailController extends GetxController {
  final ProductApiService _productService;

  // Trạng thái Observable
  final Rx<Product?> _product = Rx<Product?>(null);
  final RxList<Product> _relatedProducts = <Product>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isRelatedLoading = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Add loading state for add to cart
  final RxBool _isAddingToCart = false.obs;

  // Getters cho trạng thái
  Product? get product => _product.value;
  List<Product> get relatedProducts => _relatedProducts;
  bool get isLoading => _isLoading.value;
  bool get isRelatedLoading => _isRelatedLoading.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isAddingToCart => _isAddingToCart.value;

  // Constructor
  ProductDetailController(this._productService);

  // Lấy recommendation service từ Get
  RecommendationApiService get _recommendationService =>
      Get.find<RecommendationApiService>();

  // Lấy cart controller từ Get
  CartController get _cartController => Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();

  }

  @override
  void onClose() {
    // Dọn dẹp tài nguyên khi controller bị hủy
    _product.value = null;
    _relatedProducts.clear();
    super.onClose();
  }

  // Lấy thông tin chi tiết sản phẩm theo ID
  Future<void> fetchProductById(int productId) async {
    try {
      _setLoading(true);
      _clearError();

      final product = await _productService.getProductById(productId);
      _product.value = product;

      print('DEBUG: Fetched product: ${product.name}');

      // Sau khi lấy chi tiết sản phẩm, lấy các sản phẩm tương tự thay vì liên quan
      fetchRelatedProducts();
    } catch (e) {
      print('DEBUG: Error fetching product: $e');
      _setError('Error fetching product: $e');
      _product.value = null;
    } finally {
      _setLoading(false);
    }
  }

  // Lấy các sản phẩm tương tự sử dụng RecommendationApiService
  Future<void> fetchRelatedProducts() async {
    if (_product.value == null) return;

    try {
      _isRelatedLoading.value = true;

      // Lấy ID của sản phẩm hiện tại
      final productId = _product.value!.productId;

      // Sử dụng recommendation service để lấy sản phẩm tương tự
      final similarProducts = await _recommendationService.getSimilarProducts(
        productId,
        limit: 5,
      );

      _relatedProducts.value = similarProducts;

      print('DEBUG: Fetched ${_relatedProducts.length} similar products');
    } catch (e) {
      print('DEBUG: Error fetching similar products: $e');
      // Không hiển thị lỗi này cho người dùng, chỉ log ra console
    } finally {
      _isRelatedLoading.value = false;
    }
  }

  // Kiểm tra sản phẩm có trong danh sách yêu thích không
  bool isProductInFavorites(int productId) {
    // TODO: Implement favorites feature
    return false;
  }

  // Thêm vào giỏ hàng
  Future<void> addToCart() async {
    if (_product.value == null) return;

    try {
      _isAddingToCart.value = true;

      final productId = _product.value!.productId;
      final quantity = 1; // Default quantity

      final success = await _cartController.addToCart(productId, quantity);

      if (!success) {
        Get.snackbar(
          'Lỗi',
          'Không thể thêm sản phẩm vào giỏ hàng. Vui lòng thử lại sau.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('DEBUG: Error adding to cart: $e');
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi thêm vào giỏ hàng: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isAddingToCart.value = false;
    }
  }

  // Helper methods để cập nhật trạng thái
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }
}
