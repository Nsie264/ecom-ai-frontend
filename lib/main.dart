import 'package:ecom_ai_frontend/controllers/cart_controller.dart';
import 'package:ecom_ai_frontend/controllers/order_controller.dart';
import 'package:ecom_ai_frontend/controllers/product_detail_controller.dart';
import 'package:ecom_ai_frontend/controllers/training_controller.dart';
import 'package:ecom_ai_frontend/services/cart_service.dart';
import 'package:ecom_ai_frontend/services/order_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecom_ai_frontend/middleware/auth_middleware.dart';

import 'config/api_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'routes/app_pages.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'utils/http_client.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/login_selection_screen.dart';
import 'views/products/product_list_screen.dart';
import 'views/profile/profile_screen.dart';
import 'services/recommendation_service.dart';
import 'controllers/recommendation_controller.dart';
import 'views/products/product_detail_screen.dart';
import 'views/cart/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize secure storage to check for stored token
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');

  // Initialize the HttpClient with the base URL
  final httpClient = HttpClient(ApiConfig.baseUrl);

  // If token exists, add it to the headers
  if (token != null) {
    httpClient.saveToken(token);
  }

  // Initialize services
  final authService = AuthApiService(httpClient);
  final productService = ProductApiService(httpClient);
  final cartService = CartApiService(httpClient);
  final orderService = OrderApiService(httpClient);
  final recommendationService = RecommendationApiService(httpClient);

  // Register services directly for dependency injection
  Get.put(httpClient);
  Get.put(productService);
  Get.put(cartService);
  Get.put(orderService);
  Get.put(recommendationService);

  // Initialize controllers and make them available throughout the app
  final authController = Get.put(AuthController(authService));
  Get.put(ProductController(productService));
  Get.put(CartController(cartService, authService, orderService));
  Get.put(OrderController(orderService));
  Get.put(RecommendationController(recommendationService));
  Get.put(ProductDetailController(productService));
  // Register TrainingController for admin training screen
  Get.put(TrainingController());

  // Check auth state
  if (token != null) {
    await authController.checkInitialAuthState();
  }

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Commerce AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      initialRoute: Routes.LOGIN_SELECTION,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => ProductListScreen(),
      ),
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    );
  }
}
