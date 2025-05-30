// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/order_controller.dart';

// class OrderSuccessScreen extends StatefulWidget {
//   final int orderId;

//   const OrderSuccessScreen({
//     Key? key,
//     required this.orderId,
//   }) : super(key: key);

//   @override
//   State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
// }

// class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
//   final OrderController orderController = Get.find<OrderController>();

//   @override
//   void initState() {
//     super.initState();
//     // Tải chi tiết đơn hàng để hiển thị
//     orderController.fetchOrderDetails(widget.orderId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Đặt hàng thành công'),
//         // Không cho phép quay lại màn hình checkout
//         automaticallyImplyLeading: false,
//       ),
//       body: Obx(() {
//         if (orderController.isLoadingDetails) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final order = orderController.selectedOrder;
//         if (order == null) {
//           return const Center(
//             child: Text('Không tìm thấy thông tin đơn hàng'),
//           );
//         }

//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 24),
//                 // Success icon
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.check_circle,
//                     color: Colors.green[700],
//                     size: 80,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Success message
//                 const Text(
//                   'Đơn hàng đã được đặt thành công!',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Mã đơn hàng: #${order.orderId}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Order details card
//                 Card(
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Tóm tắt đơn hàng',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         _buildOrderInfoRow('Ngày đặt', _formatDate(order.orderDate)),
//                         _buildOrderInfoRow('Trạng thái', _getStatusText(order.status)),
//                         _buildOrderInfoRow(
//                           'Tổng tiền',
//                           '${_formatCurrency(order.totalAmount)} đ',
//                         ),
//                         _buildOrderInfoRow(
//                           'Phương thức thanh toán',
//                           order.paymentMethod == 'COD'
//                               ? 'Thanh toán khi nhận hàng'
//                               : order.paymentMethod,
//                         ),
//                         const Divider(height: 32),
//                         const Text(
//                           'Địa chỉ giao hàng',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _formatAddress(order.shippingAddress),
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Actions
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     OutlinedButton(
//                       onPressed: () {
//                         // Navigate to order details screen
//                         Get.toNamed('/orders/${order.orderId}');
//                       },
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: const Text('Chi tiết đơn hàng'),
//                     ),
//                     const SizedBox(width: 16),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Navigate to home screen
//                         Get.offAllNamed('/');
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       child: const Text('Tiếp tục mua sắm'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildOrderInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }

//   String _getStatusText(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return 'Chờ xử lý';
//       case 'CONFIRMED':
//         return 'Đã xác nhận';
//       case 'SHIPPING':
//         return 'Đang giao hàng';
//       case 'DELIVERED':
//         return 'Đã giao hàng';
//       case 'CANCELLED':
//         return 'Đã hủy';
//       default:
//         return status;
//     }
//   }

//   String _formatAddress(Map<String, dynamic> address) {
//     final street = address['street'] as String;
//     final city = address['city'] as String;
//     final country = address['country'] as String;
    
//     return '$street, $city, $country';
//   }

//   String _formatCurrency(double amount) {
//     return amount.toStringAsFixed(0).replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         );
//   }
// }