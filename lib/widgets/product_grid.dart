import 'package:flutter/material.dart';
import '../models/product.dart';
import '../utils/safe_navigation.dart';
import '../views/products/product_detail_screen.dart';
import 'product_item.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const ProductGrid({
    Key? key,
    required this.products,
    this.isLoading = false,
    this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: isLoading ? products.length + 1 : products.length,
      itemBuilder: (context, index) {
        if (index == products.length) {
          if (onLoadMore != null) {
            onLoadMore!();
          }
          return const Center(child: CircularProgressIndicator());
        }

        final product = products[index];
        return ProductItem(
          product: product,
          onTap: () {
            SafeNavigation.to(
              ProductDetailScreen(productId: product.productId),
            );
          },
        );
      },
    );
  }
}
