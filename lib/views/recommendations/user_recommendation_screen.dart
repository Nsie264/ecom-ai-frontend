import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recommendation_controller.dart';
import '../../models/product.dart';
import '../../widgets/product_item.dart';
import '../../utils/safe_navigation.dart';
import '../products/product_detail_screen.dart';

class UserRecommendationScreen extends StatelessWidget {
  final RecommendationController _recommendationController =
      Get.find<RecommendationController>();

  UserRecommendationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load recommendations when screen is opened
    _recommendationController.fetchPersonalizedRecommendations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đề xuất dành cho bạn'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    _recommendationController
                        .fetchPersonalizedRecommendations(),
            tooltip: 'Refresh Recommendations',
          ),
        ],
      ),
      body: Obx(() {
        if (_recommendationController.isLoadingPersonalized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_recommendationController.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${_recommendationController.errorMessage.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () =>
                          _recommendationController
                              .fetchPersonalizedRecommendations(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final recommendations =
            _recommendationController.personalizedRecommendations;

        if (recommendations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_neutral, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No personalized recommendations available yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Browse more products to get recommendations based on your interests',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final product = recommendations[index];
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
      }),
    );
  }
}
