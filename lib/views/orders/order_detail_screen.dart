// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/order_controller.dart';
// import '../../models/order.dart';

// class OrderDetailScreen extends StatefulWidget {
//   const OrderDetailScreen({Key? key}) : super(key: key);

//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }

// class _OrderDetailScreenState extends State<OrderDetailScreen> {
//   final OrderController orderController = Get.find<OrderController>();

//   @override
//   void initState() {
//     super.initState();
//     // If order details aren't loaded yet, fetch them
//     final orderId = Get.arguments as int;
//     if (orderController.selectedOrder?.orderId != orderId) {
//       orderController.fetchOrderDetails(orderId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chi tiết đơn hàng'), elevation: 0),
//       body: Obx(() {
//         if (orderController.isLoadingDetails) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (orderController.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Lỗi: ${orderController.errorMessage}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: () {
//                     final orderId = Get.arguments as int;
//                     orderController.fetchOrderDetails(orderId);
//                   },
//                   child: const Text('Thử lại'),
//                 ),
//               ],
//             ),
//           );
//         }

//         final order = orderController.selectedOrder;
//         if (order == null) {
//           return const Center(child: Text('Không tìm thấy thông tin đơn hàng'));
//         }

//         return _buildOrderDetails(order);
//       }),
//     );
//   }

//   Widget _buildOrderDetails(Order order) {
//     final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildOrderStatusCard(order),
//           const SizedBox(height: 24),
//           _buildSectionHeading('Sản phẩm trong đơn hàng'),
//           if (order.items != null && order.items!.isNotEmpty)
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: order.items!.length,
//               itemBuilder: (context, index) {
//                 final item = order.items![index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Row(
//                       children: [
//                         // Product image if available
//                         if (item.product.imageUrl != null)
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Image.network(
//                               item.product.imageUrl!,
//                               width: 60,
//                               height: 60,
//                               fit: BoxFit.cover,
//                               errorBuilder:
//                                   (_, __, ___) => Container(
//                                     width: 60,
//                                     height: 60,
//                                     color: Colors.grey[200],
//                                     child: const Icon(
//                                       Icons.image_not_supported,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                             ),
//                           )
//                         else
//                           Container(
//                             width: 60,
//                             height: 60,
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.image, color: Colors.grey),
//                           ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.product.name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 '${_formatCurrency(item.priceAtPurchase)}₫ × ${item.quantity}',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '${_formatCurrency(item.total)}₫',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             )
//           else
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(24.0),
//                 child: Text('Không có thông tin sản phẩm'),
//               ),
//             ),

//           const SizedBox(height: 24),
//           _buildSectionHeading('Thông tin giao hàng'),
//           _buildInfoCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoRow('Địa chỉ:', '${order.shippingAddress['street']}'),
//                 _buildInfoRow('Thành phố:', '${order.shippingAddress['city']}'),
//                 if (order.shippingAddress['state'] != null)
//                   _buildInfoRow(
//                     'Tỉnh/Thành:',
//                     '${order.shippingAddress['state']}',
//                   ),
//                 _buildInfoRow(
//                   'Quốc gia:',
//                   '${order.shippingAddress['country']}',
//                 ),
//                 if (order.shippingAddress['postal_code'] != null)
//                   _buildInfoRow(
//                     'Mã bưu điện:',
//                     '${order.shippingAddress['postal_code']}',
//                   ),
//                 if (order.shippingAddress['phone'] != null)
//                   _buildInfoRow(
//                     'Điện thoại:',
//                     '${order.shippingAddress['phone']}',
//                   ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),
//           _buildSectionHeading('Thông tin thanh toán'),
//           _buildInfoCard(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildInfoRow(
//                   'Phương thức:',
//                   order.paymentMethod == 'COD'
//                       ? 'Thanh toán khi nhận hàng (COD)'
//                       : order.paymentMethod,
//                 ),
//                 _buildInfoRow(
//                   'Tổng tiền hàng:',
//                   '${_formatCurrency(order.totalAmount)}₫',
//                 ),
//               ],
//             ),
//           ),

//           if (order.status.toUpperCase() == 'PENDING' ||
//               order.status.toUpperCase() == 'PROCESSING')
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 24),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () => _showCancelDialog(order.orderId),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: Colors.red,
//                     side: const BorderSide(color: Colors.red),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text('HỦY ĐƠN HÀNG'),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderStatusCard(Order order) {
//     // Create colorful status indicator based on order status
//     Color statusColor;
//     IconData statusIcon;

//     switch (order.status.toUpperCase()) {
//       case 'PENDING':
//         statusColor = Colors.orange;
//         statusIcon = Icons.hourglass_empty;
//         break;
//       case 'PROCESSING':
//         statusColor = Colors.blue;
//         statusIcon = Icons.inventory;
//         break;
//       case 'SHIPPED':
//         statusColor = Colors.green;
//         statusIcon = Icons.local_shipping;
//         break;
//       case 'DELIVERED':
//         statusColor = Colors.green.shade700;
//         statusIcon = Icons.check_circle;
//         break;
//       case 'CANCELLED':
//         statusColor = Colors.red;
//         statusIcon = Icons.cancel;
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusIcon = Icons.help_outline;
//     }

//     final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

//     return Card(
//       elevation: 0,
//       color: statusColor.withOpacity(0.1),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(statusIcon, color: statusColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   _translateStatus(order.status),
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow('Mã đơn hàng:', '#${order.orderId}'),
//             _buildInfoRow('Ngày đặt:', dateFormat.format(order.orderDate)),
//             _buildInfoRow('Cập nhật:', dateFormat.format(order.updatedAt)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeading(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   Widget _buildInfoCard({required Widget child}) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(padding: const EdgeInsets.all(16), child: child),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(color: Colors.grey[700], fontSize: 14),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showCancelDialog(int orderId) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Hủy đơn hàng'),
//         content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text('KHÔNG')),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               orderController.cancelOrder(orderId).then((success) {
//                 if (success) Get.back(); // Return to order history
//               });
//             },
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('HỦY ĐƠN HÀNG'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper function to translate order status to Vietnamese
//   String _translateStatus(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return 'Chờ xác nhận';
//       case 'PROCESSING':
//         return 'Đang xử lý';
//       case 'SHIPPED':
//         return 'Đang giao hàng';
//       case 'DELIVERED':
//         return 'Đã giao hàng';
//       case 'CANCELLED':
//         return 'Đã hủy';
//       default:
//         return status;
//     }
//   }

//   // Format currency helper function
//   String _formatCurrency(double amount) {
//     return amount
//         .toStringAsFixed(0)
//         .replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         );
//   }
// }
