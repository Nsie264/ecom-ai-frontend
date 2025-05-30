import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';

class CartController extends GetxController {
  final CartApiService _cartService;
  final AuthApiService _authService;
  final OrderApiService _orderService;

  // Observable state variables
  final RxList<CartItem> _cartItems = <CartItem>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isAdding = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isRemoving = false.obs;
  final RxDouble _cartTotal = 0.0.obs;
  final RxInt _cartItemCount = 0.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Order processing
  final RxBool _isProcessingOrder = false.obs;
  final RxList<Address> _userAddresses = <Address>[].obs;
  final Rx<Address?> _selectedAddress = Rx<Address?>(null);
  final RxBool _isLoadingAddresses = false.obs;

  // IDs của items đang được xử lý
  final RxInt _updatingItemId = (-1).obs;
  final RxInt _removingItemId = (-1).obs;

  // Getters for the state
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading.value;
  bool get isAdding => _isAdding.value;
  bool get isUpdating => _isUpdating.value;
  bool get isRemoving => _isRemoving.value;
  double get cartTotal => _cartTotal.value;
  int get cartItemCount => _cartItemCount.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  bool get isEmpty => _cartItems.isEmpty;

  // Order related getters
  bool get isProcessingOrder => _isProcessingOrder.value;
  List<Address> get addresses => _userAddresses;
  Address? get selectedAddress => _selectedAddress.value;
  bool get isLoadingAddresses => _isLoadingAddresses.value;

  // Getters cho item IDs đang được xử lý
  int get updatingItemId => _updatingItemId.value;
  int get removingItemId => _removingItemId.value;

  // Constructor with dependency injection
  CartController(this._cartService, this._authService, this._orderService);

  @override
  void onInit() {
    super.onInit();
    print('DEBUG: CartController.onInit() called');
    fetchCart();
  }

