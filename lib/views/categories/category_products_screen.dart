// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/product_controller.dart';
// import '../../models/product.dart';
// import '../../utils/safe_navigation.dart';
// import '../../widgets/product_grid.dart';
// import '../products/product_detail_screen.dart';

// class CategoryProductsScreen extends StatelessWidget {
//   final int categoryId;
//   final String categoryName;
//   final ProductController controller = Get.find<ProductController>();

//   CategoryProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.categoryName,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Nếu bạn đang thiết lập filter ở đây, trước build method
//     controller.applyCategory(categoryId);

//     return Scaffold(
//       appBar: AppBar(title: Text(categoryName)),
//       body: Obx(() {
//         if (controller.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (controller.hasError) {
//           return Center(child: Text(controller.errorMessage));
//         }

//         if (controller.products.isEmpty) {
//           return const Center(child: Text('No products found.'));
//         }

//         return ProductGrid(
//           products: controller.products,
//           isLoading: controller.isLoadingMore,
//           onLoadMore: controller.loadMoreProducts,
//           onProductTap: _navigateToProductDetail,
//         );
//       }),
//     );
//   }

//   // Nếu có bất kỳ hàm tùy chỉnh nào xử lý việc chuyển hướng đến detail screen,
//   // hãy đảm bảo cập nhật nó như sau:
//   void _navigateToProductDetail(Product product) {
//     SafeNavigation.to(ProductDetailScreen(productId: product.productId));
//   }
// }
