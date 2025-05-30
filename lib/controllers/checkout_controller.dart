// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/address.dart';
// import '../models/order.dart';
// import '../services/order_service.dart';
// import '../services/auth_service.dart';

// class CheckoutController extends GetxController {
//   // Services
//   final OrderApiService orderService;
//   final AuthApiService authService;

//   // Order details
//   final double totalAmount;
//   final List<Map<String, dynamic>>? orderItems;

//   // Observable state variables
//   final RxList<Address> _addresses = <Address>[].obs;
//   final Rx<Address?> _selectedAddress = Rx<Address?>(null);
//   final RxBool _isProcessing = false.obs;
//   final RxBool _isLoadingAddresses = false.obs;
//   final RxString _paymentMethod = 'COD'.obs; // Default payment method

//   // Getters
//   List<Address> get addresses => _addresses;
//   Address? get selectedAddress => _selectedAddress.value;
//   bool get isProcessing => _isProcessing.value;
//   bool get isLoadingAddresses => _isLoadingAddresses.value;
//   String get paymentMethod => _paymentMethod.value;

//   CheckoutController({
//     required this.orderService,
//     required this.authService,
//     required this.totalAmount,
//     this.orderItems,
//   });

//   @override
//   void onInit() {
//     super.onInit();
//     // Load addresses when controller initializes
//     fetchAddresses();
//   }

//   // Fetch addresses from the auth service
//   Future<void> fetchAddresses() async {
//     _isLoadingAddresses.value = true;
//     try {
//       final userAddresses = await authService.getUserAddresses();
//       _addresses.value = userAddresses;

//       // Select default address if available
//       if (userAddresses.isNotEmpty) {
//         selectDefaultAddress();
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Lỗi',
//         'Không thể tải địa chỉ: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     } finally {
//       _isLoadingAddresses.value = false;
//     }
//   }

//   // Set the default address
//   void selectDefaultAddress() {
//     if (_addresses.isNotEmpty) {
//       // Try to find the default address first
//       final defaultAddress = _addresses.firstWhereOrNull(
//         (addr) => addr.isDefault,
//       );

//       // If no default address is found, use the first one
//       _selectedAddress.value = defaultAddress ?? _addresses.first;
//     } else {
//       _selectedAddress.value = null;
//     }
//   }

//   // Select a specific address
//   void selectAddress(Address address) {
//     _selectedAddress.value = address;
//   }

//   // Process the order
//   Future<Order?> processOrder() async {
//     if (selectedAddress == null) {
//       Get.snackbar(
//         'Lỗi',
//         'Vui lòng chọn địa chỉ giao hàng',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return null;
//     }

//     _isProcessing.value = true;

//     try {
//       // Create shippingAddress map from the selected address
//       final Map<String, dynamic> shippingAddressMap = {
//         'address_id': selectedAddress!.addressId,
//         'street': selectedAddress!.street,
//         'city': selectedAddress!.city,
//         'country': selectedAddress!.country,
//       };

//       if (selectedAddress!.state != null) {
//         shippingAddressMap['state'] = selectedAddress!.state;
//       }

//       if (selectedAddress!.postalCode != null) {
//         shippingAddressMap['postal_code'] = selectedAddress!.postalCode;
//       }

//       if (selectedAddress!.phone != null) {
//         shippingAddressMap['phone'] = selectedAddress!.phone;
//       }

//       // Create the order using the OrderService directly
//       final Order result = await orderService.createOrder(
//         shippingAddress: shippingAddressMap,
//         paymentMethod: paymentMethod,
//       );

//       return result;
//     } catch (e) {
//       Get.snackbar(
//         'Lỗi',
//         'Đã xảy ra lỗi: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return null;
//     } finally {
//       _isProcessing.value = false;
//     }
//   }

//   // Add a new address
//   Future<bool> addAddress(Address address) async {
//     _isLoadingAddresses.value = true;
//     try {
//       final addedAddress = await authService.addAddress(address);
//       _addresses.add(addedAddress);

//       // Set as selected address if it's the first one
//       if (_addresses.length == 1 || address.isDefault) {
//         _selectedAddress.value = addedAddress;
//       }

//       return true;
//     } catch (e) {
//       Get.snackbar(
//         'Lỗi',
//         'Không thể thêm địa chỉ: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return false;
//     } finally {
//       _isLoadingAddresses.value = false;
//     }
//   }

//   // Helper method to format currency
//   String formatCurrency(double amount) {
//     return amount
//         .toStringAsFixed(0)
//         .replaceAllMapped(
//           RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//           (Match m) => '${m[1]}.',
//         );
//   }
// }