  // Fetch all cart items from the API
  Future<void> fetchCart() async {
    print('DEBUG: CartController.fetchCart() started');
    try {
      _setLoading(true);
      _clearError();

      print('DEBUG: About to call _cartService.getCart()');
      final items = await _cartService.getCart();
      print('DEBUG: _cartService.getCart() returned ${items.length} items');

      _cartItems.value = items;

      // Calculate totals
      _updateCartTotals();

      print('DEBUG: Fetched ${items.length} cart items');
    } catch (e) {
      print('DEBUG: Exception in fetchCart(): $e');
      _setError('Failed to load cart: $e');
      print('ERROR: Failed to load cart - $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add an item to the cart
  Future<bool> addToCart(int productId, int quantity) async {
    try {
      _isAdding.value = true;
      _clearError();

      final newItem = await _cartService.addToCart(productId, quantity);

      // Check if the item already exists in the cart
      final existingIndex = _cartItems.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex >= 0) {
        // Update the existing item
        _cartItems[existingIndex] = newItem;
      } else {
        // Add the new item
        _cartItems.add(newItem);
      }

      // Update totals
      _updateCartTotals();

      Get.snackbar(
        'Đã thêm vào giỏ hàng',
        'Sản phẩm đã được thêm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('DEBUG: Added product $productId to cart, quantity: $quantity');
      return true;
    } catch (e) {
      _setError('Failed to add item to cart: $e');
      print('ERROR: Failed to add item to cart - $e');

      Get.snackbar(
        'Lỗi',
        'Không thể thêm sản phẩm vào giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      _isAdding.value = false;
    }
  }

  // Update the quantity of an item in the cart
  Future<bool> updateItemQuantity(int cartItemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        return removeItemFromCart(cartItemId);
      }

      // Don't show loading indicator, just track which item is being updated
      _updatingItemId.value = cartItemId;
      _clearError();

      try {
        // Call the API to update the quantity
        await _cartService.updateCartItem(cartItemId, newQuantity);

        // Silent refresh - fetch cart without showing loading indicator
        await _silentFetchCart();

        return true;
      } catch (apiError) {
        print('DEBUG: API error in updateItemQuantity: $apiError');

        // Silent refresh without showing loading
        await _silentFetchCart();
        return false;
      }
    } catch (e) {
      _setError('Failed to update cart item: $e');
      // Silent refresh without showing loading
      await _silentFetchCart();
      return false;
    } finally {
      _updatingItemId.value = -1;
    }
  }

  // Remove an item from the cart
  Future<bool> removeItemFromCart(int cartItemId) async {
    try {
      // Don't show loading indicator, just track which item is being removed
      _removingItemId.value = cartItemId;
      _clearError();

      try {
        // Call the API to remove the item
        await _cartService.removeFromCart(cartItemId);

        // Silent refresh - fetch cart without showing loading indicator
        await _silentFetchCart();

        return true;
      } catch (apiError) {
        print('DEBUG: API error in removeItemFromCart: $apiError');

        // Silent refresh without showing loading
        await _silentFetchCart();
        return false;
      }
    } catch (e) {
      _setError('Failed to remove item from cart: $e');
      // Silent refresh without showing loading
      await _silentFetchCart();
      return false;
    } finally {
      _removingItemId.value = -1;
    }
  }

  // Clear the entire cart - still show loading here since it's a full operation
  Future<bool> clearCart() async {
    try {
      _setLoading(true);
      _clearError();

      try {
        // Remove each item one by one
        final itemsToRemove = List<CartItem>.from(_cartItems);

        for (var item in itemsToRemove) {
          await _cartService.removeFromCart(item.cartItemId);
        }

        // Always reload the entire cart data
        await _silentFetchCart();

        Get.snackbar(
          'Giỏ hàng trống',
          'Tất cả sản phẩm đã được xóa khỏi giỏ hàng',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      } catch (apiError) {
        print('DEBUG: API error in clearCart: $apiError');

        // Silent refresh without showing loading
        await _silentFetchCart();
        return false;
      }
    } catch (e) {
      _setError('Failed to clear cart: $e');
      // Silent refresh without showing loading
      await _silentFetchCart();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Order related functions

  // Fetch user addresses
  Future<void> fetchAddresses() async {
    try {
      _isLoadingAddresses.value = true;
      final addresses = await _authService.getUserAddresses();
      _userAddresses.value = addresses;

      // Set default address if available
      if (addresses.isNotEmpty) {
        final defaultAddress = addresses.firstWhereOrNull(
          (addr) => addr.isDefault,
        );
        _selectedAddress.value = defaultAddress ?? addresses.first;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải địa chỉ: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingAddresses.value = false;
    }
  }

  // Select an address
  void selectAddress(Address address) {
    _selectedAddress.value = address;
  }

  // Add a new address
  Future<bool> addAddress(Address address) async {
    try {
      _isLoadingAddresses.value = true;
      final addedAddress = await _authService.addAddress(address);
      _userAddresses.add(addedAddress);

      // Set as selected if it's the first one or is default
      if (_userAddresses.length == 1 || address.isDefault) {
        _selectedAddress.value = addedAddress;
      }

      return true;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể thêm địa chỉ: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoadingAddresses.value = false;
    }
  }

  // Create an order
  Future<Order?> createOrder() async {
    if (selectedAddress == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn địa chỉ giao hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    _isProcessingOrder.value = true;

    try {
      // Create the order using the selected address ID
      final Order result = await _orderService.createOrder(
        addressId: selectedAddress!.addressId!,
        // Optionally include notes if needed
        // notes: "Additional notes for this order"
      );

      // Show success message
      Get.snackbar(
        'Thành công',
        'Đặt hàng thành công! Mã đơn hàng: ${result.orderId}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Refresh cart after successful order
      await fetchCart();

      return result;
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi khi đặt hàng: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      _isProcessingOrder.value = false;
    }
  }

  // Silent fetch that doesn't show loading indicator
  Future<void> _silentFetchCart() async {
    try {
      _clearError();
      final items = await _cartService.getCart();
      _cartItems.value = items;
      _updateCartTotals();
    } catch (e) {
      print('DEBUG: Exception in _silentFetchCart(): $e');
      _setError('Failed to load cart: $e');
    }
  }

  // Helper method to update cart totals
  void _updateCartTotals() {
    double total = 0;
    int itemCount = 0;

    for (var item in _cartItems) {
      total += item.subtotal; // Use subtotal from the server response
      itemCount += item.quantity;
    }

    _cartTotal.value = total;
    _cartItemCount.value = itemCount;

    print('DEBUG: Cart updated - Total: $total, Items: $itemCount');
  }

  // Helper method to format currency
  String formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  // Helper methods to update state
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
