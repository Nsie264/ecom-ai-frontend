import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item.dart';
import '../../models/address.dart';
import '../../models/order.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DEBUG: CartScreen.build() called');
    final CartController cartController = Get.find<CartController>();
    print('DEBUG: CartScreen found CartController: ${cartController.hashCode}');

    // Force refresh cart data when screen is opened
    print('DEBUG: CartScreen manually calling fetchCart()');
    cartController.fetchCart();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        // actions: [
        //   Obx(
        //     () =>
        //         cartController.isEmpty
        //             ? const SizedBox.shrink()
        //             : IconButton(
        //               icon: const Icon(Icons.delete_sweep),
        //               onPressed:
        //                   () => _showClearCartConfirmation(
        //                     context,
        //                     cartController,
        //                   ),
        //             ),
        //   ),
        // ],
      ),
      body: Obx(() {
        if (cartController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartController.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${cartController.errorMessage}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => cartController.fetchCart(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (cartController.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Giỏ hàng của bạn đang trống',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tiếp tục mua sắm'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartController.cartItems.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final cartItem = cartController.cartItems[index];
                  return _buildCartItem(context, cartItem, cartController);
                },
              ),
            ),
            _buildCartSummary(context, cartController),
          ],
        );
      }),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem cartItem,
    CartController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child:
                    cartItem.imageUrl != null
                        ? Image.network(
                          cartItem.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),

            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    cartItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Product price
                  Text(
                    '${cartItem.price.toStringAsFixed(0)}₫',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Subtotal (if quantity > 1)
                  if (cartItem.quantity > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Tổng: ${cartItem.subtotal.toStringAsFixed(0)}₫',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Quantity controls and delete button
                  Row(
                    children: [
                      _buildQuantityControl(context, cartItem, controller),
                      const Spacer(),

                      Obx(
                        () =>
                            controller.removingItemId == cartItem.cartItemId
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => controller.removeItemFromCart(
                                        cartItem.productId,
                                      ),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(
    BuildContext context,
    CartItem cartItem,
    CartController controller,
  ) {
    return Obx(() {
      final isUpdating = controller.updatingItemId == cartItem.cartItemId;

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            InkWell(
              onTap:
                  isUpdating
                      ? null
                      : () => controller.updateItemQuantity(
                        cartItem.productId,
                        cartItem.quantity - 1,
                      ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Icon(Icons.remove, size: 18),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!),
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child:
                  isUpdating
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text(
                        '${cartItem.quantity}',
                        style: const TextStyle(fontSize: 16),
                      ),
            ),

            InkWell(
              onTap:
                  isUpdating
                      ? null
                      : () => controller.updateItemQuantity(
                        cartItem.productId,
                        cartItem.quantity + 1,
                      ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCartSummary(BuildContext context, CartController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng cộng:', style: TextStyle(fontSize: 18)),
                Obx(
                  () => Text(
                    '${controller.cartTotal.toStringAsFixed(0)}₫',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed:
                    controller.isEmpty
                        ? null
                        : () => _showOrderConfirmation(context, controller),
                child: const Text(
                  'THANH TOÁN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartConfirmation(
    BuildContext context,
    CartController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('HỦY')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearCart();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('XÓA'),
          ),
        ],
      ),
    );
  }

  // New method to show order confirmation dialog
  void _showOrderConfirmation(BuildContext context, CartController controller) {
    // First fetch addresses
    controller.fetchAddresses();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Xác nhận đơn hàng',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // Order summary
              const Text(
                'Tóm tắt đơn hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Obx(
                () => Text(
                  'Tổng số sản phẩm: ${controller.cartItemCount}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),

              const SizedBox(height: 4),

              Obx(
                () => Text(
                  'Tổng tiền: ${controller.formatCurrency(controller.cartTotal)}₫',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              const Divider(height: 24),

              // Address selection
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Obx(() {
                if (controller.isLoadingAddresses) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.addresses.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bạn chưa có địa chỉ giao hàng nào',
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed:
                            () => _showAddAddressDialog(context, controller),
                        child: const Text('Thêm địa chỉ mới'),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Address>(
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      value: controller.selectedAddress,
                      items:
                          controller.addresses.map((address) {
                            return DropdownMenuItem<Address>(
                              value: address,
                              child: Text(
                                '${address.street}, ${address.city}, ${address.country}',
                              ),
                            );
                          }).toList(),
                      onChanged: (Address? newValue) {
                        if (newValue != null) {
                          controller.selectAddress(newValue);
                        }
                      },
                    ),
                    TextButton(
                      onPressed:
                          () => _showAddAddressDialog(context, controller),
                      child: const Text('+ Thêm địa chỉ mới'),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 16),

              // Payment method
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // For simplicity, only COD is available
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.money, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thanh toán khi nhận hàng (COD)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Thanh toán bằng tiền mặt khi nhận hàng',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('HỦY'),
                  ),
                  const SizedBox(width: 16),
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isProcessingOrder
                              ? null
                              : () => _processOrder(context, controller),
                      child:
                          controller.isProcessingOrder
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('XÁC NHẬN ĐẶT HÀNG'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show add address dialog
  void _showAddAddressDialog(BuildContext context, CartController controller) {
    final formKey = GlobalKey<FormState>();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final countryController = TextEditingController();
    final postalCodeController = TextEditingController();
    final phoneController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thêm địa chỉ mới',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa chỉ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'Thành phố',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập thành phố';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(
                    labelText: 'Tỉnh',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(
                    labelText: 'Quốc gia',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập quốc gia';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã bưu điện',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('HỦY'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final address = Address(
                            street: streetController.text,
                            city: cityController.text,
                            state:
                                stateController.text.isEmpty
                                    ? null
                                    : stateController.text,
                            country: countryController.text,
                            postalCode:
                                postalCodeController.text.isEmpty
                                    ? null
                                    : postalCodeController.text,
                            phone:
                                phoneController.text.isEmpty
                                    ? null
                                    : phoneController.text,
                            isDefault: controller.addresses.isEmpty,
                          );

                          controller.addAddress(address).then((success) {
                            if (success) {
                              Get.back();
                            }
                          });
                        }
                      },
                      child: const Text('THÊM ĐỊA CHỈ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Process the order
  void _processOrder(BuildContext context, CartController controller) async {
    if (controller.selectedAddress == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn địa chỉ giao hàng',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Order? result = await controller.createOrder();

    if (result != null) {
      Get.back(); // Close the dialog

      // Show success dialog
      Get.dialog(
        AlertDialog(
          title: const Text('Đặt hàng thành công'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cảm ơn bạn đã đặt hàng!'),
              const SizedBox(height: 8),
              Text('Mã đơn hàng: #${result.orderId}'),
              const SizedBox(height: 8),
              Text(
                'Tổng tiền: ${controller.formatCurrency(result.totalAmount)}₫',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                // Optionally navigate to order history screen
                Get.toNamed('/orders');
              },
              child: const Text('XEM ĐƠN HÀNG'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();

              },
              child: const Text('QUAY LẠI GIỎ HÀNG'),
            ),
          ],
        ),
      );
    }
  }
}
