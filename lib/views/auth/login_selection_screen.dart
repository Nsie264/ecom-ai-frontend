import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_pages.dart';

class LoginSelectionScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  LoginSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to E-Commerce AI'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Account Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _loginAsUser(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Customer Account'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loginAsAdmin(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text('Admin Account'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.toNamed(Routes.PRODUCT_MANAGEMENT),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.green,
              ),
              child: const Text('Product Management'),
            ),
          ],
        ),
      ),
    );
  }

  void _loginAsUser() async {
    try {
      final result = await _authController.login(
        'new@gmail.com',
        'password123',
      );

      if (result) {
        Get.offAllNamed(Routes.PRODUCTS);
      } else {
        Get.snackbar(
          'Login Failed',
          'Unable to login with customer account',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _loginAsAdmin() async {
    try {
      final result = await _authController.login(
        'admin@example.com',
        'password123',
      );

      if (result) {
        Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(Routes.ADMIN_TRAINING);
        Get.snackbar(
          'Admin Mode',
          'Logged in as Admin',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Login Failed',
          'Unable to login with admin account',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
