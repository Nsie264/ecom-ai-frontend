import 'package:get/get.dart';
import '../models/product.dart';
import '../services/recommendation_service.dart';

class RecommendationController extends GetxController {
  final RecommendationApiService _recommendationService;

  // Observable state variables
  final RxList<Product> similarProducts = <Product>[].obs;
  final RxList<Product> personalizedRecommendations = <Product>[].obs;
  final RxBool isLoadingSimilar = false.obs;
  final RxBool isLoadingPersonalized = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  RecommendationController(this._recommendationService);

  /// Fetch similar products based on a specific product ID
  Future<void> fetchSimilarProducts(int productId, {int limit = 10}) async {
    isLoadingSimilar.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final products = await _recommendationService.getSimilarProducts(
        productId,
        limit: limit,
      );
      similarProducts.value = products;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      similarProducts.clear();
    } finally {
      isLoadingSimilar.value = false;
    }
  }

  /// Fetch personalized recommendations for the current user
  Future<void> fetchPersonalizedRecommendations({int limit = 10}) async {
    isLoadingPersonalized.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final recommendations = await _recommendationService
          .getPersonalizedRecommendations(limit: limit);
      personalizedRecommendations.value = recommendations;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      personalizedRecommendations.clear();
    } finally {
      isLoadingPersonalized.value = false;
    }
  }

  // Workspace methods as requested in the prompt

  /// Fetch and process similar products for the workspace
  Future<void> workspaceSimilarProducts(int productId, {int limit = 10}) async {
    await fetchSimilarProducts(productId, limit: limit);

    // Additional workspace-specific processing could be added here
    // For example, filtering, sorting, or transforming the data

    // Log for debugging
    print('Loaded ${similarProducts.length} similar products for workspace');
  }

  /// Fetch and process personalized recommendations for the workspace
  Future<void> workspacePersonalizedRecommendations({int limit = 10}) async {
    await fetchPersonalizedRecommendations(limit: limit);

    // Additional workspace-specific processing could be added here
    // For example, filtering, sorting, or transforming the data

    // Log for debugging
    print(
      'Loaded ${personalizedRecommendations.length} personalized recommendations for workspace',
    );
  }

  /// Clear all recommendation data
  void clearRecommendations() {
    similarProducts.clear();
    personalizedRecommendations.clear();
    hasError.value = false;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // Clean up resources if needed
    clearRecommendations();
    super.onClose();
  }
}
