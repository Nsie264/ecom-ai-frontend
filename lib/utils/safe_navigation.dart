import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Tiện ích để điều hướng an toàn giữa các màn hình khi sử dụng GetX
/// Ngăn ngừa lỗi "setState() or markNeedsBuild() called during build"
class SafeNavigation {
  /// Điều hướng đến một màn hình mới an toàn
  static void to(Widget page, {dynamic arguments}) {
    // Sử dụng post-frame callback để đảm bảo việc điều hướng xảy ra sau khi build hiện tại hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.to(() => page, arguments: arguments);
    });
  }

  /// Điều hướng đến một route đã đặt tên
  static void toNamed(String routeName, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(routeName, arguments: arguments);
    });
  }

  /// Điều hướng và xóa màn hình hiện tại khỏi ngăn xếp
  static void off(Widget page, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.off(() => page, arguments: arguments);
    });
  }

  /// Điều hướng và xóa tất cả màn hình trước đó
  static void offAll(Widget page, {dynamic arguments}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAll(() => page, arguments: arguments);
    });
  }

  /// Quay lại màn hình trước đó
  static void back() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.back();
    });
  }
}
