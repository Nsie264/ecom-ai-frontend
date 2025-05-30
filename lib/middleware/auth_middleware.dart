import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If the user is not logged in and trying to access protected routes
    if (!authController.isLoggedIn &&
        route != '/login' &&
        route != '/register') {
      return const RouteSettings(name: '/login');
    }

    // If the user is logged in and trying to access auth routes
    if (authController.isLoggedIn &&
        (route == '/login' || route == '/register')) {
      return const RouteSettings(name: '/products');
    }

    return null;
  }
}

class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();

    // If the user is logged in, redirect to products
    if (authController.isLoggedIn) {
      return const RouteSettings(name: '/products');
    }

    return null;
  }
}
