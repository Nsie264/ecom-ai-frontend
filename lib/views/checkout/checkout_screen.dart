// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/checkout_controller.dart';
// import '../../models/address.dart';
// import '../../services/auth_service.dart';
// import '../../services/order_service.dart';
// import '../../utils/http_client.dart';
// import '../checkout/checkout_success_screen.dart';

// class CheckoutScreen extends StatelessWidget {
//   final double totalAmount;
//   final List<Map<String, dynamic>>? orderItems;

//   const CheckoutScreen({Key? key, required this.totalAmount, this.orderItems})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller with services
//     final checkoutController = Get.put(
//       CheckoutController(
//         orderService: OrderApiService(Get.find<HttpClient>()),
//         authService: AuthApiService(Get.find<HttpClient>()),
//         totalAmount: totalAmount,
//         orderItems: orderItems,
//       ),
//     );

//     return Scaffold(
//       appBar: AppBar(title: const Text('Thanh toán'), elevation: 0),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildTotalAmount(checkoutController),
//                     const SizedBox(height: 24),
//                     _buildAddressSection(checkoutController),
//                     const SizedBox(height: 24),
//                     _buildPaymentMethodSection(checkoutController),
//                   ],
//                 ),
//               ),
//             ),
//             _buildCheckoutButton(checkoutController),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalAmount(CheckoutController controller) {
//     return Card(
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.shopping_cart, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text(
//                   'Tổng thanh toán',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Tổng cộng:', style: TextStyle(fontSize: 16)),
//                 Text(
//                   '${controller.formatCurrency(totalAmount)}₫',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddressSection(CheckoutController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'Địa chỉ giao hàng',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.add, size: 16),
//               label: const Text('Thêm địa chỉ mới'),
//               onPressed: () => _showAddAddressDialog(controller),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Obx(() {
//           if (controller.isLoadingAddresses) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }

//           if (controller.addresses.isEmpty) {
//             return const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20),
//               child: Center(
//                 child: Text(
//                   'Vui lòng thêm địa chỉ giao hàng',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             );
//           }

//           return Column(
//             children:
//                 controller.addresses.map((address) {
//                   final isSelected =
//                       controller.selectedAddress?.addressId ==
//                       address.addressId;
//                   return AddressCard(
//                     address: address,
//                     isSelected: isSelected,
//                     onTap: () {
//                       controller.selectAddress(address);
//                     },
//                   );
//                 }).toList(),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildPaymentMethodSection(CheckoutController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Phương thức thanh toán',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 12),
//         Card(
//           elevation: 0,
//           shape: RoundedRectangleBorder(
//             side: BorderSide(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.orange[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     Icons.payments_outlined,
//                     color: Colors.orange[800],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Thanh toán khi nhận hàng (COD)',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'Thanh toán bằng tiền mặt khi nhận được hàng',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Obx(
//                   () => Radio<String>(
//                     value: 'COD',
//                     groupValue: controller.paymentMethod,
//                     onChanged: (value) {
//                       // Always COD, but we could add more options later
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCheckoutButton(CheckoutController controller) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Obx(
//         () => ElevatedButton(
//           onPressed:
//               controller.isProcessing || controller.selectedAddress == null
//                   ? null
//                   : () => _processOrder(controller),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             backgroundColor: Colors.blue,
//             disabledBackgroundColor: Colors.grey[400],
//           ),
//           child:
//               controller.isProcessing
//                   ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                   : const Text(
//                     'XÁC NHẬN ĐẶT HÀNG',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//         ),
//       ),
//     );
//   }

//   void _processOrder(CheckoutController controller) async {
//     final result = await controller.processOrder();

//     if (result != null) {
//       Get.offAll(() => OrderSuccessScreen(orderId: result.orderId));
//     }
//   }

//   void _showAddAddressDialog(CheckoutController controller) {
//     Get.dialog(
//       AddressFormDialog(controller: controller),
//       barrierDismissible: false,
//     );
//   }
// }

// class AddressCard extends StatelessWidget {
//   final Address address;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const AddressCard({
//     Key? key,
//     required this.address,
//     required this.isSelected,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 0,
//       shape: RoundedRectangleBorder(
//         side: BorderSide(
//           color:
//               isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
//           width: isSelected ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Radio<bool>(
//                 value: true,
//                 groupValue: isSelected,
//                 onChanged: (_) => onTap(),
//                 activeColor: Theme.of(context).primaryColor,
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on, size: 16),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             address.street,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         if (address.isDefault)
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.green[100],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Text(
//                               'Mặc định',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${address.city}, ${address.country}',
//                       style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AddressFormDialog extends StatefulWidget {
//   final CheckoutController controller;

//   const AddressFormDialog({Key? key, required this.controller})
//     : super(key: key);

//   @override
//   State<AddressFormDialog> createState() => _AddressFormDialogState();
// }

// class _AddressFormDialogState extends State<AddressFormDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _streetController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _countryController = TextEditingController();
//   bool _isDefault = false;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _streetController.dispose();
//     _cityController.dispose();
//     _countryController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'Thêm địa chỉ mới',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Get.back(),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: _streetController,
//                   decoration: const InputDecoration(
//                     labelText: 'Địa chỉ',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập địa chỉ';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _cityController,
//                   decoration: const InputDecoration(
//                     labelText: 'Thành phố',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập thành phố';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: _countryController,
//                   decoration: const InputDecoration(
//                     labelText: 'Quốc gia',
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Vui lòng nhập quốc gia';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 CheckboxListTile(
//                   title: const Text('Đặt làm địa chỉ mặc định'),
//                   value: _isDefault,
//                   onChanged: (value) {
//                     setState(() {
//                       _isDefault = value ?? false;
//                     });
//                   },
//                   contentPadding: EdgeInsets.zero,
//                   controlAffinity: ListTileControlAffinity.leading,
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _saveAddress,
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child:
//                         _isLoading
//                             ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 color: Colors.white,
//                               ),
//                             )
//                             : const Text('LƯU ĐỊA CHỈ'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _saveAddress() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         final newAddress = Address(
//           street: _streetController.text,
//           city: _cityController.text,
//           country: _countryController.text,
//           isDefault: _isDefault,
//         );

//         final success = await widget.controller.addAddress(newAddress);

//         if (success) {
//           Get.back(); // Close the dialog
//         } else {
//           Get.snackbar(
//             'Lỗi',
//             'Không thể thêm địa chỉ. Vui lòng thử lại sau.',
//             snackPosition: SnackPosition.BOTTOM,
//           );
//         }
//       } catch (e) {
//         Get.snackbar(
//           'Lỗi',
//           'Đã xảy ra lỗi: ${e.toString()}',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
// }
