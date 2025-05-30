import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Helper class to safely navigate between screens
/// Ensures navigation doesn't happen during build phase
class NavigationHelper {
  /// Navigate to a new screen safely
  /// This method will delay navigation until after the current build phase is complete
  static void navigateTo(Widget page, {dynamic arguments}) {
    // Using post-frame callback to ensure navigation happens after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => page, arguments: arguments);
    });
  }

  /// Navigate to a named route safely
  static void navigateToNamed(String routeName, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(routeName, arguments: arguments);
    });
  }

  /// Navigate to a named route and remove previous screens
  static void navigateOffNamed(String routeName, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(routeName, arguments: arguments);
    });
  }

  /// Navigate to a screen and remove previous screens
  static void navigateOff(Widget page, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(() => page, arguments: arguments);
    });
  }

  /// Navigate to a screen and remove all previous screens
  static void navigateOffAll(Widget page, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => page, arguments: arguments);
    });
  }

  /// Go back to previous screen
  static void goBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.back();
    });
  }
}
