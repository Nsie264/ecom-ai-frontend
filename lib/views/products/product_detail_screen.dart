import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/product_detail_controller.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/safe_navigation.dart';
import '../../widgets/product_horizontal_list.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  // Không thể truy cập productId trong initializer, nên thay đổi cách khai báo controller
  late final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller trong build method, sử dụng tag với productId
    controller = Get.put(
      ProductDetailController(Get.find<ProductApiService>()),
      tag: 'product_detail_$productId',
    );

    // Gọi API khi màn hình được tạo
    controller.fetchProductById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.product?.name ?? 'Product Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart screen using named route
              Get.toNamed('/cart');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return Center(child: Text('Error: ${controller.errorMessage}'));
        }

        if (controller.product == null) {
          return const Center(child: Text('Product not found'));
        }

        final product = controller.product!;
        return _buildProductDetail(context, product);
      }),
      bottomNavigationBar: Obx(() {
        if (controller.product == null) return const SizedBox.shrink();
        return _buildBottomBar(context);
      }),
    );
  }

  Widget _buildProductDetail(BuildContext context, Product product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with regular NetworkImage instead of CachedNetworkImage
          SizedBox(
            height: 300,
            width: double.infinity,
            child:
                product.images != null && product.images!.isNotEmpty
                    ? Image.network(
                      product.images!.first.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.grey[400],
                                size: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image available',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name & Price
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '${product.price.toStringAsFixed(0)}₫',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category
                Text(
                  'Category: ${product.categoryName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description ?? 'No description available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Related Products
                Text(
                  'Related Products',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Related Products List
                Obx(() {
                  if (controller.isRelatedLoading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.relatedProducts.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('No related products found')),
                    );
                  }

                  return HorizontalProductListWidget(
                    title: '',
                    products: controller.relatedProducts,
                    onProductTap: (product) {
                      // Sử dụng SafeNavigation để tránh lỗi
                      SafeNavigation.to(
                        ProductDetailScreen(productId: product.productId),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              controller.isProductInFavorites(productId)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              // TODO: Toggle favorite
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed:
                    controller.isAddingToCart
                        ? null
                        : () => controller.addToCart(),
                child:
                    controller.isAddingToCart
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Đang thêm...'),
                          ],
                        )
                        : Text('Thêm vào giỏ hàng'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
