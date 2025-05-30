import 'package:get/get.dart';
import '../middleware/auth_middleware.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/login_selection_screen.dart';
import '../views/products/product_list_screen.dart';
import '../views/cart/cart_screen.dart';
import '../views/checkout/checkout_screen.dart';
import '../views/orders/order_history_screen.dart';
import '../views/orders/order_detail_screen.dart';
import '../views/admin/training_management_screen.dart';
import '../views/recommendations/user_recommendation_screen.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.LOGIN_SELECTION, page: () => LoginSelectionScreen()),
    GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
    GetPage(name: Routes.REGISTER, page: () => RegisterScreen()),
    GetPage(name: Routes.PRODUCTS, page: () => ProductListScreen()),
    GetPage(name: Routes.CART, page: () => const CartScreen()),
    // GetPage(
    //   name: Routes.CHECKOUT,
    //   page:
    //       () =>
    //           CheckoutScreen(totalAmount: Get.arguments['totalAmount'] ?? 0.0),
    //   middlewares: [AuthMiddleware()],
    // ),
    GetPage(
      name: Routes.ORDERS,
      page: () => const OrderHistoryScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.ADMIN_TRAINING,
      page: () => TrainingManagementScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.USER_RECOMMENDATIONS,
      page: () => UserRecommendationScreen(),
      middlewares: [AuthMiddleware()],
    ),
    // GetPage(
    //   name: Routes.ORDER_DETAIL,
    //   page: () => const OrderDetailScreen(),
    //   middlewares: [AuthMiddleware()],
    // ),
    // Add other routes here
  ];
}

class Routes {
  static const LOGIN_SELECTION = '/'; // New initial route
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PRODUCTS =
      '/products'; // This will be the main route after login
  static const CART = '/cart';
  static const CHECKOUT = '/checkout';
  static const ORDERS = '/orders';
  static const ORDER_DETAIL = '/orders/detail';
  static const ADMIN_TRAINING = '/admin/training';
  static const USER_RECOMMENDATIONS = '/recommendations';
  // Add other route constants here
}

class AppRoutes {
  static const LOGIN_SELECTION = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PRODUCTS = '/products';
  static const CART = '/cart';
  static const CHECKOUT = '/checkout';
  static const ORDERS = '/orders';
  static const ORDER_DETAIL = '/orders/detail';
  static const ADMIN_TRAINING = '/admin/training';
  static const USER_RECOMMENDATIONS = '/recommendations';
}
