import 'package:get/get.dart';
import '../models/order.dart';
import '../services/order_service.dart';

// For order list items (simplified version of Order for list display)
class OrderListItem {
  final int orderId;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final int itemCount;

  OrderListItem({
    required this.orderId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemCount,
  });

  factory OrderListItem.fromOrder(Order order) {
    return OrderListItem(
      orderId: order.orderId,
      orderDate: order.orderDate,
      totalAmount: order.totalAmount,
      status: order.status,
      itemCount: order.items?.length ?? 0,
    );
  }
}

class OrderController extends GetxController {
  final OrderApiService _orderService;

  // Observable state variables
  final RxList<OrderListItem> _orders = <OrderListItem>[].obs;
  final Rx<Order?> _selectedOrder = Rx<Order?>(null);
  final RxBool _isLoadingList = false.obs;
  final RxBool _isLoadingDetails = false.obs;
  final RxBool _isCancellingOrder = false.obs;
  final RxBool _hasError = false.obs;
  final RxString _errorMessage = ''.obs;

  // Pagination information
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 1.obs;
  final RxInt _pageSize = 10.obs;
  final RxBool _hasMoreOrders = true.obs;

  // Getters for the state
  List<OrderListItem> get orders => _orders;
  Order? get selectedOrder => _selectedOrder.value;
  bool get isLoadingList => _isLoadingList.value;
  bool get isLoadingDetails => _isLoadingDetails.value;
  bool get isCancellingOrder => _isCancellingOrder.value;
  bool get hasError => _hasError.value;
  String get errorMessage => _errorMessage.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  int get pageSize => _pageSize.value;
  bool get hasMoreOrders => _hasMoreOrders.value;

  // Constructor with dependency injection
  OrderController(this._orderService);

  @override
  void onInit() {
    super.onInit();
    // Fetch orders when the controller initializes to show order history immediately
    fetchOrders(refresh: true);
  }

  // Fetch orders list with pagination
  Future<void> fetchOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _hasMoreOrders.value = true;
      }

      if (!_hasMoreOrders.value && !refresh) {
        // No more orders to load
        return;
      }

      _isLoadingList.value = true;
      _clearError();

      final result = await _orderService.getOrdersList(
        page: _currentPage.value,
        pageSize: _pageSize.value,
      );

      // Create OrderListItem objects from the full Order objects
      final orderItems =
          result.map((order) => OrderListItem.fromOrder(order)).toList();

      if (refresh) {
        // Replace the existing orders with the new ones
        _orders.value = orderItems;
      } else {
        // Append the new orders to the existing ones
        _orders.addAll(orderItems);
      }

      // Update pagination state
      if (orderItems.length < _pageSize.value) {
        _hasMoreOrders.value = false;
      } else {
        _currentPage.value++;
      }

      print(
        'DEBUG: Fetched ${orderItems.length} orders, page ${_currentPage.value - 1}',
      );
    } catch (e) {
      _setError('Failed to load orders: $e');
      print('ERROR: Failed to load orders - $e');

      Get.snackbar(
        'Lỗi',
        'Không thể tải lịch sử đơn hàng: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingList.value = false;
    }
  }

  // Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!_isLoadingList.value && _hasMoreOrders.value) {
      await fetchOrders(refresh: false);
    }
  }

  // Fetch details of a specific order
  Future<void> fetchOrderDetails(int orderId) async {
    try {
      _isLoadingDetails.value = true;
      _clearError();

      final order = await _orderService.getOrderDetails(orderId);
      _selectedOrder.value = order;

      print('DEBUG: Fetched details for order $orderId');
    } catch (e) {
      _setError('Failed to load order details: $e');
      print('ERROR: Failed to load order details - $e');

      Get.snackbar(
        'Lỗi',
        'Không thể tải chi tiết đơn hàng: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingDetails.value = false;
    }
  }

  // Cancel an order
  // Future<bool> cancelOrder(int orderId, {String? reason}) async {
  //   try {
  //     _isCancellingOrder.value = true;
  //     _clearError();

  //     final success = await _orderService.cancelOrder(orderId, reason: reason);

  //     if (success) {
  //       // Update the order in the list
  //       final index = _orders.indexWhere((order) => order.orderId == orderId);
  //       if (index >= 0) {
  //         final updatedOrder = _orders[index];
  //         _orders[index] = OrderListItem(
  //           orderId: updatedOrder.orderId,
  //           orderDate: updatedOrder.orderDate,
  //           totalAmount: updatedOrder.totalAmount,
  //           status: 'CANCELLED',
  //           itemCount: updatedOrder.itemCount,
  //         );
  //       }

  //       // Update the selected order if it's the same one
  //       if (_selectedOrder.value?.orderId == orderId) {
  //         _selectedOrder.value = Order(
  //           itemCount: _selectedOrder,
  //           orderId: _selectedOrder.value!.orderId,
  //           userId: _selectedOrder.value!.userId,
  //           orderDate: _selectedOrder.value!.orderDate,
  //           totalAmount: _selectedOrder.value!.totalAmount,
  //           status: 'CANCELLED',
  //           shippingAddress: _selectedOrder.value!.shippingAddress,
  //           paymentMethod: _selectedOrder.value!.paymentMethod,
  //           createdAt: _selectedOrder.value!.createdAt,
  //           updatedAt: DateTime.now(),
  //           items: _selectedOrder.value!.items,
  //         );
  //       }

  //       print('DEBUG: Cancelled order $orderId');

  //       // Show success message
  //       Get.snackbar(
  //         'Hủy đơn hàng thành công',
  //         'Đơn hàng của bạn đã được hủy thành công.',
  //         snackPosition: SnackPosition.BOTTOM,
  //       );

  //       return true;
  //     }

  //     // Show error message
  //     Get.snackbar(
  //       'Hủy đơn hàng thất bại',
  //       'Không thể hủy đơn hàng. Vui lòng thử lại.',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );

  //     return false;
  //   } catch (e) {
  //     _setError('Failed to cancel order: $e');
  //     print('ERROR: Failed to cancel order - $e');

  //     // Show error message
  //     Get.snackbar(
  //       'Hủy đơn hàng thất bại',
  //       'Không thể hủy đơn hàng: ${e.toString()}',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );

  //     return false;
  //   } finally {
  //     _isCancellingOrder.value = false;
  //   }
  // }

  // Clear the selected order
  void clearSelectedOrder() {
    _selectedOrder.value = null;
  }

  // Helper methods to update state
  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }
}
