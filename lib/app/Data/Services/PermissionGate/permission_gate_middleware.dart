import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import 'permission_gate_service.dart';

/// Redirects any named navigation (in-app, notification tap, deep link) to
/// the blocking "Permissions Required" screen while a compulsory permission
/// is missing.
class PermissionGateMiddleware extends GetMiddleware {
  PermissionGateMiddleware() : super(priority: -100);

  @override
  RouteSettings? redirect(String? route) {
    if (!Get.isRegistered<PermissionGateService>()) return null;
    if (PermissionGateService.to.shouldBlockRoute(route)) {
      return const RouteSettings(name: Routes.permissionGate);
    }
    return null;
  }

  /// Adds the middleware to every page except the exempt ones.
  static List<GetPage> guard(List<GetPage> pages) {
    return pages.map((page) {
      if (PermissionGateService.exemptRoutes.contains(page.name)) return page;
      return page.copy(
        middlewares: [...?page.middlewares, PermissionGateMiddleware()],
      );
    }).toList();
  }
}
